import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:uuid/uuid.dart';

import 'theme/cavia_theme.dart';
import '../core/config/cavia_config.dart';
import '../core/data/database/cavia_database.dart';
import '../core/data/repositories/local_track_repository.dart';
import '../core/data/repositories/local_playlist_repository.dart';
import '../core/data/repositories/local_queue_repository.dart';
import '../core/data/repositories/local_settings_repository.dart';
import '../core/data/repositories/local_search_repository.dart';
import '../core/data/repositories/local_sync_repository.dart';
import '../core/data/repositories/supabase_auth_repository.dart';
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
  final String? deviceId;

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
    this.deviceId,
  });

  /// True once [create] completed a Supabase initialization in this process.
  static bool supabaseReady = false;

  /// Async production bootstrap: opens the real database, restores/creates the
  /// stable device id, initializes Supabase when configured, and prepares the
  /// audio handler. Runs once from `main()`; tests construct [CaviaApp] by
  /// injecting their own dependencies through the plain constructor instead.
  static Future<CaviaApp> create() async {
    if (CaviaConfig.supabaseConfigured) {
      // Re-initialization is a logged no-op in supabase_flutter.
      await sb.Supabase.initialize(
        url: CaviaConfig.supabaseUrl,
        publishableKey: CaviaConfig.supabaseAnonKey,
      );
      supabaseReady = true;
    }

    return CaviaApp(
      audioHandler: await _ensureAudioHandler(),
    );
  }

  /// The OS media session is initialized only when the platform supports it.
  /// On unsupported platforms (e.g. headless CI) an in-process handler keeps
  /// on-device playback functional without claiming OS integration.
  static Future<CaviaAudioHandler> _ensureAudioHandler() async {
    const config = AudioServiceConfig(
      androidNotificationChannelId: 'com.stretchwave.cavia_music.playback',
      androidNotificationChannelName: 'Cavia Music playback',
      androidNotificationOngoing: true,
    );
    try {
      return await AudioService.init(
        builder: () => CaviaAudioHandler(),
        config: config,
      );
    } catch (_) {
      return CaviaAudioHandler();
    }
  }

  @override
  State<CaviaApp> createState() => _CaviaAppState();
}

class _CaviaAppState extends State<CaviaApp> {
  CaviaDatabase? _db;
  bool _ownsDb = false;
  String _deviceId = 'device-local';

  late final PlaybackController _playbackController;
  late final LibraryController _libraryController;
  late final SettingsController _settingsController;

  bool _controllersReady = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // -------------------------------------------------------------------
    // 1. Database (or injected repositories) + stable device identity
    // -------------------------------------------------------------------
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

    if (widget.deviceId != null) {
      _deviceId = widget.deviceId!;
    } else if (db != null) {
      _deviceId = await _resolveDeviceId(db);
    }

    SyncRepository? syncRepo = widget.syncRepository;
    AuthRepository? authRepo = widget.authRepository;
    TrackRepository? trackRepo = widget.trackRepository;
    PlaylistRepository? playlistRepo = widget.playlistRepository;
    QueueRepository? queueRepo = widget.queueRepository;
    SettingsRepository? settingsRepo = widget.settingsRepository;
    SearchRepository? searchRepo = widget.searchRepository;

    if (db != null) {
      final sbClient = CaviaConfig.supabaseConfigured && CaviaApp.supabaseReady
          ? sb.Supabase.instance.client
          : null;

      syncRepo ??= LocalSyncRepository(db: db, client: sbClient, deviceId: _deviceId);
      authRepo ??= SupabaseAuthRepository(client: sbClient);
      trackRepo ??= LocalTrackRepository(db, syncRepository: syncRepo, deviceId: _deviceId);
      playlistRepo ??= LocalPlaylistRepository(db, syncRepository: syncRepo, deviceId: _deviceId);
      queueRepo ??= LocalQueueRepository(db);
      settingsRepo ??= LocalSettingsRepository(db, syncRepository: syncRepo, deviceId: _deviceId);
      searchRepo ??= LocalSearchRepository(db);
    }

    // -------------------------------------------------------------------
    // 2. Providers, coordinator, resolver
    // -------------------------------------------------------------------
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
        getActivePlayingTrackId: () => _playbackController.currentSong?.id,
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

    // -------------------------------------------------------------------
    // 3. Controllers
    // -------------------------------------------------------------------
    _playbackController = PlaybackController(
      audioEngine: widget.audioEngine,
      trackResolver: resolver,
      queueRepository: queueRepo,
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
      providerRegistry: providerRegistry,
    );

    // Restore an existing Supabase session when one is stored.
    await authRepo?.restoreSession();

    if (mounted) {
      setState(() => _controllersReady = true);
    }
  }

  Future<String> _resolveDeviceId(CaviaDatabase db) async {
    final row = await (db.select(db.dbPreferences)
          ..where((t) => t.key.equals('deviceId')))
        .getSingleOrNull();
    if (row != null && row.value.isNotEmpty) return row.value;

    final id = const Uuid().v4();
    await db.into(db.dbPreferences).insertOnConflictUpdate(
          DbPreferencesCompanion.insert(
            key: 'deviceId',
            value: id,
            updatedAt: DateTime.timestamp(),
          ),
        );
    return id;
  }

  @override
  void dispose() {
    if (_controllersReady) {
      _playbackController.dispose();
      _libraryController.dispose();
      _settingsController.dispose();
    }
    if (_ownsDb) {
      _db?.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controllersReady) {
      return const MaterialApp(
        title: 'Cavia Music',
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

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
