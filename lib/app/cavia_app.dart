import 'package:flutter/material.dart';
import 'theme/cavia_theme.dart';
import '../core/data/database/cavia_database.dart';
import '../core/data/repositories/local_track_repository.dart';
import '../core/data/repositories/local_playlist_repository.dart';
import '../core/data/repositories/local_queue_repository.dart';
import '../core/data/repositories/local_settings_repository.dart';
import '../core/data/repositories/local_search_repository.dart';
import '../core/data/repositories/local_sync_repository.dart';
import '../core/data/repositories/supabase_auth_repository.dart';
import '../core/data/seeds/initial_data_seeder.dart';
import '../core/domain/repositories/track_repository.dart';
import '../core/domain/repositories/playlist_repository.dart';
import '../core/domain/repositories/queue_repository.dart';
import '../core/domain/repositories/settings_repository.dart';
import '../core/domain/repositories/search_repository.dart';
import '../core/domain/repositories/auth_repository.dart';
import '../core/domain/repositories/sync_repository.dart';
import '../core/playback/audio_engine.dart';
import '../core/playback/track_resolver.dart';
import '../core/playback/cavia_audio_handler.dart';
import '../core/providers/provider_registry.dart';
import '../core/providers/local_audio_provider.dart';
import '../core/providers/youtube_provider.dart';
import '../core/providers/innertube_audio_provider.dart';
import '../core/providers/spotify_metadata_provider.dart';
import '../core/storage/cache_manager.dart';
import '../core/storage/local_cache_manager.dart';
import '../core/storage/caching_coordinator.dart';
import '../core/state/playback_controller.dart';
import '../core/state/library_controller.dart';
import '../core/state/settings_controller.dart';
import '../core/state/app_state_scope.dart';
import '../features/shell/main_scaffold.dart';

class CaviaApp extends StatefulWidget {
  final CaviaDatabase? database;
  final TrackRepository? trackRepository;
  final PlaylistRepository? playlistRepository;
  final QueueRepository? queueRepository;
  final SettingsRepository? settingsRepository;
  final SearchRepository? searchRepository;
  final AuthRepository? authRepository;
  final SyncRepository? syncRepository;
  final AudioEngine? audioEngine;
  final TrackResolver? trackResolver;
  final CaviaAudioHandler? audioHandler;

  const CaviaApp({
    super.key,
    this.database,
    this.trackRepository,
    this.playlistRepository,
    this.queueRepository,
    this.settingsRepository,
    this.searchRepository,
    this.authRepository,
    this.syncRepository,
    this.audioEngine,
    this.trackResolver,
    this.audioHandler,
  });

  @override
  State<CaviaApp> createState() => _CaviaAppState();
}

class _CaviaAppState extends State<CaviaApp> {
  CaviaDatabase? _db;
  bool _ownsDb = false;

  late final PlaybackController _playbackController;
  late final LibraryController _libraryController;
  late final SettingsController _settingsController;

  @override
  void initState() {
    super.initState();

    CaviaDatabase? db = widget.database;
    if (db == null &&
        widget.trackRepository == null &&
        widget.playlistRepository == null &&
        widget.queueRepository == null &&
        widget.settingsRepository == null &&
        widget.searchRepository == null &&
        widget.authRepository == null &&
        widget.syncRepository == null) {
      db = CaviaDatabase();
      _ownsDb = true;
    }
    _db = db;

    SyncRepository? syncRepo = widget.syncRepository;
    AuthRepository? authRepo = widget.authRepository;
    TrackRepository? trackRepo = widget.trackRepository;
    PlaylistRepository? playlistRepo = widget.playlistRepository;
    QueueRepository? queueRepo = widget.queueRepository;
    SettingsRepository? settingsRepo = widget.settingsRepository;
    SearchRepository? searchRepo = widget.searchRepository;

    if (db != null) {
      syncRepo ??= LocalSyncRepository(db: db);
      authRepo ??= SupabaseAuthRepository();
      trackRepo ??= LocalTrackRepository(db, syncRepository: syncRepo);
      playlistRepo ??= LocalPlaylistRepository(db, syncRepository: syncRepo);
      queueRepo ??= LocalQueueRepository(db);
      settingsRepo ??= LocalSettingsRepository(db, syncRepository: syncRepo);
      searchRepo ??= LocalSearchRepository(db);

      InitialDataSeeder(db).seedIfNeeded();
      authRepo.restoreSession();
    }

    final providerRegistry = ProviderRegistry(
      initialProviders: [
        if (trackRepo != null) LocalAudioProvider(trackRepository: trackRepo),
        YouTubeMusicProvider(),
        InnerTubeAudioProvider(),
        SpotifyMetadataProvider(),
      ],
    );

    CacheManager? cacheMgr;
    CachingCoordinator? cachingCoord;
    if (db != null) {
      cacheMgr = LocalCacheManager(db: db);
      cachingCoord = CachingCoordinator(
        cacheManager: cacheMgr,
        providerRegistry: providerRegistry,
        settingsRepository: settingsRepo,
        trackRepository: trackRepo,
        getActivePlayingTrackId: () => _playbackController.currentSong.id,
      );
    }

    final resolver = widget.trackResolver ??
        (trackRepo != null
            ? TrackResolver(
                providerRegistry: providerRegistry,
                trackRepository: trackRepo,
                cacheManager: cacheMgr,
              )
            : null);

    _playbackController = PlaybackController(
      audioEngine: widget.audioEngine,
      trackResolver: resolver,
      queueRepository: queueRepo,
      trackRepository: trackRepo,
      audioHandler: widget.audioHandler,
    );

    _libraryController = LibraryController(
      trackRepository: trackRepo,
      playlistRepository: playlistRepo,
      searchRepository: searchRepo,
    );

    _settingsController = SettingsController(
      repository: settingsRepo,
      authRepository: authRepo,
      syncRepository: syncRepo,
      cacheManager: cacheMgr,
      cachingCoordinator: cachingCoord,
    );
  }

  @override
  void dispose() {
    _playbackController.dispose();
    _libraryController.dispose();
    _settingsController.dispose();
    if (_ownsDb) {
      _db?.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      playback: _playbackController,
      library: _libraryController,
      settings: _settingsController,
      child: MaterialApp(
        title: 'Cavia Music',
        debugShowCheckedModeBanner: false,
        theme: CaviaTheme.darkTheme,
        home: const MainScaffold(),
      ),
    );
  }
}
