import 'dart:io' show Platform;

/// Central compile-time configuration for Cavia Music.
///
/// All external credentials must be supplied through Flutter compile-time
/// defines (`--dart-define=NAME=VALUE`) or a `--dart-define-from-file=env.json`
/// (which can be generated from `.env` with the helper script documented in
/// README.md). A bare `.env` file is NEVER read automatically by Flutter —
/// this class is the single point that turns defines into runtime values.
///
/// No secret with server-side power (service keys, client secrets) is ever
/// read here. Only publishable/anonymous credentials are supported.
class CaviaConfig {
  CaviaConfig._();

  /// Tests can override values via this map (production is empty).
  static Map<String, String> testOverrides = const {};

  static String _define(String name, [String? fallback]) {
    final override = testOverrides[name];
    if (override != null) return override;
    final value = String.fromEnvironment(name);
    if (value.isNotEmpty) return value;
    return fallback ?? '';
  }

  static bool _defineBool(String name, [bool fallback = false]) {
    final raw = _define(name).toLowerCase();
    if (raw.isEmpty) return fallback;
    return raw == 'true' || raw == '1' || raw == 'yes';
  }

  static int? _defineInt(String name) {
    final raw = _define(name);
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  // ---------------------------------------------------------------------------
  // Application environment
  // ---------------------------------------------------------------------------

  /// 'development' | 'staging' | 'production'
  static String get appEnvironment => _define('CAVIA_APP_ENV', 'development');

  static bool get isDevelopment => appEnvironment == 'development';
  static bool get isProduction => appEnvironment == 'production';

  // ---------------------------------------------------------------------------
  // Supabase
  // ---------------------------------------------------------------------------

  /// Supabase project URL (e.g. https://xxxxx.supabase.co).
  static String get supabaseUrl => _define('CAVIA_SUPABASE_URL');

  /// Supabase **anon (publishable)** key. Never the service-role key: a
  /// service-role JWT would bypass Row Level Security and is rejected here.
  static String get supabaseAnonKey => _define('CAVIA_SUPABASE_ANON_KEY');

  /// True when both values are present and structurally sane.
  static bool get supabaseConfigured {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) return false;
    final okUrl = supabaseUrl.startsWith('https://') ||
        supabaseUrl.startsWith('http://localhost') ||
        supabaseUrl.startsWith('http://127.0.0.1');
    // Service-role keys are long JWTs starting 'eyJ'; anonymous keys also are,
    // but service-role keys are conventionally flagged by the 'service_role'
    // role claim inside their payload. Reject anything self-identifying.
    final looksLikeServiceRole = supabaseAnonKey.contains('service_role');
    return okUrl && !looksLikeServiceRole;
  }

  // ---------------------------------------------------------------------------
  // Spotify OAuth (PKCE)
  // ---------------------------------------------------------------------------

  /// Spotify application Client ID. Absent → Spotify import UI must degrade
  /// to an instructions state, never a fake preview.
  static String get spotifyClientId => _define('CAVIA_SPOTIFY_CLIENT_ID');

  static bool get spotifyConfigured => spotifyClientId.trim().isNotEmpty;

  /// Mobile / deep-link redirect (default aligned with AndroidManifest.xml).
  static String get spotifyRedirectUriMobile =>
      _define('CAVIA_SPOTIFY_REDIRECT_URI_MOBILE', 'caviamusic://auth/spotify/callback');

  /// Desktop loopback callback. The embedded local HTTP listener binds to the
  /// port contained in this URI (default 8888).
  static String get spotifyRedirectUriDesktop =>
      _define('CAVIA_SPOTIFY_REDIRECT_URI_DESKTOP', 'http://127.0.0.1:8888/callback');

  // Legacy single-value variable kept for backwards compatibility.
  static String get spotifyRedirectUriLegacy => _define('CAVIA_SPOTIFY_REDIRECT_URI');

  /// The redirect URI that applies to the current platform. Desktop targets
  /// prefer the loopback URI so no OS-level protocol registration is needed.
  static String get effectiveSpotifyRedirectUri {
    if (isDesktop) return spotifyRedirectUriDesktop;
    return spotifyRedirectUriMobile.isNotEmpty
        ? spotifyRedirectUriMobile
        : (spotifyRedirectUriLegacy.isNotEmpty
            ? spotifyRedirectUriLegacy
            : 'caviamusic://auth/spotify/callback');
  }

  // ---------------------------------------------------------------------------
  // Storage
  // ---------------------------------------------------------------------------

  static final int defaultCacheQuotaBytes =
      _defineInt('CAVIA_MAX_CACHE_SIZE_BYTES') ?? 1288490188; // 1.2 GiB

  // ---------------------------------------------------------------------------
  // Diagnostics
  // ---------------------------------------------------------------------------

  static bool get enableConsoleLogs =>
      _defineBool('CAVIA_ENABLE_CONSOLE_LOGS', isDevelopment);

  // ---------------------------------------------------------------------------
  // Platform
  // ---------------------------------------------------------------------------

  static bool get isDesktop {
    if (_isDesktopCached != null) return _isDesktopCached!;
    bool value = false;
    try {
      value = !const bool.fromEnvironment('dart.library.js_interop') &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
    } catch (_) {
      value = false;
    }
    _isDesktopCached = value;
    return value;
  }

  static bool? _isDesktopCached;
}
