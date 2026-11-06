import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cavia_music/core/data/database/cavia_database.dart';
import 'package:cavia_music/core/data/repositories/local_settings_repository.dart';
import 'package:cavia_music/core/data/repositories/local_track_repository.dart';
import 'package:cavia_music/core/data/seeds/initial_data_seeder.dart';
import 'package:cavia_music/core/domain/models/track.dart';
import 'package:cavia_music/core/playback/playback_failure.dart';
import 'package:cavia_music/core/playback/playback_source.dart';
import 'package:cavia_music/core/playback/track_resolver.dart';
import 'package:cavia_music/core/providers/local_audio_provider.dart';
import 'package:cavia_music/core/providers/music_provider.dart';
import 'package:cavia_music/core/providers/provider_registry.dart';
import 'package:cavia_music/core/providers/spotify_metadata_provider.dart';
import 'package:cavia_music/core/domain/result/result.dart';
import 'package:cavia_music/core/domain/result/app_error.dart';
import 'package:cavia_music/core/providers/youtube_provider.dart';
import 'package:cavia_music/core/storage/cache_state.dart';
import 'package:cavia_music/core/storage/caching_coordinator.dart';
import 'package:cavia_music/core/storage/local_cache_manager.dart';

class MockCachableProvider implements MusicProvider {
  @override
  final String id = 'cachable_provider';
  @override
  final String displayName = 'Cachable Stream Provider';
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
      const Result.failure(NotFoundError('Track not found'));

  @override
  Future<Result<PlaybackSource, PlaybackFailure>> resolvePlaybackSource(String providerTrackId) async {
    return Result.success(PlaybackSource.stream(
      trackId: providerTrackId,
      providerId: id,
      streamUri: Uri.parse('https://stream.example.com/$providerTrackId.mp3'),
    ));
  }
}

class MockRestrictedProvider implements MusicProvider {
  @override
  final String id = 'restricted_provider';
  @override
  final String displayName = 'Restricted DRM Provider';
  @override
  bool isOperational = true;

  @override
  final ProviderCapabilities capabilities = const ProviderCapabilities(
    searchSupport: true,
    metadataSupport: true,
    playbackSupport: true,
    backgroundPlaybackSupport: true,
    seekingSupport: true,
    cachingPermission: false, // Disallowed
    offlineAvailability: false,
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
      const Result.failure(NotFoundError('Track not found'));

  @override
  Future<Result<PlaybackSource, PlaybackFailure>> resolvePlaybackSource(String providerTrackId) async =>
      const Result.failure(PlaybackFailure(
        type: PlaybackFailureType.playbackUnsupported,
        internalMessage: 'Playback disallowed on restricted provider',
      ));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CaviaDatabase db;
  late Directory tempCacheDir;
  late LocalCacheManager cacheManager;
  late LocalSettingsRepository settingsRepo;
  late LocalTrackRepository trackRepo;
  late ProviderRegistry registry;
  late CachingCoordinator coordinator;
  late MockCachableProvider cachableProvider;
  late MockRestrictedProvider restrictedProvider;

  setUp(() async {
    db = CaviaDatabase.forTesting(NativeDatabase.memory());
    await InitialDataSeeder(db).seedIfNeeded();

    tempCacheDir = await Directory.systemTemp.createTemp('cavia_cache_test_');
    cacheManager = LocalCacheManager(db: db, customDirectory: tempCacheDir);
    settingsRepo = LocalSettingsRepository(db);
    trackRepo = LocalTrackRepository(db);

    cachableProvider = MockCachableProvider();
    restrictedProvider = MockRestrictedProvider();

    registry = ProviderRegistry(
      initialProviders: [
        LocalAudioProvider(trackRepository: trackRepo),
        YouTubeMusicProvider(),
        SpotifyMetadataProvider(),
        cachableProvider,
        restrictedProvider,
      ],
    );

    coordinator = CachingCoordinator(
      cacheManager: cacheManager,
      providerRegistry: registry,
      settingsRepository: settingsRepo,
      trackRepository: trackRepo,
    );
  });

  tearDown(() async {
    await db.close();
    if (await tempCacheDir.exists()) {
      await tempCacheDir.delete(recursive: true);
    }
  });

  group('1. Eligibility & Provider Policy Enforcement Tests', () {
    test('YouTube tracks are strictly rejected from caching with exact UI message', () {
      final ytTrack = Track(
        id: 'yt_track_1',
        providerId: 'youtube',
        providerTrackId: 'dQw4w9WgXcQ',
        title: 'Never Gonna Give You Up',
        artist: 'Rick Astley',
        album: 'Whenever You Need Somebody',
        duration: const Duration(seconds: 213),
        artworkUri: 'https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg',
        dateAdded: DateTime.now(),
      );

      final result = coordinator.checkEligibility(ytTrack);

      expect(result.isEligible, false);
      expect(result.state, CacheState.notSupportedBySource);
      expect(result.rejectionReason, CacheMessages.notSupportedBySource);
      expect(result.rejectionReason, "This source doesn't allow offline caching.");
    });

    test('Spotify tracks are strictly rejected from caching with exact UI message', () {
      final spotifyTrack = Track(
        id: 'sp_track_1',
        providerId: 'spotify',
        providerTrackId: '4cOdK2wGLETKBW3PvgPWqT',
        title: 'Starboy',
        artist: 'The Weeknd',
        album: 'Starboy',
        duration: const Duration(seconds: 230),
        artworkUri: 'https://i.scdn.co/image/abc',
        dateAdded: DateTime.now(),
      );

      final result = coordinator.checkEligibility(spotifyTrack);

      expect(result.isEligible, false);
      expect(result.state, CacheState.notSupportedBySource);
      expect(result.rejectionReason, CacheMessages.notSupportedBySource);
    });

    test('Local files owned by user are never copied into a redundant second cache', () {
      final localTrack = Track(
        id: 'local_track_1',
        providerId: 'local',
        providerTrackId: '/storage/emulated/0/Music/track.mp3',
        title: 'Local Song',
        artist: 'Local Artist',
        album: 'Local Album',
        duration: const Duration(seconds: 180),
        artworkUri: 'assets/images/cover_zenith.jpg',
        dateAdded: DateTime.now(),
      );

      final result = coordinator.checkEligibility(localTrack);

      expect(result.isLocalOwned, true);
      expect(result.isEligible, false);
      expect(result.state, CacheState.availableOffline);
    });

    test('Restricted providers with cachingPermission == false are rejected', () {
      final restrictedTrack = Track(
        id: 'restricted_1',
        providerId: 'restricted_provider',
        providerTrackId: 'track_res_1',
        title: 'Protected Track',
        artist: 'Protected Artist',
        album: 'Album',
        duration: const Duration(seconds: 120),
        artworkUri: '',
        dateAdded: DateTime.now(),
      );

      final result = coordinator.checkEligibility(restrictedTrack);

      expect(result.isEligible, false);
      expect(result.state, CacheState.notSupportedBySource);
      expect(result.rejectionReason, CacheMessages.notSupportedBySource);
    });

    test('Authorized eligible provider tracks are accepted for caching', () {
      final eligibleTrack = Track(
        id: 'cachable_1',
        providerId: 'cachable_provider',
        providerTrackId: 'track_safe_1',
        title: 'Free Audio',
        artist: 'Safe Artist',
        album: 'Album',
        duration: const Duration(seconds: 120),
        artworkUri: '',
        dateAdded: DateTime.now(),
      );

      final result = coordinator.checkEligibility(eligibleTrack);

      expect(result.isEligible, true);
      expect(result.state, CacheState.eligible);
    });
  });

  group('2. Toggle Behavior & Retention Tests', () {
    test('Turning offline caching OFF preserves existing cached files without deleting them', () async {
      final track = Track(
        id: 'song_1', // Seeded in database
        providerId: 'cachable_provider',
        providerTrackId: 'stream_1',
        title: 'Zenith',
        artist: 'Kenshi Yonezu',
        album: 'Kenshi Album',
        duration: const Duration(seconds: 240),
        artworkUri: 'assets/images/cover_zenith.jpg',
        dateAdded: DateTime.now(),
      );

      final testBytes = utf8.encode('AUDIO_STREAM_BINARY_DATA_TEST_BYTES');
      final hash = sha256.convert(testBytes).toString();

      final res = await coordinator.requestCacheTrack(
        track: track,
        byteStreamProvider: () => Stream.value(testBytes),
        expectedSize: testBytes.length,
        sha256Hash: hash,
      );

      expect(res.isSuccess, true);
      final entry = res.dataOrNull!;
      expect(File(entry.filePath).existsSync(), true);

      // Disable offline caching
      await coordinator.onOfflineCachingToggled(false);

      // Verify cached files remain intact
      expect(File(entry.filePath).existsSync(), true);
      final retrieved = await cacheManager.getCacheEntry(track.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.downloadState, CacheState.availableOffline);
    });

    test('When offline caching is disabled, new download requests are rejected', () async {
      await coordinator.onOfflineCachingToggled(false);

      final track = Track(
        id: 'song_2',
        providerId: 'cachable_provider',
        providerTrackId: 'stream_2',
        title: 'Afterglow',
        artist: 'Luna Caine',
        album: 'Afterglow Album',
        duration: const Duration(seconds: 249),
        artworkUri: 'assets/images/cover_afterglow.jpg',
        dateAdded: DateTime.now(),
      );

      final res = await coordinator.requestCacheTrack(
        track: track,
        byteStreamProvider: () => Stream.value([1, 2, 3]),
      );

      expect(res.isFailure, true);
      expect(res.errorOrNull, CacheMessages.cachingDisabled);
      expect(res.errorOrNull, 'Offline caching is disabled.');
    });

    test('Cancelling download cleans up temporary file and leaves database consistent', () async {
      final track = Track(
        id: 'song_cancel',
        providerId: 'cachable_provider',
        providerTrackId: 'stream_cancel',
        title: 'Cancelling Track',
        artist: 'Artist',
        album: 'Album',
        duration: const Duration(seconds: 100),
        artworkUri: '',
        dateAdded: DateTime.now(),
      );

      final controller = StreamController<List<int>>();

      final downloadFuture = cacheManager.cacheTrack(
        track: track,
        byteStreamProvider: () => controller.stream,
      );

      // Push initial chunk
      controller.add([1, 2, 3, 4]);
      await pumpEventQueue();

      // Cancel transfer
      await cacheManager.cancelDownload(track.id);

      final result = await downloadFuture;
      expect(result, isNull);

      await controller.close();

      // Verify no orphaned .tmp files remain
      final files = tempCacheDir.listSync();
      expect(files.isEmpty, true);

      final entry = await cacheManager.getCacheEntry(track.id);
      expect(entry, isNull);
    });
  });

  group('3. 10 Explicit Cache States & Messages', () {
    test('All 10 cache states map to exact specified messages and display names', () {
      expect(CacheState.notCached.displayName, 'Not Cached');
      expect(CacheState.notCached.statusMessage, CacheMessages.notCached);

      expect(CacheState.eligible.displayName, 'Eligible');

      expect(CacheState.waiting.displayName, 'Waiting');

      expect(CacheState.downloading.displayName, 'Downloading');

      expect(CacheState.availableOffline.displayName, 'Available offline');
      expect(CacheState.availableOffline.statusMessage, CacheMessages.availableOffline);
      expect(CacheState.availableOffline.isPlayableOffline, true);

      expect(CacheState.failed.displayName, 'Download Failed');
      expect(CacheState.failed.statusMessage, CacheMessages.cachingFailed);

      expect(CacheState.corrupted.displayName, 'Corrupted');
      expect(CacheState.corrupted.statusMessage, CacheMessages.cachingFailed);

      expect(CacheState.expired.displayName, 'Expired');
      expect(CacheState.expired.statusMessage, CacheMessages.notCached);

      expect(CacheState.notSupportedBySource.displayName, 'Not Supported');
      expect(CacheState.notSupportedBySource.statusMessage, CacheMessages.notSupportedBySource);

      expect(CacheState.removedFromCache.displayName, 'Removed');
      expect(CacheState.removedFromCache.statusMessage, CacheMessages.notCached);
    });

    test('watchTrackCacheState streams download progress states', () async {
      final track = Track(
        id: 'song_stream_states',
        providerId: 'cachable_provider',
        providerTrackId: 'stream_states',
        title: 'State Test Track',
        artist: 'Artist',
        album: 'Album',
        duration: const Duration(seconds: 120),
        artworkUri: '',
        dateAdded: DateTime.now(),
      );

      final statesEmitted = <CacheState>[];
      final sub = cacheManager.watchTrackCacheState(track.id).listen((s) {
        statesEmitted.add(s);
      });

      final testBytes = utf8.encode('TEST_AUDIO_BYTES');
      await cacheManager.cacheTrack(
        track: track,
        byteStreamProvider: () => Stream.value(testBytes),
      );

      await pumpEventQueue();
      await sub.cancel();

      expect(statesEmitted.contains(CacheState.downloading), true);
      expect(statesEmitted.contains(CacheState.availableOffline), true);
    });
  });

  group('4. Storage, Temporary Files & Integrity Verification Tests', () {
    test('Promotes temporary file only upon valid checksum and size completion', () async {
      final track = Track(
        id: 'song_integrity_1',
        providerId: 'cachable_provider',
        providerTrackId: 'str_int_1',
        title: 'Integrity Song',
        artist: 'Artist',
        album: 'Album',
        duration: const Duration(seconds: 150),
        artworkUri: '',
        dateAdded: DateTime.now(),
      );

      final data = utf8.encode('VALID_AUDIO_CHECKSUM_TEST_PAYLOAD');
      final expectedSha = sha256.convert(data).toString();

      final entry = await cacheManager.cacheTrack(
        track: track,
        byteStreamProvider: () => Stream.value(data),
        expectedSize: data.length,
        sha256Hash: expectedSha,
      );

      expect(entry, isNotNull);
      expect(File(entry!.filePath).existsSync(), true);

      final isValid = await cacheManager.verifyIntegrity(track.id);
      expect(isValid, true);
    });

    test('Integrity check detects size tampering, deletes corrupt file and reconciles DB', () async {
      final track = Track(
        id: 'song_tamper_size',
        providerId: 'cachable_provider',
        providerTrackId: 'str_tamper_1',
        title: 'Tampered Song Size',
        artist: 'Artist',
        album: 'Album',
        duration: const Duration(seconds: 150),
        artworkUri: '',
        dateAdded: DateTime.now(),
      );

      final data = utf8.encode('FULL_AUDIO_PAYLOAD_STRING');
      final entry = await cacheManager.cacheTrack(
        track: track,
        byteStreamProvider: () => Stream.value(data),
        expectedSize: data.length,
      );

      expect(entry, isNotNull);

      // Simulate partial or corrupt truncation
      await File(entry!.filePath).writeAsBytes(utf8.encode('TRUNCATED'));

      final isValid = await cacheManager.verifyIntegrity(track.id);
      expect(isValid, false);

      // Verify file was deleted and DB entry cleaned
      expect(File(entry.filePath).existsSync(), false);
      final dbEntry = await cacheManager.getCacheEntry(track.id);
      expect(dbEntry, isNull);
    });

    test('Integrity check detects hash mismatch, deletes corrupt file and reconciles DB', () async {
      final track = Track(
        id: 'song_tamper_hash',
        providerId: 'cachable_provider',
        providerTrackId: 'str_tamper_2',
        title: 'Tampered Song Hash',
        artist: 'Artist',
        album: 'Album',
        duration: const Duration(seconds: 150),
        artworkUri: '',
        dateAdded: DateTime.now(),
      );

      final data = utf8.encode('FULL_AUTHENTIC_AUDIO_BYTES');
      final originalHash = sha256.convert(data).toString();

      final entry = await cacheManager.cacheTrack(
        track: track,
        byteStreamProvider: () => Stream.value(data),
        expectedSize: data.length,
        sha256Hash: originalHash,
      );

      expect(entry, isNotNull);

      // Tamper content with same length
      final tamperedBytes = utf8.encode('XULL_AUTHENTIC_AUDIO_BYTES');
      await File(entry!.filePath).writeAsBytes(tamperedBytes);

      final isValid = await cacheManager.verifyIntegrity(track.id);
      expect(isValid, false);

      expect(File(entry.filePath).existsSync(), false);
      final dbEntry = await cacheManager.getCacheEntry(track.id);
      expect(dbEntry, isNull);
    });
  });

  group('5. Storage Limits, LRU Eviction & Active Playback Protection', () {
    test('LRU eviction evicts least-recently-accessed tracks when limit is exceeded', () async {
      // Set small cache limit of 100 bytes
      coordinator.maxCacheSizeBytes = 100;

      final trackA = Track(
        id: 'track_A',
        providerId: 'cachable_provider',
        providerTrackId: 'A',
        title: 'Track A',
        artist: 'Artist A',
        album: 'Album',
        duration: const Duration(seconds: 60),
        artworkUri: '',
        dateAdded: DateTime.now(),
      );

      final trackB = Track(
        id: 'track_B',
        providerId: 'cachable_provider',
        providerTrackId: 'B',
        title: 'Track B',
        artist: 'Artist B',
        album: 'Album',
        duration: const Duration(seconds: 60),
        artworkUri: '',
        dateAdded: DateTime.now(),
      );

      final trackC = Track(
        id: 'track_C',
        providerId: 'cachable_provider',
        providerTrackId: 'C',
        title: 'Track C',
        artist: 'Artist C',
        album: 'Album',
        duration: const Duration(seconds: 60),
        artworkUri: '',
        dateAdded: DateTime.now(),
      );

      // Cache A (50 bytes) at t1
      final bytes50 = List.filled(50, 1);
      await coordinator.requestCacheTrack(
        track: trackA,
        byteStreamProvider: () => Stream.value(bytes50),
        expectedSize: 50,
      );

      await Future.delayed(const Duration(milliseconds: 15));

      // Cache B (50 bytes) at t2
      await coordinator.requestCacheTrack(
        track: trackB,
        byteStreamProvider: () => Stream.value(bytes50),
        expectedSize: 50,
      );

      // Total size now = 100 bytes (limit reached)
      expect(await cacheManager.calculateTotalCacheSize(), 100);

      await Future.delayed(const Duration(milliseconds: 15));

      // Access A in the future so B is strictly the oldest in Unix seconds
      await cacheManager.markAccessed(
        trackA.id,
        DateTime.now().add(const Duration(hours: 1)),
      );

      await Future.delayed(const Duration(milliseconds: 15));

      // Cache C (50 bytes) -> must evict B (oldest)
      await coordinator.requestCacheTrack(
        track: trackC,
        byteStreamProvider: () => Stream.value(bytes50),
        expectedSize: 50,
      );

      // Track B was evicted
      expect(await cacheManager.getCacheEntry(trackB.id), isNull);
      // Track A and Track C remain
      expect(await cacheManager.getCacheEntry(trackA.id), isNotNull);
      expect(await cacheManager.getCacheEntry(trackC.id), isNotNull);
    });

    test('Actively playing track is NEVER evicted even if it is the oldest', () async {
      String? activePlayingId = 'track_active_protected';

      final protectedCoordinator = CachingCoordinator(
        cacheManager: cacheManager,
        providerRegistry: registry,
        settingsRepository: settingsRepo,
        trackRepository: trackRepo,
        getActivePlayingTrackId: () => activePlayingId,
        maxCacheSizeBytes: 100,
      );

      final trackActive = Track(
        id: 'track_active_protected',
        providerId: 'cachable_provider',
        providerTrackId: 'act',
        title: 'Active Track',
        artist: 'Artist Active',
        album: 'Album',
        duration: const Duration(seconds: 60),
        artworkUri: '',
        dateAdded: DateTime.now(),
      );

      final trackOther = Track(
        id: 'track_other',
        providerId: 'cachable_provider',
        providerTrackId: 'oth',
        title: 'Other Track',
        artist: 'Artist Other',
        album: 'Album',
        duration: const Duration(seconds: 60),
        artworkUri: '',
        dateAdded: DateTime.now(),
      );

      final trackNew = Track(
        id: 'track_new',
        providerId: 'cachable_provider',
        providerTrackId: 'new',
        title: 'New Track',
        artist: 'Artist New',
        album: 'Album',
        duration: const Duration(seconds: 60),
        artworkUri: '',
        dateAdded: DateTime.now(),
      );

      final bytes50 = List.filled(50, 2);

      // Cache active track first (oldest)
      await protectedCoordinator.requestCacheTrack(
        track: trackActive,
        byteStreamProvider: () => Stream.value(bytes50),
        expectedSize: 50,
      );

      await Future.delayed(const Duration(milliseconds: 15));

      // Cache other track
      await protectedCoordinator.requestCacheTrack(
        track: trackOther,
        byteStreamProvider: () => Stream.value(bytes50),
        expectedSize: 50,
      );

      await Future.delayed(const Duration(milliseconds: 15));

      // Now cache new track (needs 50 bytes)
      // Normal LRU would evict trackActive (oldest), but active protection ensures trackOther is evicted instead!
      await protectedCoordinator.requestCacheTrack(
        track: trackNew,
        byteStreamProvider: () => Stream.value(bytes50),
        expectedSize: 50,
      );

      // Verify active track is protected and NOT evicted
      expect(await cacheManager.getCacheEntry(trackActive.id), isNotNull);
      // Track other was evicted
      expect(await cacheManager.getCacheEntry(trackOther.id), isNull);
      // Track new was cached
      expect(await cacheManager.getCacheEntry(trackNew.id), isNotNull);
    });
  });

  group('6. Clear Cache Action & Confirmation Semantics', () {
    test('When user declines confirmation, clear cache returns "No changes made" with 0 data removed', () async {
      final track = Track(
        id: 'song_declined',
        providerId: 'cachable_provider',
        providerTrackId: 'declined',
        title: 'Keep Me',
        artist: 'Artist',
        album: 'Album',
        duration: const Duration(seconds: 60),
        artworkUri: '',
        dateAdded: DateTime.now(),
      );

      await coordinator.requestCacheTrack(
        track: track,
        byteStreamProvider: () => Stream.value([10, 20, 30, 40]),
        expectedSize: 4,
      );

      final msg = await coordinator.executeClearCache(userConfirmed: false);

      expect(msg, CacheMessages.noChangesMade);
      expect(msg, 'No changes made');
      expect(await cacheManager.getCacheEntry(track.id), isNotNull);
    });

    test('When user confirms, cache is cleared, records reconciled, and returns "Cache cleared"', () async {
      final track = Track(
        id: 'song_confirmed_clear',
        providerId: 'cachable_provider',
        providerTrackId: 'clear_me',
        title: 'Clear Me',
        artist: 'Artist',
        album: 'Album',
        duration: const Duration(seconds: 60),
        artworkUri: '',
        dateAdded: DateTime.now(),
      );

      await coordinator.requestCacheTrack(
        track: track,
        byteStreamProvider: () => Stream.value([1, 2, 3, 4, 5, 6]),
        expectedSize: 6,
      );

      expect(await cacheManager.calculateTotalCacheSize(), greaterThan(0));

      final msg = await coordinator.executeClearCache(userConfirmed: true);

      expect(msg, CacheMessages.cacheCleared);
      expect(msg, 'Cache cleared');
      expect(await cacheManager.calculateTotalCacheSize(), 0);
      expect(await cacheManager.getCacheEntry(track.id), isNull);

      // Verify library database metadata is intact
      final allTracks = await trackRepo.getAllTracks();
      expect(allTracks.isSuccess, true);
      expect(allTracks.dataOrNull!.isNotEmpty, true);
    });

    test('Storage size formatting matches Japanese Ink UI design specifications', () {
      expect(CachingCoordinator.formatStorageSize(0), '0 MB');
      expect(CachingCoordinator.formatStorageSize(500), '500 B');
      expect(CachingCoordinator.formatStorageSize(1024 * 320), '320 KB');
      expect(CachingCoordinator.formatStorageSize(1024 * 1024 * 45), '45 MB');
      expect(CachingCoordinator.formatStorageSize(1.2 * 1024 * 1024 * 1024), '1.2 GB');
    });
  });

  group('7. TrackResolver Offline Playback Integration', () {
    test('Resolver resolves directly from verified local cache file when available', () async {
      final track = Track(
        id: 'track_cached_playback',
        providerId: 'cachable_provider',
        providerTrackId: 'playback_stream',
        title: 'Cached Playback',
        artist: 'Artist',
        album: 'Album',
        duration: const Duration(seconds: 120),
        artworkUri: '',
        dateAdded: DateTime.now(),
      );

      final data = utf8.encode('PLAYABLE_CACHED_STREAM_BYTES');
      final entry = await cacheManager.cacheTrack(
        track: track,
        byteStreamProvider: () => Stream.value(data),
        expectedSize: data.length,
      );

      expect(entry, isNotNull);

      final resolver = TrackResolver(
        providerRegistry: registry,
        trackRepository: trackRepo,
        cacheManager: cacheManager,
      );

      final result = await resolver.resolve(track);

      expect(result.isSuccess, true);
      final source = result.dataOrNull!;
      expect(source.isLocal, true);
      expect(source.uri.scheme, 'file');
      expect(source.uri.toFilePath(), entry!.filePath);
    });

    test('When remote provider is offline and track is uncached, fails with exact UI message', () async {
      cachableProvider.isOperational = false; // Source is offline

      final uncachedTrack = Track(
        id: 'uncached_offline_track',
        providerId: 'cachable_provider',
        providerTrackId: 'stream_offline',
        title: 'Offline Song',
        artist: 'Artist',
        album: 'Album',
        duration: const Duration(seconds: 120),
        artworkUri: '',
        dateAdded: DateTime.now(),
      );

      final resolver = TrackResolver(
        providerRegistry: registry,
        trackRepository: trackRepo,
        cacheManager: cacheManager,
      );

      final result = await resolver.resolve(uncachedTrack);

      expect(result.isFailure, true);
      final failure = result.errorOrNull!;
      expect(failure.type, PlaybackFailureType.notCachedForOffline);
      expect(failure.userMessage, CacheMessages.notCached);
      expect(failure.userMessage, "This track isn't cached for offline playback.");
    });
  });
}
