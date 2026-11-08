import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uuid/uuid.dart';
import 'package:audio_service/audio_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:drift/native.dart';

import 'theme/cavia_theme.dart';
import 'theme/cavia_colors.dart';
import '../core/config/cavia_config.dart';
import '../core/models/music_models.dart';
import '../core/mock_data/mock_library.dart';
import '../core/state/playback_controller.dart';
import '../core/state/library_controller.dart';
import '../core/state/settings_controller.dart';
import '../core/state/app_state_scope.dart';
import '../core/data/database/cavia_database.dart';
import '../core/data/seeds/initial_data_seeder.dart';
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
import '../core/domain/repositories/sync_repository.dart';
import '../core/domain/repositories/auth_repository.dart';
import '../core/domain/result/result.dart';
import '../core/domain/result/app_error.dart';
import '../core/playback/audio_engine.dart';
import '../core/playback/track_resolver.dart';
import '../core/playback/cavia_audio_handler.dart';
import '../core/providers/provider_registry.dart';
import '../core/providers/local_audio_provider.dart';
import '../core/providers/youtube_provider.dart';
import '../core/providers/innertube_audio_provider.dart';
import '../core/providers/spotify_metadata_provider.dart';
import '../core/storage/local_cache_manager.dart';
import '../core/storage/caching_coordinator.dart';
import '../features/shell/main_scaffold.dart';

class _InMemoryTrackRepo implements TrackRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<List<Track>, AppError>> getAllTracks({String? profileId}) async =>
      Result.success(MockLibrary.allSongs);

  @override
  Future<Result<Track, AppError>> getTrackById(String id, {String? profileId}) async {
    final matches = MockLibrary.allSongs.where((s) => s.id == id);
    if (matches.isNotEmpty) return Result.success(matches.first);
    return const Result.failure(NotFoundError('Track not found'));
  }
}

/// Root application widget for Cavia Music.
///
/// Maintains a single [MaterialApp] throughout the app lifecycle, managing
/// the bootstrap sequence, error recovery, dependency wiring, and providing
/// [PlaybackController], [LibraryController], and [SettingsController]
/// to the entire widget tree via [AppStateScope].
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
  final bool autoSeed;

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
    this.autoSeed = false,
  });

  /// Optional factory for production main entry point.
  static Future<void> initializeSupabaseIfConfigured() async {
    if (CaviaConfig.supabaseConfigured) {
      try {
        await sb.Supabase.initialize(
          url: CaviaConfig.supabaseUrl,
          publishableKey: CaviaConfig.supabaseAnonKey,
        );
      } catch (e) {
        debugPrint('[Cavia] Supabase initialization failed (offline mode): $e');
      }
    }
  }

  @override
  State<CaviaApp> createState() => CaviaAppState();
}

class CaviaAppState extends State<CaviaApp> {
  CaviaDatabase? _db;
  bool _ownsDb = false;

  PlaybackController? _playbackController;
  LibraryController? _libraryController;
  SettingsController? _settingsController;

  bool _isInitialized = false;
  Object? _initializationError;
  Future<void>? _bootstrapFuture;

  // Visible getters for regression tests and inspection
  bool get isInitialized => _isInitialized;
  Object? get initializationError => _initializationError;
  PlaybackController? get playbackController => _playbackController;
  LibraryController? get libraryController => _libraryController;
  SettingsController? get settingsController => _settingsController;
  CaviaDatabase? get database => _db;

  @override
  void initState() {
    super.initState();
    _startBootstrap();
  }

  void _startBootstrap() {
    _bootstrapFuture ??= _bootstrapAsync();
  }

  Future<void> _bootstrapAsync() async {
    try {
      // 1. Resolve local database
      CaviaDatabase? db = widget.database;
      if (db == null &&
          widget.trackRepository == null &&
          widget.playlistRepository == null &&
          widget.queueRepository == null &&
          widget.settingsRepository == null &&
          widget.searchRepository == null) {
        db = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')
            ? CaviaDatabase.forTesting(NativeDatabase.memory())
            : CaviaDatabase();
        _ownsDb = true;
      }
      _db = db;

      // Seed initial data if newly created and permitted
      if (db != null && widget.autoSeed) {
        try {
          await InitialDataSeeder(db).seedIfNeeded();
        } catch (e) {
          debugPrint('[Cavia] Seed warning: $e');
        }
      }

      // 2. Resolve stable device identifier
      String deviceId = widget.deviceId ?? 'device-local';
      if (widget.deviceId == null && db != null) {
        deviceId = await _resolveDeviceId(db);
      }

      // 3. Resolve optional cloud client (never blocks offline startup)
      sb.SupabaseClient? sbClient;
      try {
        if (CaviaConfig.supabaseConfigured) {
          sbClient = sb.Supabase.instance.client;
        }
      } catch (_) {}

      // 4. Assemble repositories
      SyncRepository? syncRepo = widget.syncRepository;
      AuthRepository? authRepo = widget.authRepository;
      TrackRepository? trackRepo = widget.trackRepository;
      PlaylistRepository? playlistRepo = widget.playlistRepository;
      QueueRepository? queueRepo = widget.queueRepository;
      SettingsRepository? settingsRepo = widget.settingsRepository;
      SearchRepository? searchRepo = widget.searchRepository;

      if (db != null) {
        syncRepo ??= LocalSyncRepository(db: db, client: sbClient, deviceId: deviceId);
        authRepo ??= SupabaseAuthRepository(client: sbClient);
        trackRepo ??= LocalTrackRepository(db, syncRepository: syncRepo);
        playlistRepo ??= LocalPlaylistRepository(db, syncRepository: syncRepo);
        queueRepo ??= LocalQueueRepository(db);
        settingsRepo ??= LocalSettingsRepository(db, syncRepository: syncRepo, deviceId: deviceId);
        searchRepo ??= LocalSearchRepository(db);
      }

      final effectiveTrackRepo = trackRepo ?? _InMemoryTrackRepo();

      // 5. Restore persisted user session (non-blocking)
      if (authRepo != null) {
        try {
          await authRepo.restoreSession();
        } catch (_) {}
      }

      // 6. Assemble cache manager, coordinator, and provider registry
      final cacheManager = db != null ? LocalCacheManager(db: db) : null;

      final providers = [
        LocalAudioProvider(trackRepository: effectiveTrackRepo),
        YouTubeMusicProvider(),
        InnerTubeAudioProvider(),
        SpotifyMetadataProvider(),
      ];
      final registry = ProviderRegistry(initialProviders: providers);

      final cachingCoordinator = cacheManager != null
          ? CachingCoordinator(
              cacheManager: cacheManager,
              providerRegistry: registry,
              trackRepository: effectiveTrackRepo,
              settingsRepository: settingsRepo,
            )
          : null;

      final resolver = widget.trackResolver ??
          TrackResolver(
            providerRegistry: registry,
            trackRepository: effectiveTrackRepo,
            cacheManager: cacheManager,
          );

      // 7. Resolve Audio Handler
      CaviaAudioHandler? audioHandler = widget.audioHandler;
      if (audioHandler == null && !kIsWeb) {
        audioHandler = await _ensureAudioHandler();
      }

      // 8. Instantiate all three controllers with real dependencies
      _playbackController = PlaybackController(
        audioEngine: widget.audioEngine,
        trackResolver: resolver,
        queueRepository: queueRepo,
        trackRepository: effectiveTrackRepo,
        audioHandler: audioHandler,
      );

      _libraryController = LibraryController(
        trackRepository: trackRepo,
        playlistRepository: playlistRepo,
        searchRepository: searchRepo,
        profileId: authRepo?.currentProfile.id ?? 'guest',
      );

      _settingsController = SettingsController(
        repository: settingsRepo,
        authRepository: authRepo,
        syncRepository: syncRepo,
        cacheManager: cacheManager,
        cachingCoordinator: cachingCoordinator,
        providerRegistry: registry,
      );

      if (!mounted) return;
      setState(() {
        _isInitialized = true;
        _initializationError = null;
      });
    } catch (e, stack) {
      debugPrint('[Cavia] Bootstrap failure: $e\n$stack');
      if (!mounted) return;
      setState(() {
        _initializationError = e;
        _isInitialized = false;
      });
    }
  }

  static Future<CaviaAudioHandler?> _ensureAudioHandler() async {
    try {
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        return null;
      }
      const config = AudioServiceConfig(
        androidNotificationChannelId: 'com.stretchwave.cavia_music.playback',
        androidNotificationChannelName: 'Cavia Music playback',
        androidNotificationOngoing: true,
      );
      return await AudioService.init(
        builder: () => CaviaAudioHandler(),
        config: config,
      );
    } catch (_) {
      return CaviaAudioHandler();
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
            updatedAt: DateTime.now().toUtc(),
          ),
        );
    return id;
  }

  void retryBootstrap() {
    setState(() {
      _initializationError = null;
      _isInitialized = false;
      _bootstrapFuture = null;
    });
    _startBootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cavia Music',
      debugShowCheckedModeBanner: false,
      theme: CaviaTheme.darkTheme,
      home: _buildHome(context),
    );
  }

  Widget _buildHome(BuildContext context) {
    if (_initializationError != null) {
      return _buildErrorScreen(context, _initializationError!);
    }

    if (!_isInitialized ||
        _playbackController == null ||
        _libraryController == null ||
        _settingsController == null) {
      return _buildLoadingScreen(context);
    }

    return AppStateScope(
      playback: _playbackController!,
      library: _libraryController!,
      settings: _settingsController!,
      child: const MainScaffold(),
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: CaviaColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(CaviaColors.vermilion),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '藏',
              style: TextStyle(
                color: CaviaColors.textIvory.withValues(alpha: 0.15),
                fontSize: 48,
                fontWeight: FontWeight.w200,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'CAVIA MUSIC',
              style: TextStyle(
                color: CaviaColors.textIvory,
                fontSize: 16,
                letterSpacing: 4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Loading local library & configuring audio',
              style: TextStyle(
                color: CaviaColors.textDim,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, Object error) {
    return Scaffold(
      backgroundColor: CaviaColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: CaviaColors.vermilionSubtle,
                  border: Border.all(
                    color: CaviaColors.vermilionGlow,
                  ),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: CaviaColors.vermilion,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Initialization Failed',
                style: TextStyle(
                  color: CaviaColors.textIvory,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CaviaColors.textSilver,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              InkWell(
                onTap: retryBootstrap,
                borderRadius: BorderRadius.circular(100),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  decoration: BoxDecoration(
                    color: CaviaColors.glassSurface,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: CaviaColors.glassBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.refresh_rounded, size: 18, color: CaviaColors.textIvory),
                      SizedBox(width: 8),
                      Text(
                        'Retry',
                        style: TextStyle(
                          color: CaviaColors.textIvory,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _playbackController?.dispose();
    _libraryController?.dispose();
    _settingsController?.dispose();
    if (_ownsDb && _db != null) {
      _db!.close();
    }
    super.dispose();
  }
}

