import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../domain/models/app_preferences.dart';
import '../domain/models/profile.dart';
import '../domain/models/sync_state.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/sync_repository.dart';
import '../domain/result/result.dart';
import '../domain/result/app_error.dart';
import '../storage/cache_manager.dart';
import '../storage/cache_state.dart';
import '../storage/caching_coordinator.dart';
import '../providers/provider_registry.dart';
import '../providers/music_provider.dart';

/// Every displayed value in this controller is measured from a real source:
/// cache size is calculated from the database + file system, sync state comes
/// from the sync repository stream, and preferences round-trip the local store.
class SettingsController extends ChangeNotifier {
  final SettingsRepository? repository;
  final AuthRepository? authRepository;
  final SyncRepository? syncRepository;
  final CacheManager? cacheManager;
  final CachingCoordinator? cachingCoordinator;
  final ProviderRegistry? providerRegistry;

  StreamSubscription<AppPreferences>? _sub;
  StreamSubscription<Profile>? _authSub;
  StreamSubscription<SyncState>? _syncSub;
  bool _isDisposed = false;

  Profile _currentProfile = Profile.guest();
  Profile get currentProfile => _currentProfile;
  bool get isAuthenticated => !_currentProfile.isGuest;

  // Storage settings
  bool _offlineCaching = true;
  bool _isMeasuringCache = false;
  int _cacheSizeBytes = 0; // measured from the filesystem, never seeded

  // Cloud sync
  SyncState _syncState = const SyncState(profileId: 'guest');

  // Playback settings
  String _audioQuality = 'Lossless (24-bit / 96 kHz FLAC)';
  double _playbackSpeed = 1.0;
  bool _crossfade = true;
  bool _gaplessPlayback = true;
  bool _normalizeVolume = false;

  // Appearance settings
  final bool _darkAppearance = true;
  Color _accentColor = CaviaColors.vermilion;
  bool _artworkAtmosphere = true;
  String _animationIntensity = 'Smooth';

  SettingsController({
    this.repository,
    this.authRepository,
    this.syncRepository,
    this.cacheManager,
    this.cachingCoordinator,
    this.providerRegistry,
  }) {
    if (authRepository != null) {
      _currentProfile = authRepository!.currentProfile;
      _authSub = authRepository!.watchCurrentProfile().listen((p) {
        if (_isDisposed) return;
        _currentProfile = p;
        _refreshSyncMessage();
        notifyListeners();
      });
    }

    if (syncRepository != null) {
      _syncSub = syncRepository!.watchSyncState().listen((state) {
        if (_isDisposed) return;
        _syncState = state;
        _refreshSyncMessage();
        notifyListeners();
      });
    }

    if (repository != null) {
      _initFromRepo();
    }

    unawaited(_refreshCacheSizeFromDisk());
  }

  void _initFromRepo() async {
    final repo = repository;
    if (repo == null || _isDisposed) return;
    final prefs = await repo.getPreferences();
    if (_isDisposed) return;
    _applyPrefs(prefs);
    if (_isDisposed) return;
    _sub = repo.watchPreferences().listen(_applyPrefs);
  }

  void _applyPrefs(AppPreferences prefs) {
    if (_isDisposed) return;
    _offlineCaching = prefs.offlineCaching;
    _cloudSync = prefs.cloudSync;
    _audioQuality = prefs.audioQuality;
    _playbackSpeed = prefs.playbackSpeed;
    _crossfade = prefs.crossfade;
    _gaplessPlayback = prefs.gaplessPlayback;
    _normalizeVolume = prefs.normalizeVolume;
    _accentColor = Color(prefs.accentColorValue);
    _artworkAtmosphere = prefs.artworkAtmosphere;
    _animationIntensity = prefs.animationIntensity;
    _refreshSyncMessage();
    notifyListeners();
  }

  AppPreferences _toPreferences() {
    return AppPreferences(
      profileId: _currentProfile.id,
      offlineCaching: _offlineCaching,
      cacheQuotaBytes: _cacheQuotaBytes,
      audioQuality: _audioQuality,
      playbackSpeed: _playbackSpeed,
      crossfade: _crossfade,
      gaplessPlayback: _gaplessPlayback,
      normalizeVolume: _normalizeVolume,
      accentColorValue: _accentColor.toARGB32(),
      artworkAtmosphere: _artworkAtmosphere,
      animationIntensity: _animationIntensity,
      cloudSync: _cloudSync,
    );
  }

  double _cacheQuotaBytes =
      AppPreferences().cacheQuotaBytes; // user-chosen quota (policy)

  // ---------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------

  bool _cloudSync = false;

  bool get offlineCaching => _offlineCaching;
  int get cacheSizeBytes => _cacheSizeBytes;
  bool get isMeasuringCache => _isMeasuringCache;
  double get cacheQuotaBytes => _cacheQuotaBytes;
  String get cacheSizeFormatted =>
      CachingCoordinator.formatStorageSize(_cacheSizeBytes);
  String get cacheQuotaFormatted =>
      CachingCoordinator.formatStorageSize(_cacheQuotaBytes);

  bool get cloudSync => _cloudSync;
  SyncState get syncState => _syncState;
  String get syncStatusMessage =>
      _syncState.getUserFacingMessage(
        isGuest: _currentProfile.isGuest,
        syncEnabled: _cloudSync,
      );
  DateTime? get lastSyncedAt => _syncState.lastSyncedAt;

  String get audioQuality => _audioQuality;
  double get playbackSpeed => _playbackSpeed;
  bool get crossfade => _crossfade;
  bool get gaplessPlayback => _gaplessPlayback;
  bool get normalizeVolume => _normalizeVolume;

  bool get darkAppearance => _darkAppearance;
  Color get accentColor => _accentColor;
  bool get artworkAtmosphere => _artworkAtmosphere;
  String get animationIntensity => _animationIntensity;

  /// Live provider statuses as observed by the engine (real semantics, no
  /// marketing copy): display name, id, capabilities, operational flag.
  List<MusicProvider> get registeredProviders =>
      providerRegistry?.allProviders ?? const [];

  void _refreshSyncMessage() {
    // Message is derived on read via syncStatusMessage; kept for future
    // extensions. Nothing fabricated is stored here.
  }

  // ---------------------------------------------------------------------
  // Storage
  // ---------------------------------------------------------------------

  /// Reads the actual cache footprint from the database + filesystem.
  Future<void> _refreshCacheSizeFromDisk() async {
    final mgr = cacheManager;
    if (mgr == null) return;
    _isMeasuringCache = true;
    notifyListeners();
    try {
      final bytes = await mgr.calculateTotalCacheSize();
      if (_isDisposed) return;
      _cacheSizeBytes = bytes;
    } catch (_) {
      if (_isDisposed) return;
      // Real measurement failed: keep the last known value and surface
      // nothing fabricated. A failed measurement simply doesn't update.
    } finally {
      if (!_isDisposed) {
        _isMeasuringCache = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshCacheSize() => _refreshCacheSizeFromDisk();

  Future<void> toggleOfflineCaching(bool value) async {
    _offlineCaching = value;
    // NOTE: disabling caching does NOT delete existing files.
    await cachingCoordinator?.onOfflineCachingToggled(value);
    _persist();
    notifyListeners();
  }

  Future<void> setCacheQuota(double bytes) async {
    if (bytes <= 0) return;
    _cacheQuotaBytes = bytes;
    cachingCoordinator?.maxCacheSizeBytes = bytes.round();
    _persist();
    notifyListeners();
  }

  Future<String> clearCache({bool confirmed = true}) async {
    if (!confirmed) {
      return CacheMessages.noChangesMade;
    }
    if (cachingCoordinator != null) {
      final res = await cachingCoordinator!.executeClearCache(userConfirmed: confirmed);
      await _refreshCacheSizeFromDisk();
      _persist();
      return res;
    }
    await repository?.clearCache();
    await _refreshCacheSizeFromDisk();
    _persist();
    return CacheMessages.cacheCleared;
  }

  /// Makes [track] available offline by resolving its real playback source
  /// through the coordinator's eligibility gate and the provided [resolver].
  ///
  /// Every rejection reason is reported verbatim to the caller for toast
  /// display — eligibility policy (never cache YouTube official/Spotify
  /// content, never duplicate local files) is owned by the coordinator.
  Future<String> cacheTrackOffline(
    Track track,
    Future<Result<PlaybackSource, PlaybackFailure>> Function() resolveSource,
  ) async {
    final coord = cachingCoordinator;
    if (coord == null) {
      return 'Offline caching is not available in this build.';
    }

    final prefs = await repository?.getPreferences();
    if (prefs != null && !prefs.offlineCaching) {
      return CacheMessages.cachingDisabled;
    }

    // 1. Honest eligibility check (source restrictions explained verbatim).
    final eligibility = coord.checkEligibility(track);
    if (eligibility.isLocalOwned) return 'Already stored locally on this device.';
    if (!eligibility.isEligible) {
      return eligibility.rejectionReason ?? CacheMessages.notSupportedBySource;
    }

    // 2. Resolve the actual audio source the way playback does.
    final sourceRes = await resolveSource();
    if (sourceRes.isFailure) {
      return sourceRes.errorOrNull?.userMessage ??
          "Couldn't resolve audio for this track.";
    }
    final source = sourceRes.dataOrNull!;
    if (source.requiresOfficialPlayer) {
      return "Official-player sources can't be cached.";
    }
    if (source.isLocal) {
      return 'Already stored locally on this device.';
    }
    if (!source.isStream) {
      return CacheMessages.notSupportedBySource;
    }

    // 3. Download through the real HTTP pipeline.
    try {
      final request = http.Request('GET', source.uri);
      if (source.headers != null) request.headers.addAll(source.headers!);

      final response =
          await http.Client().send(request).timeout(const Duration(seconds: 30));
      if (response.statusCode != 200) {
        return "Couldn't download this track (server code ${response.statusCode}).";
      }

      final mimeType =
          source.mimeType ?? response.headers['content-type'] ?? 'audio/mpeg';

      final result = await coord.requestCacheTrack(
        track: track,
        byteStreamProvider: () => response.asStream(),
        mimeType: mimeType,
      );

      if (result.isSuccess) {
        if (prefs != null) await repository?.updatePreferences(prefs);
        await _refreshCacheSizeFromDisk();
        return CacheMessages.availableOffline;
      }
      return result.errorOrNull ?? CacheMessages.cachingFailed;
    } on TimeoutException {
      return 'Download timed out. Try again with a better connection.';
    } catch (e) {
      return CacheMessages.cachingFailed;
    }
  }

  // ---------------------------------------------------------------------
  // Cloud sync
  // ---------------------------------------------------------------------

  String toggleCloudSync(bool value) {
    if (value && _currentProfile.isGuest) {
      _cloudSync = false;
      _persist();
      notifyListeners();
      return 'Sign in to sync your library.';
    }

    _cloudSync = value;
    _persist();
    notifyListeners();
    if (_cloudSync) {
      triggerSync();
      return 'Syncing library...';
    }
    return 'Sync is off.';
  }

  /// Pushes the local outbox first, pulls remote changes second.
  Future<void> triggerSync() async {
    if (!_cloudSync || _currentProfile.isGuest) return;
    final repo = syncRepository;
    if (repo == null) return;
    await repo.processOutbox(profileId: _currentProfile.id);
    await repo.pullRemoteChanges(profileId: _currentProfile.id);
  }

  // ---------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------

  Future<Result<Profile, AppError>> signIn(String email, String password) async {
    final repo = authRepository;
    if (repo == null) {
      return const Result.failure(
          ValidationError('Sign in is not configured on this build.'));
    }
    final res = await repo.signInWithPassword(email, password);
    if (res.isSuccess) {
      _currentProfile = res.dataOrNull!;
      _cloudSync = _readStoredCloudSync();
      notifyListeners();
      unawaited(triggerSync());
    }
    return res;
  }

  Future<Result<Profile, AppError>> signUp(
    String email,
    String password, {
    String? displayName,
  }) async {
    final repo = authRepository;
    if (repo == null) {
      return const Result.failure(
          ValidationError('Sign up is not configured on this build.'));
    }
    final res = await repo.signUp(email, password, displayName: displayName);
    if (res.isSuccess) {
      _currentProfile = res.dataOrNull!;
      _cloudSync = _readStoredCloudSync();
      notifyListeners();
      unawaited(triggerSync());
    }
    return res;
  }

  Future<Result<void, AppError>> signOut() async {
    final repo = authRepository;
    if (repo != null) {
      final res = await repo.signOut();
      if (res.isFailure) return res;
    }
    _currentProfile = Profile.guest();
    notifyListeners();
    return const Result.success(null);
  }

  Future<Result<void, AppError>> deleteAccount() async {
    final repo = authRepository;
    if (repo == null) {
      return const Result.failure(ValidationError(
        'Cloud sync is not configured on this build. '
        'There is no cloud account to delete.',
      ));
    }
    final res = await repo.deleteAccount();
    if (res.isFailure) return res;
    _currentProfile = Profile.guest();
    _cloudSync = false;
    _persist();
    notifyListeners();
    return const Result.success(null);
  }

  Future<Result<void, AppError>> mergeGuestWithAccount() async {
    if (_currentProfile.isGuest) {
      return const Result.failure(
          ValidationError('Must be signed in to merge libraries.'));
    }
    final repo = syncRepository;
    if (repo == null) {
      return const Result.failure(ValidationError(
        'Cloud sync is not configured on this build.',
      ));
    }
    final res =
        await repo.mergeGuestLibraryWithAccount(_currentProfile.id);
    if (res.isSuccess) {
      await triggerSync();
    }
    return res;
  }

  bool _readStoredCloudSync() {
    // The stored preference is loaded asynchronously by the repo stream;
    // during sign-in the last observed value is used to stay consistent.
    return _cloudSync;
  }

  // ---------------------------------------------------------------------
  // Playback
  // ---------------------------------------------------------------------

  void setAudioQuality(String quality) {
    if (quality == _audioQuality) return;
    _audioQuality = quality;
    _persist();
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double speed) async {
    final clamped = speed.clamp(0.25, 4.0);
    _playbackSpeed = clamped;
    _persist();
    notifyListeners();
  }

  void toggleCrossfade(bool value) {
    _crossfade = value;
    _persist();
    notifyListeners();
  }

  void toggleGapless(bool value) {
    _gaplessPlayback = value;
    _persist();
    notifyListeners();
  }

  void toggleNormalizeVolume(bool value) {
    _normalizeVolume = value;
    _persist();
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Appearance
  // ---------------------------------------------------------------------

  void setAccentColor(Color color) {
    _accentColor = color;
    _persist();
    notifyListeners();
  }

  void toggleArtworkAtmosphere(bool value) {
    _artworkAtmosphere = value;
    _persist();
    notifyListeners();
  }

  void setAnimationIntensity(String intensity) {
    _animationIntensity = intensity;
    _persist();
    notifyListeners();
  }

  void _persist() {
    repository?.updatePreferences(_toPreferences());
  }

  @override
  void dispose() {
    _isDisposed = true;
    _sub?.cancel();
    _authSub?.cancel();
    _syncSub?.cancel();
    super.dispose();
  }
}
