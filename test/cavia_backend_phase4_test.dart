import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cavia_music/core/data/database/cavia_database.dart';
import 'package:cavia_music/core/data/repositories/local_track_repository.dart';
import 'package:cavia_music/core/data/repositories/local_playlist_repository.dart';
import 'package:cavia_music/core/data/seeds/initial_data_seeder.dart';
import 'package:cavia_music/core/domain/models/track.dart';
import 'package:cavia_music/core/spotify/spotify_models.dart';
import 'package:cavia_music/core/spotify/spotify_url_parser.dart';
import 'package:cavia_music/core/spotify/spotify_oauth_service.dart';
import 'package:cavia_music/core/spotify/spotify_playlist_client.dart';
import 'package:cavia_music/core/spotify/spotify_track_matcher.dart';
import 'package:cavia_music/core/spotify/spotify_import_coordinator.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Spotify URL & URI Validation Tests', () {
    test('Standard Spotify playlist URLs are parsed and cleaned', () {
      const url = 'https://open.spotify.com/playlist/37i9dQZF1DXdbXrPNafg9d';
      final res = SpotifyUrlParser.parsePlaylistId(url);
      expect(res.isSuccess, true);
      expect(res.dataOrNull, '37i9dQZF1DXdbXrPNafg9d');
    });

    test('Playlist URL with tracking parameters strips parameters cleanly', () {
      const url = 'https://open.spotify.com/playlist/37i9dQZF1DXdbXrPNafg9d?si=4826b1a2bf0d4e92&pt=xyz123';
      final res = SpotifyUrlParser.parsePlaylistId(url);
      expect(res.isSuccess, true);
      expect(res.dataOrNull, '37i9dQZF1DXdbXrPNafg9d');
    });

    test('Spotify URI format is parsed correctly', () {
      const uri = 'spotify:playlist:37i9dQZF1DXdbXrPNafg9d';
      final res = SpotifyUrlParser.parsePlaylistId(uri);
      expect(res.isSuccess, true);
      expect(res.dataOrNull, '37i9dQZF1DXdbXrPNafg9d');
    });

    test('Copied link with leading and trailing whitespace is trimmed', () {
      const url = '   https://open.spotify.com/playlist/37i9dQZF1DXdbXrPNafg9d \n ';
      final res = SpotifyUrlParser.parsePlaylistId(url);
      expect(res.isSuccess, true);
      expect(res.dataOrNull, '37i9dQZF1DXdbXrPNafg9d');
    });

    test('Rejects album links with explicit user message', () {
      const url = 'https://open.spotify.com/album/4eLPsYPBmXABThSJ821sqY';
      final res = SpotifyUrlParser.parsePlaylistId(url);
      expect(res.isFailure, true);
      expect(
        res.errorOrNull?.userMessage,
        'This is an album link. Cavia playlist import only supports playlists.',
      );
    });

    test('Rejects artist links with explicit user message', () {
      const url = 'https://open.spotify.com/artist/06HL4z0CvFAxyc27GXpf02';
      final res = SpotifyUrlParser.parsePlaylistId(url);
      expect(res.isFailure, true);
      expect(
        res.errorOrNull?.userMessage,
        'This is an artist link. Cavia playlist import only supports playlists.',
      );
    });

    test('Rejects track links with explicit user message', () {
      const url = 'https://open.spotify.com/track/11dFghVXANMlKmJXsNCbNl';
      final res = SpotifyUrlParser.parsePlaylistId(url);
      expect(res.isFailure, true);
      expect(
        res.errorOrNull?.userMessage,
        'This is a track link. Cavia playlist import only supports playlists.',
      );
    });

    test('Rejects podcast episode links with explicit user message', () {
      const url = 'https://open.spotify.com/episode/7makk4oTQel546B0PZlDM5';
      final res = SpotifyUrlParser.parsePlaylistId(url);
      expect(res.isFailure, true);
      expect(res.errorOrNull?.userMessage, 'Podcasts are not supported.');
    });

    test('Rejects non-Spotify URLs and empty input', () {
      final resEmpty = SpotifyUrlParser.parsePlaylistId('');
      expect(resEmpty.isFailure, true);

      final resNonSpotify = SpotifyUrlParser.parsePlaylistId('https://music.apple.com/playlist/123');
      expect(resNonSpotify.isFailure, true);
      expect(resNonSpotify.errorOrNull?.userMessage, 'Not a valid Spotify link.');
    });
  });

  group('Spotify OAuth PKCE & Token Lifecycle Tests', () {
    late SpotifyOAuthService oauth;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      oauth = SpotifyOAuthService(
        clientId: 'test_client_id',
        redirectUri: 'caviamusic://spotify/callback',
      );
    });

    test('Code verifier meets RFC 7636 high-entropy requirements (43-128 chars)', () {
      final verifier = oauth.generateCodeVerifier();
      expect(verifier.length >= 43 && verifier.length <= 128, true);
      expect(RegExp(r'^[A-Za-z0-9-._~]+$').hasMatch(verifier), true);
    });

    test('Code challenge correctly implements S256 base64url encoding without padding', () {
      const testVerifier = 'dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk';
      final challenge = oauth.generateCodeChallenge(testVerifier);
      expect(challenge.contains('='), false);
      expect(challenge.contains('+'), false);
      expect(challenge.contains('/'), false);
    });

    test('Authorization URL contains PKCE challenge and minimal playlist scopes', () async {
      final authUri = await oauth.createAuthorizationUrl();
      expect(authUri.host, 'accounts.spotify.com');
      expect(authUri.path, '/authorize');
      expect(authUri.queryParameters['code_challenge_method'], 'S256');
      expect(authUri.queryParameters['code_challenge']?.isNotEmpty, true);
      expect(authUri.queryParameters['state']?.isNotEmpty, true);

      final scopes = authUri.queryParameters['scope']!;
      expect(scopes.contains('playlist-read-private'), true);
      expect(scopes.contains('playlist-read-collaborative'), true);
      // Strictly NO playback scopes
      expect(scopes.contains('streaming'), false);
      expect(scopes.contains('user-modify-playback-state'), false);
    });

    test('Callback rejects tampered state parameter with security error', () async {
      await oauth.createAuthorizationUrl(); // seeds pending state
      const tamperedCallback = 'caviamusic://spotify/callback?code=mock_code&state=tampered_state';

      final result = await oauth.handleAuthorizationCallback(callbackUrl: tamperedCallback);
      expect(result.isFailure, true);
      expect(result.errorOrNull?.userMessage.contains('Invalid OAuth state'), true);
    });

    test('Successful callback exchanges code for tokens and persists session securely', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path == '/api/token') {
          return http.Response(
            jsonEncode({
              'access_token': 'mock_access_token_123',
              'token_type': 'Bearer',
              'expires_in': 3600,
              'refresh_token': 'mock_refresh_token_xyz',
              'scope': 'playlist-read-private',
            }),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final service = SpotifyOAuthService(
        clientId: 'test_client_id',
        redirectUri: 'caviamusic://spotify/callback',
        httpClient: mockClient,
      );

      final authUri = await service.createAuthorizationUrl();
      final validState = authUri.queryParameters['state']!;

      final callbackUrl = 'caviamusic://spotify/callback?code=valid_code&state=$validState';
      final result = await service.handleAuthorizationCallback(callbackUrl: callbackUrl);

      expect(result.isSuccess, true);
      final session = result.dataOrNull!;
      expect(session.accessToken, 'mock_access_token_123');
      expect(session.refreshToken, 'mock_refresh_token_xyz');

      // Verify session can be retrieved from secure storage
      final retrieved = await service.getSession();
      expect(retrieved?.accessToken, 'mock_access_token_123');

      // Disconnect purges tokens
      await service.disconnect();
      final afterDisconnect = await service.getSession();
      expect(afterDisconnect, null);
    });
  });

  group('Track Matching Hierarchy & Version Preservation Tests', () {
    late SpotifyTrackMatcher matcher;
    late List<Track> catalog;

    setUp(() {
      matcher = SpotifyTrackMatcher();
      catalog = [
        Track(
          id: 'cat_1',
          title: 'Afterglow',
          artist: 'Luna Caine',
          album: 'Afterglow EP',
          duration: const Duration(minutes: 4, seconds: 9),
          artworkAsset: 'assets/images/cover_afterglow.jpg',
          isrc: 'USRC12345678',
          dateAdded: DateTime.now(),
        ),
        Track(
          id: 'cat_2',
          title: 'Afterglow (Acoustic)',
          artist: 'Luna Caine',
          album: 'Acoustic Sessions',
          duration: const Duration(minutes: 3, seconds: 55),
          artworkAsset: 'assets/images/cover_afterglow.jpg',
          isrc: 'USRC87654321',
          dateAdded: DateTime.now(),
        ),
        Track(
          id: 'cat_3',
          title: 'Zenith',
          artist: 'Kenshi Yonezu',
          album: 'Zenith Horizon',
          duration: const Duration(minutes: 3, seconds: 45),
          artworkAsset: 'assets/images/cover_zenith.jpg',
          dateAdded: DateTime.now(),
        ),
      ];
    });

    test('1. Exact ISRC match pairs track with high confidence', () {
      const spotifyTrack = SpotifyTrackItem(
        id: 'sp_1',
        name: 'Afterglow - Alternate Name',
        artist: 'Luna Caine',
        album: 'Unknown Compilation',
        duration: Duration(minutes: 4, seconds: 9),
        isrc: 'USRC12345678',
      );

      final result = matcher.matchTrack(spotifyTrack: spotifyTrack, availableTracks: catalog);
      expect(result.confidence, MatchConfidence.highConfidence);
      expect(result.matchedTrackId, 'cat_1');
      expect(result.matchReason.contains('ISRC'), true);
    });

    test('2. Exact normalized title and artist matches with high confidence', () {
      const spotifyTrack = SpotifyTrackItem(
        id: 'sp_3',
        name: 'zenith',
        artist: 'Kenshi Yonezu',
        album: 'Zenith Horizon',
        duration: Duration(minutes: 3, seconds: 44),
      );

      final result = matcher.matchTrack(spotifyTrack: spotifyTrack, availableTracks: catalog);
      expect(result.confidence, MatchConfidence.highConfidence);
      expect(result.matchedTrackId, 'cat_3');
    });

    test('3. Version Preservation: Never matches Remix/Live/Acoustic to standard original', () {
      const spotifyRemix = SpotifyTrackItem(
        id: 'sp_remix',
        name: 'Afterglow (Remix)',
        artist: 'Luna Caine',
        album: 'Club Remixes',
        duration: Duration(minutes: 4, seconds: 9),
      );

      // Catalog has original "Afterglow" and "Afterglow (Acoustic)", but no Remix
      final result = matcher.matchTrack(spotifyTrack: spotifyRemix, availableTracks: catalog);
      // Must NOT match to original "Afterglow"!
      expect(result.confidence, MatchConfidence.unmatched);
      expect(result.matchedTrackId, null);
    });

    test('4. Correctly matches Acoustic version to Acoustic catalog track', () {
      const spotifyAcoustic = SpotifyTrackItem(
        id: 'sp_ac',
        name: 'Afterglow (Acoustic)',
        artist: 'Luna Caine',
        album: 'Acoustic Sessions',
        duration: Duration(minutes: 3, seconds: 55),
      );

      final result = matcher.matchTrack(spotifyTrack: spotifyAcoustic, availableTracks: catalog);
      expect(result.confidence, MatchConfidence.highConfidence);
      expect(result.matchedTrackId, 'cat_2');
    });

    test('5. Large duration discrepancy (> 15s) is classified as ambiguous', () {
      const spotifyRadioEdit = SpotifyTrackItem(
        id: 'sp_short',
        name: 'Zenith',
        artist: 'Kenshi Yonezu',
        album: 'Zenith Horizon',
        duration: Duration(minutes: 2, seconds: 30), // 75s shorter
      );

      final result = matcher.matchTrack(spotifyTrack: spotifyRadioEdit, availableTracks: catalog);
      expect(result.confidence, MatchConfidence.ambiguous);
    });

    test('6. Unplayable or local items are classified as unavailable', () {
      const localFile = SpotifyTrackItem(
        id: 'sp_loc',
        name: 'Custom MP3',
        artist: 'Self',
        album: 'None',
        duration: Duration(minutes: 2),
        isLocal: true,
      );

      final result = matcher.matchTrack(spotifyTrack: localFile, availableTracks: catalog);
      expect(result.confidence, MatchConfidence.unavailable);
      expect(result.isMatched, false);
    });
  });

  group('Import Coordinator & Transactional Commit Tests', () {
    late CaviaDatabase db;
    late LocalTrackRepository trackRepo;
    late LocalPlaylistRepository playlistRepo;
    late SpotifyImportCoordinator coordinator;

    setUp(() async {
      db = CaviaDatabase.forTesting(NativeDatabase.memory());
      await InitialDataSeeder(db).seedIfNeeded();
      trackRepo = LocalTrackRepository(db);
      playlistRepo = LocalPlaylistRepository(db);

      // Mock client returning a playlist with 3 tracks (2 matched, 1 unmatched)
      final mockHttpClient = MockClient((request) async {
        if (request.url.path.contains('/v1/playlists/37i9dQZF1DXdbXrPNafg9d') && !request.url.path.contains('/items')) {
          return http.Response(
            jsonEncode({
              'id': '37i9dQZF1DXdbXrPNafg9d',
              'name': 'Tokyo Night Drive',
              'description': 'Best synthwave and lo-fi beats',
              'owner': {'display_name': 'Spotify Curator'},
              'images': [
                {'url': 'https://i.scdn.co/image/mock_art.jpg'}
              ],
              'tracks': {'total': 3},
            }),
            200,
          );
        }

        if (request.url.path.contains('/items')) {
          return http.Response(
            jsonEncode({
              'total': 3,
              'items': [
                {
                  'track': {
                    'id': 'sp_trk_1',
                    'name': 'Afterglow',
                    'artists': [
                      {'name': 'Luna Caine'}
                    ],
                    'album': {'name': 'Nocturne Whispers'},
                    'duration_ms': 249000,
                    'external_ids': {'isrc': 'US-CAV-24-00001'},
                    'is_playable': true,
                    'is_local': false,
                  }
                },
                {
                  'track': {
                    'id': 'sp_trk_2',
                    'name': 'Zenith',
                    'artists': [
                      {'name': 'Kenshi Yonezu'}
                    ],
                    'album': {'name': 'Floating Realm'},
                    'duration_ms': 225000,
                    'external_ids': {'isrc': 'JP-CAV-24-00002'},
                    'is_playable': true,
                    'is_local': false,
                  }
                },
                {
                  'track': {
                    'id': 'sp_trk_3',
                    'name': 'Unreleased Mystery Song',
                    'artists': [
                      {'name': 'Unknown Artist'}
                    ],
                    'album': {'name': 'Unknown'},
                    'duration_ms': 180000,
                    'is_playable': true,
                    'is_local': false,
                  }
                },
              ],
              'next': null,
            }),
            200,
          );
        }

        return http.Response('Not Found', 404);
      });

      final oauth = SpotifyOAuthService(httpClient: mockHttpClient);
      final client = SpotifyPlaylistClient(oAuthService: oauth, httpClient: mockHttpClient);

      coordinator = SpotifyImportCoordinator(
        client: client,
        trackRepository: trackRepo,
        playlistRepository: playlistRepo,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('Preview loads metadata and calculates match statistics without creating playlist', () async {
      final playlistsBefore = await playlistRepo.getAllPlaylists();
      final countBefore = playlistsBefore.dataOrNull?.length ?? 0;

      final previewRes = await coordinator.loadPreview(
        inputUrl: 'https://open.spotify.com/playlist/37i9dQZF1DXdbXrPNafg9d',
      );

      expect(previewRes.isSuccess, true);
      final preview = previewRes.dataOrNull!;
      expect(preview.metadata.name, 'Tokyo Night Drive');
      expect(preview.metadata.ownerName, 'Spotify Curator');
      expect(preview.tracks.length, 3);
      expect(preview.matchedCount, 2); // Afterglow & Zenith
      expect(preview.unmatchedCount, 1); // Unreleased Mystery Song

      // VERIFY: Database was NOT modified during preview loading
      final playlistsAfter = await playlistRepo.getAllPlaylists();
      expect(playlistsAfter.dataOrNull?.length, countBefore);
    });

    test('Execute confirmed import creates Cavia playlist and populates matched tracks', () async {
      final previewRes = await coordinator.loadPreview(
        inputUrl: 'https://open.spotify.com/playlist/37i9dQZF1DXdbXrPNafg9d',
      );
      final preview = previewRes.dataOrNull!;

      final summaryRes = await coordinator.executeImport(
        preview: preview,
        options: const ImportOptions(
          destinationPlaylistName: 'Tokyo Night Drive',
          skipDuplicates: true,
          skipUnmatched: true,
        ),
      );

      expect(summaryRes.isSuccess, true);
      final summary = summaryRes.dataOrNull!;
      expect(summary.totalTracks, 3);
      expect(summary.importedCount, 2);
      expect(summary.unmatchedCount, 1);
      // Exact specification message verification
      expect(summary.userMessage, 'Imported 2 of 3 tracks');
      expect(summary.unmatchedMessage, '1 tracks couldn\'t be matched.');

      // Verify playlist was created in SQLite database
      final allPlaylists = await playlistRepo.getAllPlaylists();
      final importedPl = allPlaylists.dataOrNull?.firstWhere((p) => p.name == 'Tokyo Night Drive');
      expect(importedPl != null, true);

      // Verify entries in playlist
      final entries = await playlistRepo.getPlaylistEntries(importedPl!.id);
      expect(entries.dataOrNull?.length, 2);
    });

    test('Handles 403 / 404 forbidden playlist with honest explanation', () async {
      final forbiddenClient = MockClient((request) async {
        return http.Response('Forbidden', 403);
      });

      final oauth = SpotifyOAuthService(httpClient: forbiddenClient);
      final client = SpotifyPlaylistClient(oAuthService: oauth, httpClient: forbiddenClient);
      final forbiddenCoordinator = SpotifyImportCoordinator(
        client: client,
        trackRepository: trackRepo,
        playlistRepository: playlistRepo,
      );

      final res = await forbiddenCoordinator.loadPreview(
        inputUrl: 'https://open.spotify.com/playlist/48j0eRAG2EYecYsQObgh0e',
      );

      expect(res.isFailure, true);
      expect(
        res.errorOrNull?.userMessage,
        "Spotify didn't provide track details for this playlist.",
      );
    });
  });
}
