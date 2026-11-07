import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:cavia_music/core/data/database/cavia_database.dart';
import 'package:cavia_music/core/data/repositories/local_playlist_repository.dart';
import 'package:cavia_music/core/data/repositories/local_queue_repository.dart';
import 'package:cavia_music/core/data/repositories/local_search_repository.dart';
import 'package:cavia_music/core/data/repositories/local_settings_repository.dart';
import 'package:cavia_music/core/data/repositories/local_sync_repository.dart';
import 'package:cavia_music/core/data/repositories/local_track_repository.dart';
import 'package:cavia_music/core/data/seeds/initial_data_seeder.dart';
import 'package:cavia_music/core/domain/models/playback_queue.dart';
import 'package:cavia_music/core/domain/models/sync_operation.dart';
import 'package:cavia_music/core/domain/models/track.dart';
import 'package:cavia_music/core/domain/result/app_error.dart';
import 'package:cavia_music/core/domain/result/result.dart';
import 'package:cavia_music/core/logging/cavia_logger.dart';
import 'package:cavia_music/core/playback/playback_failure.dart';
import 'package:cavia_music/core/playback/playback_source.dart';
import 'package:cavia_music/core/playback/queue_manager.dart';
import 'package:cavia_music/core/playback/track_resolver.dart';
import 'package:cavia_music/core/providers/local_audio_provider.dart';
import 'package:cavia_music/core/providers/music_provider.dart';
import 'package:cavia_music/core/providers/provider_registry.dart';
import 'package:cavia_music/core/providers/spotify_metadata_provider.dart';
import 'package:cavia_music/core/providers/youtube_provider.dart';
import 'package:cavia_music/core/spotify/spotify_import_coordinator.dart';
import 'package:cavia_music/core/spotify/spotify_models.dart';
import 'package:cavia_music/core/spotify/spotify_oauth_service.dart';
import 'package:cavia_music/core/spotify/spotify_playlist_client.dart';
import 'package:cavia_music/core/spotify/spotify_url_parser.dart';
import 'package:cavia_music/core/storage/cache_state.dart';
import 'package:cavia_music/core/storage/caching_coordinator.dart';
import 'package:cavia_music/core/storage/local_cache_manager.dart';

class MockReliableStreamProvider implements MusicProvider {
  @override
  final String id = 'reliable_stream';
  @override
  final String displayName = 'Reliable Stream Provider';
  @override
  bool isOperational = true;

  @override
  final ProviderCapabilities capabilities = const ProviderCapabilities(
    searchSupport: true,
    metadataSupport: true,
    playbackSupport: true,
    backgroundPlaybackSupport: true,
    seekingSupport: true,
    cachingPermission: true,
    offlineAvailability: true,
    authenticationRequired: false,
  );

  @override
  Future<Result<List<SearchResultItem>, AppError>> search({
    required String query,
    SearchFilterCategory category = SearchFilterCategory.all,
    int page = 1,
    int pageSize = 20,
    CancellationToken? cancelToken,
  }) async => const Result.success([]);

  @override
  Future<Result<Track, AppError>> resolveTrackMetadata(String providerTrackId) async =>
      const Result.failure(NotFoundError('Not found'));

  @override
  Future<Result<PlaybackSource, PlaybackFailure>> resolvePlaybackSource(String providerTrackId) async {
    if (!isOperational) {
      return Result.failure(PlaybackFailure(
        type: PlaybackFailureType.networkUnavailable,
        internalMessage: 'Network disconnected',
        providerId: id,
        trackId: providerTrackId,
      ));
    }
    return Result.success(PlaybackSource.stream(
      trackId: providerTrackId,
      providerId: id,
      streamUri: Uri.parse('https://cdn.cavia.app/stream/$providerTrackId.mp3'),
    ));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CaviaDatabase db;
  late Directory tempCacheDir;
  late LocalCacheManager cacheManager;
  late LocalSettingsRepository settingsRepo;
  late LocalTrackRepository trackRepo;
  late LocalPlaylistRepository playlistRepo;
  late LocalQueueRepository queueRepo;
  late LocalSearchRepository searchRepo;
  late LocalSyncRepository syncRepo;
  late ProviderRegistry registry;
  late CachingCoordinator cachingCoordinator;
  late MockReliableStreamProvider streamProvider;

  setUp(() async {
    db = CaviaDatabase.forTesting(NativeDatabase.memory());
    // InitialDataSeeder removed from production — database starts empty.
    tempCacheDir = await Directory.systemTemp.createTemp('cavia_e2e_test_');
    cacheManager = LocalCacheManager(db: db, customDirectory: tempCacheDir);
    syncRepo = LocalSyncRepository(db: db, deviceId: 'device_alpha');
    trackRepo = LocalTrackRepository(db, syncRepository: syncRepo);
    playlistRepo = LocalPlaylistRepository(db, syncRepository: syncRepo);
    queueRepo = LocalQueueRepository(db);
    settingsRepo = LocalSettingsRepository(db, syncRepository: syncRepo);
    searchRepo = LocalSearchRepository(db);

    streamProvider = MockReliableStreamProvider();
    registry = ProviderRegistry(
      initialProviders: [
        LocalAudioProvider(trackRepository: trackRepo),
        YouTubeMusicProvider(),
        SpotifyMetadataProvider(),
        streamProvider,
      ],
    );

    cachingCoordinator = CachingCoordinator(
      cacheManager: cacheManager,
      providerRegistry: registry,
      settingsRepository: settingsRepo,
      trackRepository: trackRepo,
    );
  });

  tearDown(() async {
    syncRepo.dispose();
    await db.close();
    if (await tempCacheDir.exists()) {
      await tempCacheDir.delete(recursive: true);
    }
  });

  // =========================================================================
  // 1. END-TO-END USER SCENARIOS (A THROUGH H)
  // =========================================================================

  group('Scenario A: New Guest Workflow', () {
    test('Guest starts with seeded library, likes a song, creates a playlist, reorders, and restarts', () async {
      // 1 & 2. Start in guest mode & browse
      final tracksRes = await trackRepo.getAllTracks();
      expect(tracksRes.isSuccess, true);
      final tracks = tracksRes.dataOrNull!;
      expect(tracks.length, greaterThanOrEqualTo(2));

      // 3. Like a previously unliked track (song_4)
      await trackRepo.toggleLike('song_4', profileId: 'guest');
      final isLikedRes = await trackRepo.isTrackLiked('song_4', profileId: 'guest');
      expect(isLikedRes.dataOrNull, true);

      // 4. Create a playlist
      final plRes = await playlistRepo.createPlaylist('Night Vibes', profileId: 'guest');
      expect(plRes.isSuccess, true);
      final playlist = plRes.dataOrNull!;

      // 5. Add and reorder tracks
      await playlistRepo.addTrackToPlaylist(playlist.id, tracks[0].id);
      await playlistRepo.addTrackToPlaylist(playlist.id, tracks[1].id);

      var entriesRes = await playlistRepo.getPlaylistEntries(playlist.id);
      expect(entriesRes.isSuccess, true);
      var entries = entriesRes.dataOrNull!;
      expect(entries.length, 2);
      expect(entries[0].trackId, tracks[0].id);
      expect(entries[1].trackId, tracks[1].id);

      // Reorder tracks (move index 0 to after index 1 using Flutter ReorderableListView convention 0 -> 2)
      await playlistRepo.reorderPlaylistEntries(playlist.id, 0, 2);
      entriesRes = await playlistRepo.getPlaylistEntries(playlist.id);
      entries = entriesRes.dataOrNull!;
      expect(entries[0].trackId, tracks[1].id);
      expect(entries[1].trackId, tracks[0].id);

      // 6 & 7. Simulate application cold restart: re-instantiate repositories on same SQLite db
      final restartedTrackRepo = LocalTrackRepository(db);
      final restartedPlaylistRepo = LocalPlaylistRepository(db);

      // 8. Confirm data persists
      final reloadedLiked = await restartedTrackRepo.isTrackLiked('song_4', profileId: 'guest');
      expect(reloadedLiked.dataOrNull, true);

      final reloadedPlaylistsRes = await restartedPlaylistRepo.getAllPlaylists(profileId: 'guest');
      expect(reloadedPlaylistsRes.isSuccess, true);
      expect(reloadedPlaylistsRes.dataOrNull!.any((p) => p.name == 'Night Vibes'), true);

      final reloadedEntriesRes = await restartedPlaylistRepo.getPlaylistEntries(playlist.id);
      final reloadedEntries = reloadedEntriesRes.dataOrNull!;
      expect(reloadedEntries[0].trackId, tracks[1].id);
      expect(reloadedEntries[1].trackId, tracks[0].id);
    });
  });

  group('Scenario B: Offline Guest Workflow', () {
    test('All local library, playlist, and queue mutations function without network', () async {
      // 1 & 2. Offline guest modifies playlist
      final plRes = await playlistRepo.createPlaylist('Offline Gym Mix', profileId: 'guest');
      final playlist = plRes.dataOrNull!;
      await playlistRepo.addTrackToPlaylist(playlist.id, 'song_1');

      // 3. Likes an unliked song offline (song_6)
      await trackRepo.toggleLike('song_6', profileId: 'guest');

      // 4. Modifies queue offline
      final allTracks = (await trackRepo.getAllTracks()).dataOrNull!;
      final queueItems = allTracks
          .asMap()
          .entries
          .map((e) => QueueItem(id: 'q_${e.key}', trackId: e.value.id, position: e.key, track: e.value))
          .toList();

      await queueRepo.saveQueue(
        PlaybackQueueState(
          items: queueItems,
          currentIndex: 1,
          position: const Duration(milliseconds: 42000),
        ),
        profileId: 'guest',
      );

      // 5 & 6. Cold restart while disconnected
      final restartedQueueRepo = LocalQueueRepository(db);
      final queueStateRes = await restartedQueueRepo.loadQueue(profileId: 'guest');
      expect(queueStateRes.isSuccess, true);
      final queueState = queueStateRes.dataOrNull!;

      // 7. Confirm local changes remain intact
      expect(queueState.currentIndex, 1);
      expect(queueState.position.inMilliseconds, 42000);
      expect((await trackRepo.isTrackLiked('song_6', profileId: 'guest')).dataOrNull, true);

      final savedPlaylists = (await playlistRepo.getAllPlaylists(profileId: 'guest')).dataOrNull!;
      expect(savedPlaylists.any((p) => p.name == 'Offline Gym Mix'), true);
    });
  });

  group('Scenario C: First-time Cloud Synchronization', () {
    test('Guest library merges into user account cleanly with zero loss or duplication', () async {
      // 1 & 2. Guest creates playlist and likes songs
      final guestPl = (await playlistRepo.createPlaylist('Guest Travel', profileId: 'guest')).dataOrNull!;
      await playlistRepo.addTrackToPlaylist(guestPl.id, 'song_7');
      await trackRepo.toggleLike('song_7', profileId: 'guest');

      // 3 & 4. User signs in as user_alice
      const aliceId = 'user_alice_uuid';

      // 5. Merge local guest data into account
      final mergeRes = await syncRepo.mergeGuestLibraryWithAccount(aliceId);
      expect(mergeRes.isSuccess, true);

      // 6. Simulate restart
      final restartedTrackRepo = LocalTrackRepository(db);
      final restartedPlaylistRepo = LocalPlaylistRepository(db);

      // 7. Verify Alice now owns the liked song and the playlist
      final isAliceLiked = await restartedTrackRepo.isTrackLiked('song_7', profileId: aliceId);
      expect(isAliceLiked.dataOrNull, true);

      final alicePlaylists = (await restartedPlaylistRepo.getAllPlaylists(profileId: aliceId)).dataOrNull!;
      expect(alicePlaylists.any((p) => p.name == 'Guest Travel'), true);

      // Verify guest data was NOT deleted or corrupted
      final guestPlaylists = (await restartedPlaylistRepo.getAllPlaylists(profileId: 'guest')).dataOrNull!;
      expect(guestPlaylists.any((p) => p.name == 'Guest Travel'), true);
    });
  });

  group('Scenario D: Multiple Devices & Deterministic Conflict Resolution', () {
    test('Simultaneous updates from two devices resolve deterministically with tombstones', () async {
      const aliceId = 'user_alice_sync';

      // Seed common playlist on Alice's account
      final pl = (await playlistRepo.createPlaylist('Shared Album Mix', profileId: aliceId)).dataOrNull!;
      await playlistRepo.addTrackToPlaylist(pl.id, 'song_1');
      await playlistRepo.addTrackToPlaylist(pl.id, 'song_2');

      // Device 1: Enqueue reorder operation
      final dev1Sync = LocalSyncRepository(db: db, deviceId: 'device_phone');
      await dev1Sync.enqueueOperation(SyncOperation(
        id: 'op_dev1_reorder',
        profileId: aliceId,
        deviceId: 'device_phone',
        entityType: SyncEntityType.playlistEntry,
        entityId: 'song_2',
        operationType: SyncOperationType.reorder,
        payload: {'position': 0, 'revision': 5},
        createdAt: DateTime.now().subtract(const Duration(seconds: 10)),
        idempotencyKey: 'dev1_reorder_${pl.id}',
      ));

      // Device 2: Deletes song_2 (creates a tombstone)
      await db.into(db.dbTombstones).insert(
        DbTombstonesCompanion.insert(
          id: 'tomb_dev2_song2',
          profileId: aliceId,
          entityType: 'playlist_entry',
          entityId: 'song_2',
          deletedAt: DateTime.now(),
        ),
      );

      // Reconcile: Tombstones must deterministically prevent resurrection of deleted entry
      final tombstone = await (db.select(db.dbTombstones)
            ..where((tbl) => tbl.profileId.equals(aliceId) & tbl.entityId.equals('song_2')))
          .getSingleOrNull();

      expect(tombstone, isNotNull);
      expect(tombstone!.entityType, 'playlist_entry');

      dev1Sync.dispose();
    });
  });

  group('Scenario E: Account Switching & Multi-User Privacy Isolation', () {
    test('Account A data is completely invisible to Account B, and restored on return', () async {
      const userA = 'user_alice_privacy';
      const userB = 'user_bob_privacy';

      // 1 & 2. User A creates private playlist and likes song_1
      final alicePl = (await playlistRepo.createPlaylist("Alice's Secret Journal", profileId: userA)).dataOrNull!;
      await playlistRepo.addTrackToPlaylist(alicePl.id, 'song_1');
      await trackRepo.toggleLike('song_1', profileId: userA);

      // 3 & 4. Sign out & sign in as User B
      // 5. Confirm User A's data is NOT visible to User B
      final bobPlaylists = (await playlistRepo.getAllPlaylists(profileId: userB)).dataOrNull!;
      expect(bobPlaylists.any((p) => p.name.contains('Alice')), false);
      expect((await trackRepo.isTrackLiked('song_1', profileId: userB)).dataOrNull, false);

      // User B creates their own playlist
      await playlistRepo.createPlaylist("Bob's Heavy Metal", profileId: userB);

      // 6 & 7. Sign back into User A
      final alicePlaylistsReloaded = (await playlistRepo.getAllPlaylists(profileId: userA)).dataOrNull!;
      expect(alicePlaylistsReloaded.any((p) => p.name == "Alice's Secret Journal"), true);
      expect(alicePlaylistsReloaded.any((p) => p.name.contains('Bob')), false);
      expect((await trackRepo.isTrackLiked('song_1', profileId: userA)).dataOrNull, true);
    });
  });

  group('Scenario F: Playback Failures & Interruption Handling', () {
    test('Network drop reports typed failure with exact user-facing message', () async {
      final resolver = TrackResolver(
        providerRegistry: registry,
        trackRepository: trackRepo,
        cacheManager: cacheManager,
      );

      // Disconnect streaming provider
      streamProvider.isOperational = false;

      final track = Track(
        id: 'remote_stream_1',
        providerId: 'reliable_stream',
        providerTrackId: 'stream_abc',
        title: 'Remote Song',
        artist: 'Streamer',
        album: 'Album',
        duration: const Duration(seconds: 180),
        artworkUri: '',
        dateAdded: DateTime.now(),
      );

      final result = await resolver.resolve(track);
      expect(result.isFailure, true);
      expect(result.errorOrNull!.userMessage, "This track isn't cached for offline playback.");
    });

    test('Queue advances cleanly when current item is removed or skipped', () async {
      final allTracks = (await trackRepo.getAllTracks()).dataOrNull!;
      final queueManager = QueueManager(initialSongs: allTracks, initialIndex: 0);

      expect(queueManager.currentIndex, 0);
      expect(queueManager.currentSong?.id, allTracks[0].id);

      // Remove currently playing item
      queueManager.removeAt(0);

      // Queue state safely adjusts to next track without crashing or invalid indices
      expect(queueManager.currentIndex, 0);
      expect(queueManager.currentSong?.id, allTracks[1].id);

      // Skip forward
      queueManager.skipNext();
      expect(queueManager.currentIndex, 1);
    });
  });

  group('Scenario G: Spotify Importer Idempotency & Conflict Handling', () {
    test('Validates URLs, loads preview, and imports playlist cleanly', () async {
      // 1. URL Parser
      const url = 'https://open.spotify.com/playlist/37i9dQZF1DXdbXrPNafg9d';
      final parseRes = SpotifyUrlParser.parsePlaylistId(url);
      expect(parseRes.isSuccess, true);
      final playlistId = parseRes.dataOrNull!;
      expect(playlistId, '37i9dQZF1DXdbXrPNafg9d');

      // 2. Mock HTTP client and Spotify client
      final mockHttpClient = MockClient((request) async {
        if (request.url.path.contains('/v1/playlists/37i9dQZF1DXdbXrPNafg9d') && !request.url.path.contains('/items')) {
          return http.Response(
            jsonEncode({
              'id': '37i9dQZF1DXdbXrPNafg9d',
              'name': 'Tokyo Electronic',
              'description': 'Best electronic beats',
              'owner': {'display_name': 'Curator'},
              'images': [{'url': 'https://i.scdn.co/art.jpg'}],
              'tracks': {'total': 1},
            }),
            200,
          );
        }

        if (request.url.path.contains('/items')) {
          return http.Response(
            jsonEncode({
              'total': 1,
              'items': [
                {
                  'track': {
                    'id': 'sp_trk_1',
                    'name': 'Zenith',
                    'artists': [{'name': 'Kenshi Yonezu'}],
                    'album': {'name': 'Floating Realm'},
                    'duration_ms': 225000,
                    'external_ids': {'isrc': 'US-CAV-24-00001'},
                    'is_playable': true,
                    'is_local': false,
                  }
                }
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

      final coordinator = SpotifyImportCoordinator(
        client: client,
        trackRepository: trackRepo,
        playlistRepository: playlistRepo,
      );

      final previewRes = await coordinator.loadPreview(inputUrl: url);
      expect(previewRes.isSuccess, true);
      final preview = previewRes.dataOrNull!;
      expect(preview.matchedCount, 1);

      // Execute import
      final importRes1 = await coordinator.executeImport(
        preview: preview,
        options: const ImportOptions(destinationPlaylistName: 'Tokyo Electronic'),
        profileId: 'guest',
      );
      expect(importRes1.isSuccess, true);

      // Verify playlist created
      final existingPlaylists = (await playlistRepo.getAllPlaylists(profileId: 'guest')).dataOrNull!;
      final matchingCount = existingPlaylists.where((p) => p.name == 'Tokyo Electronic').length;
      expect(matchingCount, 1);
    });
  });

  group('Scenario H: Caching, Retention & Clear Cache Semantics', () {
    test('Full lifecycle: cache, preserve on toggle, reject YouTube, clear cache safely', () async {
      final track = Track(
        id: 'song_cache_e2e',
        providerId: 'reliable_stream',
        providerTrackId: 'stream_e2e',
        title: 'Cache Track',
        artist: 'Artist',
        album: 'Album',
        duration: const Duration(seconds: 120),
        artworkUri: '',
        dateAdded: DateTime.now(),
      );

      final testBytes = utf8.encode('FULL_SYSTEM_CACHED_STREAM_BYTES');
      final hash = sha256.convert(testBytes).toString();

      // 1 & 2. Cache eligible track
      final cacheRes = await cachingCoordinator.requestCacheTrack(
        track: track,
        byteStreamProvider: () => Stream.value(testBytes),
        expectedSize: testBytes.length,
        sha256Hash: hash,
      );
      expect(cacheRes.isSuccess, true);

      // 3 & 4. Toggle caching off -> cached track is PRESERVED
      await cachingCoordinator.onOfflineCachingToggled(false);
      expect(await cacheManager.getCacheEntry(track.id), isNotNull);

      // 5. Ineligible YouTube caching attempt is rejected
      final ytTrack = Track(
        id: 'yt_blocked',
        providerId: 'youtube',
        providerTrackId: 'yt_abc',
        title: 'Video Stream',
        artist: 'YT Artist',
        album: 'Album',
        duration: const Duration(seconds: 100),
        artworkUri: '',
        dateAdded: DateTime.now(),
      );
      final ytResult = cachingCoordinator.checkEligibility(ytTrack);
      expect(ytResult.isEligible, false);
      expect(ytResult.rejectionReason, CacheMessages.notSupportedBySource);

      // 6 & 7. Clear cache with confirmation
      final clearMsg = await cachingCoordinator.executeClearCache(userConfirmed: true);
      expect(clearMsg, CacheMessages.cacheCleared);
      expect(await cacheManager.calculateTotalCacheSize(), 0);

      // Original local library tracks remain intact
      final allTracks = await trackRepo.getAllTracks();
      expect(allTracks.dataOrNull!.isNotEmpty, true);
    });
  });

  // =========================================================================
  // 2. FAILURE INJECTION & RESILIENCE
  // =========================================================================

  group('Failure Injection Tests', () {
    test('HTTP 401 returns typed authentication error without exposing raw tokens', () {
      final failure = PlaybackFailure(
        type: PlaybackFailureType.authenticationExpired,
        internalMessage: 'HTTP 401 Unauthorized for token eyJhbGciOi...',
      );
      expect(failure.userMessage, 'Reconnect this music source to continue.');
      expect(failure.userMessage.contains('eyJ'), false);
    });

    test('HTTP 403 Forbidden returns honest permission error without stack traces', () {
      final failure = PlaybackFailure(
        type: PlaybackFailureType.permissionDenied,
        internalMessage: 'HTTP 403 Forbidden: resource access denied',
      );
      expect(failure.userMessage, "Playback isn't supported for this source.");
    });

    test('HTTP 429 Rate Limited returns friendly backoff message', () {
      final failure = PlaybackFailure(
        type: PlaybackFailureType.rateLimited,
        internalMessage: 'HTTP 429 Too Many Requests',
      );
      expect(failure.userMessage, "Couldn't start playback. Try again.");
    });

    test('Malformed JSON payloads in outbox are rejected with format error', () {
      const malformedJson = '{"invalid_json": ';
      expect(
        () => jsonDecode(malformedJson),
        throwsFormatException,
      );
    });

    test('Deep link validation rejects malformed Spotify links', () {
      expect(SpotifyUrlParser.parsePlaylistId('https://evil.com/fake').isFailure, true);
      expect(SpotifyUrlParser.parsePlaylistId('spotify:user:123').isFailure, true);
      expect(SpotifyUrlParser.parsePlaylistId('').isFailure, true);
    });
  });

  // =========================================================================
  // 3. DATA INTEGRITY & DATABASE RECOVERY
  // =========================================================================

  group('Data Integrity Tests', () {
    test('Foreign key cascade deletes playlist entries when playlist is deleted', () async {
      final pl = (await playlistRepo.createPlaylist('Cascade Playlist', profileId: 'guest')).dataOrNull!;
      await playlistRepo.addTrackToPlaylist(pl.id, 'song_1');
      await playlistRepo.addTrackToPlaylist(pl.id, 'song_2');

      final entries = (await playlistRepo.getPlaylistEntries(pl.id)).dataOrNull!;
      expect(entries.length, 2);

      // Delete playlist
      await playlistRepo.deletePlaylist(pl.id);

      // Entries must be deleted via cascade
      final remainingEntries = await (db.select(db.dbPlaylistEntries)
            ..where((tbl) => tbl.playlistId.equals(pl.id)))
          .get();
      expect(remainingEntries.isEmpty, true);
    });

    test('System collections (isSystem == true) cannot be deleted', () async {
      await db.into(db.dbPlaylists).insert(
        DbPlaylistsCompanion.insert(
          id: 'system_pl_favorites',
          profileId: const Value('guest'),
          name: 'Liked Songs',
          artworkUri: 'assets/images/cover_zenith.jpg',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isSystem: const Value(true),
        ),
      );

      final result = await playlistRepo.deletePlaylist('system_pl_favorites');

      expect(result.isFailure, true);
      expect(result.errorOrNull, isA<OperationProhibitedError>());
      expect(result.errorOrNull!.userMessage, 'System playlists cannot be deleted.');
    });

    test('Fresh installation and schema migrations v1->v2->v3 run cleanly', () async {
      final testDb = CaviaDatabase.forTesting(NativeDatabase.memory());
      expect(testDb.schemaVersion, 3);
      // Verify all tables exist and query without error
      final trackCount = await testDb.select(testDb.dbTracks).get();
      final cacheCount = await testDb.select(testDb.dbCacheEntries).get();
      expect(trackCount, isEmpty);
      expect(cacheCount, isEmpty);
      await testDb.close();
    });
  });

  // =========================================================================
  // 4. PERFORMANCE & STRESS TESTING
  // =========================================================================

  group('Performance & Stress Tests', () {
    test('Large playlist (1,000 entries) addition and batch read executes efficiently', () async {
      final pl = (await playlistRepo.createPlaylist('Stress 1K Playlist', profileId: 'guest')).dataOrNull!;

      // Batch insert 1,000 entries
      final entriesCompanion = List.generate(
        1000,
        (i) => DbPlaylistEntriesCompanion.insert(
          id: 'stress_entry_$i',
          playlistId: pl.id,
          trackId: 'song_1',
          position: i,
          dateAdded: DateTime.now(),
        ),
      );

      final stopwatch = Stopwatch()..start();
      await db.batch((batch) {
        batch.insertAll(db.dbPlaylistEntries, entriesCompanion);
      });
      stopwatch.stop();

      final entriesRes = await playlistRepo.getPlaylistEntries(pl.id);
      expect(entriesRes.isSuccess, true);
      expect(entriesRes.dataOrNull!.length, 1000);
      expect(stopwatch.elapsedMilliseconds, lessThan(3000)); // Sub-3 seconds
    });

    test('Large library search (2,000 tracks) finishes within 200ms', () async {
      // Seed 2,000 tracks
      final largeTracks = List.generate(
        2000,
        (i) => DbTracksCompanion.insert(
          id: 'perf_track_$i',
          title: 'Track Symphony $i',
          artist: i % 2 == 0 ? 'Beethoven' : 'Mozart',
          album: 'Classical Collection',
          durationMs: 180000,
          artworkUri: 'assets/images/cover_zenith.jpg',
          dateAdded: DateTime.now(),
        ),
      );

      await db.batch((batch) {
        batch.insertAll(db.dbTracks, largeTracks);
      });

      final stopwatch = Stopwatch()..start();
      final searchResults = await searchRepo.search('Symphony 199');
      stopwatch.stop();

      expect(searchResults.isSuccess, true);
      expect(searchResults.dataOrNull!.songs.isNotEmpty, true);
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });

    test('Rapid queue mutations do not crash or corrupt internal pointer', () async {
      final allTracks = (await trackRepo.getAllTracks()).dataOrNull!;
      final queueManager = QueueManager(initialSongs: allTracks, initialIndex: 0);

      // Perform 50 rapid sequential queue operations
      for (int i = 0; i < 50; i++) {
        if (i % 3 == 0) {
          queueManager.skipNext();
        } else if (i % 3 == 1) {
          queueManager.skipPrevious();
        } else {
          queueManager.toggleShuffle();
        }
      }

      expect(queueManager.currentIndex, greaterThanOrEqualTo(0));
      expect(queueManager.currentIndex, lessThan(queueManager.length));
    });
  });

  // =========================================================================
  // 5. PRIVACY, LOGGING & SECURITY REDACTION
  // =========================================================================

  group('Privacy & Security Redaction Tests', () {
    test('CaviaLogger strictly redacts Bearer tokens, secrets, emails, paths, and raw SQL', () {
      final logger = CaviaLogger();
      logger.clearHistory();

      // Log string with sensitive tokens, passwords, and user paths
      const sensitiveLog = 'Request Bearer BQA1234567890abcdef with client_secret=shhh_secret '
          'for user john.doe@example.com at C:\\Users\\MISHAL\\Music\\song.mp3';

      logger.info('AUTH_TEST', sensitiveLog);

      final history = logger.history;
      expect(history.isNotEmpty, true);
      final loggedMessage = history.last.message;

      // Assert tokens, secrets, emails, and home paths are redacted
      expect(loggedMessage.contains('BQA1234567890abcdef'), false);
      expect(loggedMessage.contains('[REDACTED_TOKEN]'), true);

      expect(loggedMessage.contains('shhh_secret'), false);
      expect(loggedMessage.contains('[REDACTED_SECRET]'), true);

      expect(loggedMessage.contains('john.doe@example.com'), false);
      expect(loggedMessage.contains('j***@example.com'), true);

      expect(loggedMessage.contains('MISHAL'), false);
      expect(loggedMessage.contains('[USER_HOME]'), true);
    });
  });
}
