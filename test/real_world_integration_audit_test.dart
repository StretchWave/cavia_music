import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:cavia_music/core/config/cavia_config.dart';
import 'package:cavia_music/core/domain/models/track.dart';
import 'package:cavia_music/core/domain/repositories/track_repository.dart';
import 'package:cavia_music/core/domain/result/result.dart';
import 'package:cavia_music/core/domain/result/app_error.dart';
import 'package:cavia_music/core/playback/playback_failure.dart';
import 'package:cavia_music/core/providers/local_audio_provider.dart';
import 'package:cavia_music/core/spotify/spotify_oauth_service.dart';

class _MockTrackRepo implements TrackRepository {
  final Map<String, Track> tracks = {};

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<Track, AppError>> getTrackById(String id, {String? profileId}) async {
    final t = tracks[id];
    if (t != null) return Result.success(t);
    return const Result.failure(NotFoundError('Not found'));
  }

  @override
  Future<Result<List<Track>, AppError>> getAllTracks({String? profileId}) async {
    return Result.success(tracks.values.toList());
  }
}

void main() {
  group('Real-World Integration Audit — Local Audio Verification', () {
    late _MockTrackRepo repo;
    late LocalAudioProvider localProvider;
    late Directory tempDir;

    setUp(() async {
      repo = _MockTrackRepo();
      localProvider = LocalAudioProvider(trackRepository: repo);
      tempDir = await Directory.systemTemp.createTemp('cavia_audit_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('LocalAudioProvider resolves audio source via filePath (not artworkAsset)', () async {
      final audioFile = File('${tempDir.path}/test_song.mp3');
      await audioFile.writeAsBytes([0, 1, 2, 3]);

      final track = Track(
        id: 'local_1',
        title: 'Local Test Track',
        artist: 'Local Artist',
        duration: const Duration(minutes: 3),
        artworkAsset: 'assets/images/cover_zenith.jpg', // Artwork is JPG
        filePath: audioFile.path, // Audio file is MP3
      );
      repo.tracks[track.id] = track;

      final res = await localProvider.resolvePlaybackSource(track.id);
      expect(res.isSuccess, true, reason: 'Must resolve audio from filePath even when artwork is JPG');
      final source = res.dataOrNull!;
      expect(source.isLocal, true);
      expect(p.normalize(source.uri.toFilePath()), p.normalize(audioFile.path));
    });

    test('LocalAudioProvider returns sourceUnavailable when local audio file is moved or deleted', () async {
      final missingPath = '${tempDir.path}/missing_song.flac';

      final track = Track(
        id: 'local_missing',
        title: 'Deleted Track',
        artist: 'Artist',
        duration: const Duration(minutes: 2),
        artworkAsset: 'assets/images/cover_zenith.jpg',
        filePath: missingPath,
      );
      repo.tracks[track.id] = track;

      final res = await localProvider.resolvePlaybackSource(track.id);
      expect(res.isFailure, true);
      final failure = res.errorOrNull!;
      expect(failure.type, PlaybackFailureType.sourceUnavailable);
      expect(failure.internalMessage.contains('missing or moved'), true);
    });

    test('LocalAudioProvider rejects non-audio file extensions', () async {
      final docFile = File('${tempDir.path}/notes.txt');
      await docFile.writeAsString('hello');

      final track = Track(
        id: 'local_txt',
        title: 'Text File',
        artist: 'Artist',
        duration: const Duration(minutes: 1),
        artworkAsset: 'assets/images/cover_zenith.jpg',
        filePath: docFile.path,
      );
      repo.tracks[track.id] = track;

      final res = await localProvider.resolvePlaybackSource(track.id);
      expect(res.isFailure, true);
      expect(res.errorOrNull!.type, PlaybackFailureType.sourceUnavailable);
    });
  });

  group('Real-World Integration Audit — Spotify OAuth Loopback & PKCE', () {
    test('SpotifyOAuthService rejects CSRF state mismatch', () async {
      final oauth = SpotifyOAuthService();
      await oauth.createAuthorizationUrl();

      final res = await oauth.handleAuthorizationCallback(
        callbackUrl: 'http://127.0.0.1:8888/callback?code=mock_code&state=invalid_tampered_state',
      );
      expect(res.isFailure, true);
      expect(res.errorOrNull?.userMessage.contains('Invalid OAuth state'), true);
    });

    test('SpotifyOAuthService exchanges authorization code for tokens via PKCE without client_secret', () async {
      String? requestBody;
      final mockHttp = http_testing.MockClient((req) async {
        if (req.url.path == '/api/token') {
          requestBody = req.body;
          return http.Response(
            jsonEncode({
              'access_token': 'sp_access_token_123',
              'token_type': 'Bearer',
              'expires_in': 3600,
              'refresh_token': 'sp_refresh_token_456',
              'scope': 'playlist-read-private playlist-read-collaborative',
            }),
            200,
          );
        }
        return http.Response('Not found', 404);
      });

      final oauth = SpotifyOAuthService(httpClient: mockHttp);
      final authUri = await oauth.createAuthorizationUrl();
      final validState = authUri.queryParameters['state']!;

      final res = await oauth.handleAuthorizationCallback(
        callbackUrl: 'http://127.0.0.1:8888/callback?code=valid_code_abc&state=$validState',
      );

      expect(res.isSuccess, true);
      final session = res.dataOrNull!;
      expect(session.accessToken, 'sp_access_token_123');
      expect(session.refreshToken, 'sp_refresh_token_456');

      // Verify PKCE request body conforms to RFC 7636: NO client_secret
      expect(requestBody != null, true);
      expect(requestBody!.contains('client_secret'), false, reason: 'PKCE MUST NEVER send client_secret');
      expect(requestBody!.contains('code_verifier'), true);
      expect(requestBody!.contains('grant_type=authorization_code'), true);
    });
  });

  group('Real-World Integration Audit — Security & Configuration', () {
    test('CaviaConfig strictly detects and rejects service_role Supabase keys', () {
      CaviaConfig.testOverrides = {
        'CAVIA_SUPABASE_URL': 'https://test-project.supabase.co',
        'CAVIA_SUPABASE_ANON_KEY': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.service_role.fake_jwt',
      };

      expect(CaviaConfig.supabaseConfigured, false,
          reason: 'Must reject service_role keys to protect RLS');

      CaviaConfig.testOverrides = {
        'CAVIA_SUPABASE_URL': 'https://test-project.supabase.co',
        'CAVIA_SUPABASE_ANON_KEY': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.anon.fake_jwt',
      };
      expect(CaviaConfig.supabaseConfigured, true);
      CaviaConfig.testOverrides = const {};
    });
  });
}
