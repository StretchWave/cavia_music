import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../domain/result/result.dart';
import '../domain/result/app_error.dart';

/// Stored Spotify OAuth session tokens.
class SpotifyTokenSession {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final String scope;

  const SpotifyTokenSession({
    required this.accessToken,
    this.refreshToken,
    required this.expiresAt,
    required this.scope,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt.subtract(const Duration(seconds: 30)));

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_at_ms': expiresAt.millisecondsSinceEpoch,
        'scope': scope,
      };

  factory SpotifyTokenSession.fromJson(Map<String, dynamic> json) => SpotifyTokenSession(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String?,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(json['expires_at_ms'] as int),
        scope: json['scope'] as String? ?? '',
      );
}

/// Spotify Authorization Code with PKCE (Proof Key for Code Exchange) OAuth Service.
///
/// SPECIFICATION RULES:
/// - Never embed a Spotify client secret in the client application.
/// - Minimum necessary scopes only: 'playlist-read-private', 'playlist-read-collaborative'.
/// - Never request playback scopes.
/// - Cryptographically secure state parameter validated before accepting callback.
/// - Tokens stored in OS secure credential storage (Android Keystore / iOS Keychain / Windows Credential Manager).
class SpotifyOAuthService {
  final String clientId;
  final String redirectUri;
  final FlutterSecureStorage secureStorage;
  final http.Client httpClient;

  String? _pendingCodeVerifier;
  String? _pendingState;
  SpotifyTokenSession? _cachedSession;

  static const String _storageKeySession = 'cavia_spotify_oauth_session';
  static const String _storageKeyVerifier = 'cavia_spotify_pkce_verifier';
  static const String _storageKeyState = 'cavia_spotify_oauth_state';

  SpotifyOAuthService({
    String? clientId,
    String? redirectUri,
    FlutterSecureStorage? secureStorage,
    http.Client? httpClient,
  })  : clientId = clientId ?? const String.fromEnvironment('CAVIA_SPOTIFY_CLIENT_ID', defaultValue: 'cavia_music_spotify_client'),
        redirectUri = redirectUri ?? const String.fromEnvironment('CAVIA_SPOTIFY_REDIRECT_URI', defaultValue: 'caviamusic://auth/spotify/callback'),
        secureStorage = secureStorage ?? const FlutterSecureStorage(),
        httpClient = httpClient ?? http.Client();

  // Scope: strictly minimal permissions (reading playlists). NO playback scopes.
  static const List<String> scopes = [
    'playlist-read-private',
    'playlist-read-collaborative',
  ];

  /// Generates a high-entropy cryptographically random PKCE code verifier (RFC 7636).
  String generateCodeVerifier([int length = 64]) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// Generates S256 PKCE code challenge from [verifier].
  String generateCodeChallenge(String verifier) {
    final bytes = ascii.encode(verifier);
    final digest = sha256.convert(bytes);
    // Base64-URL encode without padding
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  /// Generates cryptographically secure state.
  String generateState() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(values).replaceAll('=', '');
  }

  /// Builds the Spotify OAuth PKCE authorization URL and persists state & verifier.
  Future<Uri> createAuthorizationUrl() async {
    final verifier = generateCodeVerifier();
    final challenge = generateCodeChallenge(verifier);
    final state = generateState();

    _pendingCodeVerifier = verifier;
    _pendingState = state;

    try {
      await secureStorage.write(key: _storageKeyVerifier, value: verifier);
      await secureStorage.write(key: _storageKeyState, value: state);
    } catch (_) {
      // Platform fallback: retained in-memory
    }

    final queryParams = {
      'client_id': clientId,
      'response_type': 'code',
      'redirect_uri': redirectUri,
      'code_challenge_method': 'S256',
      'code_challenge': challenge,
      'state': state,
      'scope': scopes.join(' '),
    };

    return Uri.https('accounts.spotify.com', '/authorize', queryParams);
  }

  /// Validates OAuth callback and exchanges code for tokens.
  Future<Result<SpotifyTokenSession, AppError>> handleAuthorizationCallback({
    required String callbackUrl,
  }) async {
    final uri = Uri.parse(callbackUrl);
    final code = uri.queryParameters['code'];
    final returnedState = uri.queryParameters['state'];
    final error = uri.queryParameters['error'];

    if (error != null) {
      return Result.failure(ValidationError('Spotify authorization failed: $error'));
    }

    if (code == null) {
      return const Result.failure(ValidationError('Missing authorization code in callback'));
    }

    // Retrieve pending state and verifier
    String? expectedState = _pendingState;
    String? verifier = _pendingCodeVerifier;

    if (expectedState == null || verifier == null) {
      try {
        expectedState ??= await secureStorage.read(key: _storageKeyState);
        verifier ??= await secureStorage.read(key: _storageKeyVerifier);
      } catch (_) {}
    }

    // Security Check: Validate state parameter to prevent CSRF
    if (returnedState == null || returnedState != expectedState) {
      return const Result.failure(ValidationError(
        'Invalid OAuth state. The authorization response may have been tampered with.',
      ));
    }

    if (verifier == null) {
      return const Result.failure(ValidationError('Missing PKCE code verifier'));
    }

    // Exchange code for tokens via PKCE POST (NO client_secret required)
    return await _exchangeCodeForTokens(code: code, verifier: verifier);
  }

  Future<Result<SpotifyTokenSession, AppError>> _exchangeCodeForTokens({
    required String code,
    required String verifier,
  }) async {
    try {
      final response = await httpClient.post(
        Uri.https('accounts.spotify.com', '/api/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'client_id': clientId,
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': redirectUri,
          'code_verifier': verifier,
        },
      );

      if (response.statusCode != 200) {
        return Result.failure(ValidationError(
          "Couldn't complete Spotify authorization (HTTP ${response.statusCode})",
          details: response.body,
        ));
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final accessToken = json['access_token'] as String;
      final refreshToken = json['refresh_token'] as String?;
      final expiresIn = json['expires_in'] as int? ?? 3600;
      final scope = json['scope'] as String? ?? '';

      final session = SpotifyTokenSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
        scope: scope,
      );

      _cachedSession = session;
      await _persistSession(session);

      return Result.success(session);
    } catch (e, st) {
      return Result.failure(StorageError(
        userMessage: "Couldn't connect to Spotify.",
        details: e.toString(),
        cause: st,
      ));
    }
  }

  /// Refreshes expired access token using stored refresh token.
  Future<Result<SpotifyTokenSession, AppError>> refreshAccessToken() async {
    final session = await getSession();
    if (session == null || session.refreshToken == null) {
      return const Result.failure(ValidationError('Reconnect Spotify to continue.'));
    }

    try {
      final response = await httpClient.post(
        Uri.https('accounts.spotify.com', '/api/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'client_id': clientId,
          'grant_type': 'refresh_token',
          'refresh_token': session.refreshToken!,
        },
      );

      if (response.statusCode != 200) {
        return const Result.failure(ValidationError('Reconnect Spotify to continue.'));
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final newAccessToken = json['access_token'] as String;
      final newRefreshToken = (json['refresh_token'] as String?) ?? session.refreshToken;
      final expiresIn = json['expires_in'] as int? ?? 3600;

      final updated = SpotifyTokenSession(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
        scope: session.scope,
      );

      _cachedSession = updated;
      await _persistSession(updated);

      return Result.success(updated);
    } catch (e, st) {
      return Result.failure(StorageError(
        userMessage: 'Reconnect Spotify to continue.',
        details: e.toString(),
        cause: st,
      ));
    }
  }

  /// Get active valid session, auto-refreshing if expired.
  Future<SpotifyTokenSession?> getSession() async {
    if (_cachedSession != null && !_cachedSession!.isExpired) {
      return _cachedSession;
    }

    try {
      final raw = await secureStorage.read(key: _storageKeySession);
      if (raw != null) {
        final session = SpotifyTokenSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        if (session.isExpired && session.refreshToken != null) {
          final refreshed = await refreshAccessToken();
          return refreshed.dataOrNull;
        }
        _cachedSession = session;
        return session;
      }
    } catch (_) {}

    return _cachedSession;
  }

  bool get isConnected => _cachedSession != null && !_cachedSession!.isExpired;

  /// Disconnect and securely purge all stored tokens.
  Future<void> disconnect() async {
    _cachedSession = null;
    _pendingCodeVerifier = null;
    _pendingState = null;
    try {
      await secureStorage.delete(key: _storageKeySession);
      await secureStorage.delete(key: _storageKeyVerifier);
      await secureStorage.delete(key: _storageKeyState);
    } catch (_) {}
  }

  Future<void> _persistSession(SpotifyTokenSession session) async {
    try {
      await secureStorage.write(
        key: _storageKeySession,
        value: jsonEncode(session.toJson()),
      );
    } catch (_) {}
  }

  /// Completes the OAuth PKCE flow on desktop by spinning up a local HTTP loopback server,
  /// opening the authorization URL in the system browser, and capturing the callback.
  Future<Result<SpotifyTokenSession, AppError>> authenticateDesktopLoopback({
    int port = 8888,
    Duration timeout = const Duration(minutes: 3),
  }) async {
    HttpServer? server;
    try {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
      final authUri = await createAuthorizationUrl();
      if (await canLaunchUrl(authUri)) {
        await launchUrl(authUri, mode: LaunchMode.externalApplication);
      } else {
        await server.close(force: true);
        return const Result.failure(ValidationError('Could not launch system browser for Spotify authorization.'));
      }

      final request = await server.first.timeout(timeout);
      final callbackUri = request.uri;
      final fullCallbackUrl = 'http://127.0.0.1:$port${callbackUri.path}?${callbackUri.query}';

      request.response.headers.contentType = ContentType.html;
      request.response.write('''
<!DOCTYPE html>
<html>
<head><title>Cavia Music - Connected</title><style>body { background: #0D0F13; color: #EDEAE4; font-family: sans-serif; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; text-align: center; } h1 { color: #E53935; font-size: 24px; } p { color: #A0A5B2; }</style></head>
<body>
  <div>
    <h1>CAVIA / SPOTIFY CONNECTED</h1>
    <p>Authorization successful. You may close this tab and return to Cavia Music.</p>
  </div>
</body>
</html>
''');
      await request.response.close();
      await server.close(force: true);

      return await handleAuthorizationCallback(callbackUrl: fullCallbackUrl);
    } catch (e, st) {
      await server?.close(force: true);
      return Result.failure(StorageError(
        userMessage: 'Spotify authorization timed out or failed to connect.',
        details: e.toString(),
        cause: st,
      ));
    }
  }
}

