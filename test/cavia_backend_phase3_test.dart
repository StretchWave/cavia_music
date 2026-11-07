import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:cavia_music/core/domain/models/track.dart';
import 'package:cavia_music/core/mock_data/mock_library.dart';
import 'package:cavia_music/core/providers/provider_registry.dart';
import 'package:cavia_music/core/providers/local_audio_provider.dart';
import 'package:cavia_music/core/providers/youtube_provider.dart';
import 'package:cavia_music/core/providers/spotify_metadata_provider.dart';
import 'package:cavia_music/core/playback/playback_source.dart';
import 'helpers/mock_audio_engine.dart';
import 'package:cavia_music/core/playback/track_resolver.dart';
import 'package:cavia_music/core/playback/queue_manager.dart';
import 'package:cavia_music/core/playback/cavia_audio_handler.dart';
import 'package:cavia_music/core/search/search_service.dart';
import 'package:cavia_music/core/state/playback_controller.dart';
import 'package:cavia_music/core/data/database/cavia_database.dart';
import 'package:cavia_music/core/data/repositories/local_track_repository.dart';
import 'package:cavia_music/core/data/repositories/local_search_repository.dart';
import 'package:cavia_music/core/data/seeds/initial_data_seeder.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CaviaDatabase db;
  late LocalTrackRepository trackRepo;
  late LocalSearchRepository searchRepo;
  late ProviderRegistry registry;
  late TrackResolver resolver;
  late MockAudioEngine mockEngine;

  setUp(() async {
    db = CaviaDatabase.forTesting(NativeDatabase.memory());
    await InitialDataSeeder(db).seedIfNeeded();
    trackRepo = LocalTrackRepository(db);
    searchRepo = LocalSearchRepository(db);

    registry = ProviderRegistry(
      initialProviders: [
        LocalAudioProvider(trackRepository: trackRepo),
        YouTubeMusicProvider(),
        SpotifyMetadataProvider(),
      ],
    );

    resolver = TrackResolver(
      providerRegistry: registry,
      trackRepository: trackRepo,
    );

    mockEngine = MockAudioEngine();
  });

  tearDown(() async {
    await mockEngine.dispose();
    await db.close();
  });

  group('Provider Abstraction & Policy Compliance Tests', () {
    test('Every provider explicitly declares capabilities', () {
      final local = registry.getProvider('local')!;
      expect(local.capabilities.playbackSupport, true);
      expect(local.capabilities.backgroundPlaybackSupport, true);
      expect(local.capabilities.cachingPermission, true);
      expect(local.capabilities.offlineAvailability, true);

      final yt = registry.getProvider('youtube')!;
      expect(yt.capabilities.searchSupport, true);
      expect(yt.capabilities.metadataSupport, true);
      // Strictly forbidden for YouTube under specification rules
      expect(yt.capabilities.playbackSupport, false);
      expect(yt.capabilities.backgroundPlaybackSupport, false);
      expect(yt.capabilities.cachingPermission, false);
      expect(yt.capabilities.offlineAvailability, false);

      final spotify = registry.getProvider('spotify')!;
      expect(spotify.capabilities.playbackSupport, false);
      expect(spotify.capabilities.cachingPermission, false);
      expect(spotify.capabilities.authenticationRequired, true);
    });

    test('Registry filters providers by operational capabilities', () {
      expect(registry.allProviders.length, 3);
      expect(registry.playbackProviders.length, 1); // only local supports audio-only
      expect(registry.playbackProviders.first.id, 'local');
      expect(registry.searchProviders.length, 3);
    });

    test('Resolving YouTube track rejects audio extraction with exact UI message', () async {
      final ytTrack = Track(
        id: 'yt_sample_1',
        providerId: 'youtube',
        providerTrackId: 'dQw4w9WgXcQ',
        title: 'Rick Astley - Never Gonna Give You Up',
        artist: 'Rick Astley',
        album: 'Whenever You Need Somebody',
        duration: const Duration(minutes: 3, seconds: 32),
        artworkAsset: 'assets/images/cover_afterglow.jpg',
        sourceAttribution: 'YouTube Music',
        dateAdded: DateTime.now(),
      );

      final result = await resolver.resolve(ytTrack);
      expect(result.isFailure, true);
      final error = result.errorOrNull!;
      expect(error.type, PlaybackFailureType.playbackUnsupported);
      // Exact UI string check from specification table
      expect(error.userMessage, "Playback isn't supported for this source.");
    });
  });

  group('Playback State Machine & Audio Engine Tests', () {
    test('MockAudioEngine handles loading, buffering, playing, pausing, and seeking', () async {
      final source = PlaybackSource.asset(trackId: 'song_1', assetPath: 'assets/images/cover_afterglow.jpg');
      await mockEngine.load(source);
      expect(mockEngine.currentState, PlaybackMachineState.paused);

      await mockEngine.play();
      expect(mockEngine.currentState, PlaybackMachineState.playing);

      await mockEngine.seek(const Duration(seconds: 45));
      expect(mockEngine.currentPosition, const Duration(seconds: 45));

      await mockEngine.pause();
      expect(mockEngine.currentState, PlaybackMachineState.paused);

      await mockEngine.stop();
      expect(mockEngine.currentState, PlaybackMachineState.idle);
      expect(mockEngine.currentPosition, Duration.zero);
    });

    test('Audio focus loss transitions state to interrupted', () async {
      final source = PlaybackSource.asset(trackId: 'song_1', assetPath: 'assets/images/cover_afterglow.jpg');
      await mockEngine.load(source);
      await mockEngine.play();
      expect(mockEngine.currentState, PlaybackMachineState.playing);

      mockEngine.simulateInterruption();
      expect(mockEngine.currentState, PlaybackMachineState.interrupted);
    });
  });

  group('Playback Coordinator Rapid Input & Request Superseding Tests', () {
    test('Rapid track selection supersedes in-flight requests safely', () async {
      final controller = PlaybackController(
        audioEngine: mockEngine,
        trackResolver: resolver,
        trackRepository: trackRepo,
      );

      final songA = MockLibrary.allSongs[0]; // Afterglow
      final songB = MockLibrary.allSongs[1]; // Zenith
      final songC = MockLibrary.allSongs[2]; // Crimson Shrine

      // Rapidly dispatch three play requests in immediate sequence
      controller.playNow(songA);
      controller.playNow(songB);
      controller.playNow(songC);

      // The active current song should immediately track the latest selection
      expect(controller.currentSong?.id, songC.id);

      await Future.delayed(const Duration(milliseconds: 30));
      // Stale earlier requests must NOT overwrite song C
      expect(controller.currentSong?.id, songC.id);

      controller.dispose();
    });

    test('Frontend play button only reflects success when engine reports playing', () async {
      final controller = PlaybackController(
        audioEngine: mockEngine,
        trackResolver: resolver,
        trackRepository: trackRepo,
      );

      controller.pause();
      expect(controller.isPlaying, false);

      controller.play();
      expect(controller.isPlaying, true);

      mockEngine.simulateInterruption();
      await Future.delayed(const Duration(milliseconds: 10));
      // Interrupted state means not playing
      expect(controller.isPlaying, false);
      expect(controller.playbackState, PlaybackMachineState.interrupted);

      controller.dispose();
    });
  });

  group('Queue Manager & Edge Case Tests', () {
    test('Empty queue handles skipNext and skipPrevious safely', () {
      final qm = QueueManager();
      expect(qm.isEmpty, true);
      expect(qm.skipNext(), null);
      expect(qm.skipPrevious(), null);
    });

    test('One-item queue handles boundaries and repeat modes', () {
      final qm = QueueManager(initialSongs: [MockLibrary.allSongs[0]]);
      expect(qm.length, 1);

      // Repeat off: next at end returns null
      expect(qm.repeatMode, CaviaRepeatMode.off);
      expect(qm.skipNext(), null);

      // Repeat all: next at end returns first item
      qm.setRepeatMode(CaviaRepeatMode.all);
      expect(qm.skipNext()?.id, MockLibrary.allSongs[0].id);

      // Repeat one: next returns same track
      qm.setRepeatMode(CaviaRepeatMode.one);
      expect(qm.skipNext()?.id, MockLibrary.allSongs[0].id);
    });

    test('Previous button > 3 seconds seeks to 0:00; <= 3 seconds navigates to previous track', () {
      final qm = QueueManager(initialSongs: MockLibrary.allSongs, initialIndex: 1);

      // Current position is 4 seconds -> seek to start
      final actionAfter4s = qm.determinePreviousAction(const Duration(seconds: 4));
      expect(actionAfter4s, PreviousAction.seekToStart);

      // Current position is 2 seconds -> navigate to previous track
      final actionAt2s = qm.determinePreviousAction(const Duration(seconds: 2));
      expect(actionAt2s, PreviousAction.previousTrack);
      expect(qm.skipPrevious()?.id, MockLibrary.allSongs[0].id);
    });

    test('Shuffle preserves currently playing track at index 0 and restores original order', () {
      final qm = QueueManager(initialSongs: MockLibrary.allSongs, initialIndex: 1);
      final currentBeforeShuffle = qm.currentSong!;

      qm.toggleShuffle();
      expect(qm.isShuffle, true);
      // Current track must remain active at index 0
      expect(qm.currentSong?.id, currentBeforeShuffle.id);
      expect(qm.currentIndex, 0);

      // Unshuffle restores original order
      qm.toggleShuffle();
      expect(qm.isShuffle, false);
      expect(qm.currentSong?.id, currentBeforeShuffle.id);
    });

    test('Adding new item while shuffled maintains active track pointer', () {
      final qm = QueueManager(initialSongs: MockLibrary.allSongs, initialIndex: 0);
      qm.toggleShuffle();

      final newSong = Track(
        id: 'new_song_1',
        title: 'New Shuffled Song',
        artist: 'Artist',
        album: 'Album',
        duration: const Duration(minutes: 3),
        artworkAsset: 'assets/images/cover_afterglow.jpg',
      );

      qm.addToQueue(newSong);
      expect(qm.songs.any((s) => s.id == 'new_song_1'), true);
      expect(qm.currentSong?.id, MockLibrary.allSongs[0].id);
    });

    test('Removing current track while playing advances smoothly to next valid item', () {
      final qm = QueueManager(initialSongs: MockLibrary.allSongs, initialIndex: 0);
      final nextTrackId = qm.songs[1].id;

      qm.removeAt(0);
      expect(qm.currentSong?.id, nextTrackId);
      expect(qm.currentIndex, 0);
    });

    test('Duplicate tracks in queue have unique entry identifiers', () {
      final song = MockLibrary.allSongs[0];
      final qm = QueueManager(initialSongs: [song, song]);
      expect(qm.length, 2);
      expect(qm.entries[0].id != qm.entries[1].id, true);
      expect(qm.entries[0].track.id, qm.entries[1].track.id);
    });
  });

  group('Typed Error Classifications & UI Messages Tests', () {
    test('All 7 failure types match the exact specification messages', () {
      expect(
        const PlaybackFailure(
          type: PlaybackFailureType.networkUnavailable,
          internalMessage: 'err',
        ).userMessage,
        'Connection lost.',
      );

      expect(
        const PlaybackFailure(
          type: PlaybackFailureType.trackUnavailable,
          internalMessage: 'err',
        ).userMessage,
        "This track isn't available.",
      );

      expect(
        const PlaybackFailure(
          type: PlaybackFailureType.playbackUnsupported,
          internalMessage: 'err',
        ).userMessage,
        "Playback isn't supported for this source.",
      );

      expect(
        const PlaybackFailure(
          type: PlaybackFailureType.authenticationExpired,
          internalMessage: 'err',
        ).userMessage,
        'Reconnect this music source to continue.',
      );

      expect(
        const PlaybackFailure(
          type: PlaybackFailureType.requestTimeout,
          internalMessage: 'err',
        ).userMessage,
        "Couldn't start playback. Try again.",
      );

      expect(
        const PlaybackFailure(
          type: PlaybackFailureType.regionRestricted,
          internalMessage: 'err',
        ).userMessage,
        "This track isn't available in your region.",
      );

      expect(
        const PlaybackFailure(
          type: PlaybackFailureType.sourceUnavailable,
          internalMessage: 'err',
        ).userMessage,
        'No playable source was found.',
      );
    });

    test('Tracks are never skipped silently on failure; user is informed via message', () async {
      final controller = PlaybackController(
        audioEngine: mockEngine,
        trackResolver: resolver,
        trackRepository: trackRepo,
      );

      final invalidTrack = Track(
        id: 'yt_unsupported_audio',
        providerId: 'youtube',
        providerTrackId: 'yt_unsupported_audio',
        title: 'Video Only Track',
        artist: 'Unknown',
        album: 'None',
        duration: const Duration(minutes: 3),
        artworkAsset: 'assets/images/cover_afterglow.jpg',
      );

      controller.playNow(invalidTrack);
      await Future.delayed(const Duration(milliseconds: 20));

      expect(controller.playbackState, PlaybackMachineState.failed);
      expect(controller.lastErrorMessage, "Playback isn't supported for this source.");

      controller.dispose();
    });
  });

  group('Search Coordinator & Aggregation Tests', () {
    test('SearchService debounces rapid typing and cancels superseded queries', () async {
      final searchService = SearchService(
        providerRegistry: registry,
        searchRepository: searchRepo,
      );

      // Type "A", then immediately "Af", then "After"
      searchService.debouncedSearch(query: 'A');
      searchService.debouncedSearch(query: 'Af');
      final future = searchService.debouncedSearch(query: 'After');

      final result = await future;
      expect(result.isSuccess, true);
      final response = result.dataOrNull!;
      expect(response.songs.any((s) => s.title.contains('Afterglow')), true);
      expect(response.operationalSources.contains('Local Library'), true);

      // Verify query is logged in search history
      final historyList = await searchRepo.watchSearchHistory().first;
      expect(historyList.contains('After'), true);
    });

    test('Search results strictly exclude discovery, recommendation, or trending feeds', () async {
      final searchService = SearchService(
        providerRegistry: registry,
        searchRepository: searchRepo,
      );

      // Empty query returns empty collections with zero recommendation data
      final res = await searchService.searchImmediate(query: '');
      expect(res.isSuccess, true);
      expect(res.dataOrNull?.isEmpty, true);
      expect(res.dataOrNull?.totalCount, 0);
    });
  });

  group('Media Session Integration Tests', () {
    test('CaviaAudioHandler receives track metadata and propagates media controls', () {
      final handler = CaviaAudioHandler();
      bool playCalled = false;
      bool pauseCalled = false;
      bool nextCalled = false;

      handler.onPlayCallback = () => playCalled = true;
      handler.onPauseCallback = () => pauseCalled = true;
      handler.onSkipNextCallback = () => nextCalled = true;

      handler.updateTrackMetadata(
        id: 'song_1',
        title: 'Afterglow',
        artist: 'Luna Caine',
        album: 'Afterglow EP',
        duration: const Duration(minutes: 4, seconds: 9),
      );

      expect(handler.mediaItem.value?.title, 'Afterglow');
      expect(handler.mediaItem.value?.artist, 'Luna Caine');

      handler.play();
      expect(playCalled, true);

      handler.pause();
      expect(pauseCalled, true);

      handler.skipToNext();
      expect(nextCalled, true);
    });
  });
}
