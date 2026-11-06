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

class SettingsController extends ChangeNotifier {
  final SettingsRepository? repository;
  final AuthRepository? authRepository;
  final SyncRepository? syncRepository;
  final CacheManager? cacheManager;
  final CachingCoordinator? cachingCoordinator;

  StreamSubscription<AppPreferences>? _sub;
  StreamSubscription<Profile>? _authSub;
  StreamSubscription<SyncState>? _syncSub;
  bool _isDisposed = false;

  Profile _currentProfile = Profile.guest();
  Profile get currentProfile => _currentProfile;
  bool get isAuthenticated => !_currentProfile.isGuest;

  // Storage settings
  bool _offlineCaching = true;
  double _cacheSizeBytes = 1.2 * 1024 * 1024 * 1024; // 1.2 GB seed

  // Cloud sync
  bool _cloudSync = false;
  String _lastSyncTime = "Never";
  String _syncStatusMessage = "Sync is off.";
  String get syncStatusMessage => _syncStatusMessage;

  // Playback settings
  String _audioQuality = "Lossless (24-bit / 96kHz FLAC)";
  bool _crossfade = true;
  bool _gaplessPlayback = true;
  bool _normalizeVolume = false;

  // Appearance settings
  final bool _darkAppearance = true;
  Color _accentColor = CaviaColors.vermilion;
  bool _artworkAtmosphere = true;
  String _animationIntensity = "Smooth";

  SettingsController({
    this.repository,
    this.authRepository,
    this.syncRepository,
    this.cacheManager,
    this.cachingCoordinator,
  }) {
    if (authRepository != null) {
      _currentProfile = authRepository!.currentProfile;
      _authSub = authRepository!.watchCurrentProfile().listen((p) {
        _currentProfile = p;
        notifyListeners();
      });
    }

    if (syncRepository != null) {
      _syncSub = syncRepository!.watchSyncState().listen((state) {
        _syncStatusMessage = state.getUserFacingMessage(
          isGuest: _currentProfile.isGuest,
          syncEnabled: _cloudSync,
        );
        notifyListeners();
      });
    }

    if (repository != null) {
      _initFromRepo();
    }
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
    _cacheSizeBytes = prefs.currentCacheSizeBytes;
    _cloudSync = prefs.cloudSync;
    _lastSyncTime = prefs.lastSyncTime;
    _audioQuality = prefs.audioQuality;
    _crossfade = prefs.crossfade;
    _gaplessPlayback = prefs.gaplessPlayback;
    _normalizeVolume = prefs.normalizeVolume;
    _accentColor = Color(prefs.accentColorValue);
    _artworkAtmosphere = prefs.artworkAtmosphere;
    _animationIntensity = prefs.animationIntensity;
    notifyListeners();
  }

  AppPreferences _toPreferences() {
    return AppPreferences(
      profileId: _currentProfile.id,
      offlineCaching: _offlineCaching,
      audioQuality: _audioQuality,
      crossfade: _crossfade,
      gaplessPlayback: _gaplessPlayback,
      normalizeVolume: _normalizeVolume,
      accentColorValue: _accentColor.toARGB32(),
      artworkAtmosphere: _artworkAtmosphere,
      animationIntensity: _animationIntensity,
      cloudSync: _cloudSync,
      lastSyncTime: _lastSyncTime,
      currentCacheSizeBytes: _cacheSizeBytes,
    );
  }

  // Getters
  bool get offlineCaching => _offlineCaching;
  double get cacheSizeBytes => _cacheSizeBytes;
  String get cacheSizeFormatted => CachingCoordinator.formatStorageSize(_cacheSizeBytes);

  bool get cloudSync => _cloudSync;
  String get lastSyncTime => _lastSyncTime;

  String get audioQuality => _audioQuality;
  bool get crossfade => _crossfade;
  bool get gaplessPlayback => _gaplessPlayback;
  bool get normalizeVolume => _normalizeVolume;

  bool get darkAppearance => _darkAppearance;
  Color get accentColor => _accentColor;
  bool get artworkAtmosphere => _artworkAtmosphere;
  String get animationIntensity => _animationIntensity;

  // Storage Actions
  Future<void> toggleOfflineCaching(bool value) async {
    _offlineCaching = value;
    // NOTE: Disabling caching does NOT clear existing files
    if (cachingCoordinator != null) {
      await cachingCoordinator!.onOfflineCachingToggled(value);
    }
    _persist();
    notifyListeners();
  }

  Future<String> clearCache({bool confirmed = true}) async {
    if (!confirmed) {
      return CacheMessages.noChangesMade;
    }
    if (cachingCoordinator != null) {
      final res = await cachingCoordinator!.executeClearCache(userConfirmed: confirmed);
      _cacheSizeBytes = (await cachingCoordinator!.cacheManager.calculateTotalCacheSize()).toDouble();
      _persist();
      notifyListeners();
      return res;
    }
    _cacheSizeBytes = 0;
    await repository?.clearCache();
    _persist();
    notifyListeners();
    return CacheMessages.cacheCleared;
  }

  // Cloud Sync Actions
  String toggleCloudSync(bool value) {
    if (value && authRepository != null && _currentProfile.isGuest) {
      _cloudSync = false;
      _syncStatusMessage = 'Sign in to sync your library.';
      notifyListeners();
      return _syncStatusMessage;
    }

    _cloudSync = value;
    if (!_cloudSync) {
      _syncStatusMessage = 'Sync is off.';
    } else {
      _syncStatusMessage = 'Library synced';
      _lastSyncTime = 'Just now';
      triggerSync();
    }
    _persist();
    notifyListeners();
    return _syncStatusMessage;
  }

  Future<void> triggerSync() async {
    if (!_cloudSync || _currentProfile.isGuest || syncRepository == null) return;
    await syncRepository!.processOutbox(profileId: _currentProfile.id);
    await syncRepository!.pullRemoteChanges(profileId: _currentProfile.id);
  }

  // Auth Actions
  Future<Result<Profile, AppError>> signIn(String email, String password) async {
    final repo = authRepository;
    if (repo == null) {
      return const Result.failure(ValidationError('Authentication service unavailable.'));
    }
    final res = await repo.signInWithPassword(email, password);
    if (res.isSuccess) {
      _currentProfile = res.dataOrNull!;
      _cloudSync = true;
      _syncStatusMessage = 'Library synced';
      _lastSyncTime = 'Just now';
      _persist();
      notifyListeners();
      triggerSync();
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
      return const Result.failure(ValidationError('Authentication service unavailable.'));
    }
    final res = await repo.signUp(email, password, displayName: displayName);
    if (res.isSuccess) {
      _currentProfile = res.dataOrNull!;
      _cloudSync = true;
      _syncStatusMessage = 'Library synced';
      _lastSyncTime = 'Just now';
      _persist();
      notifyListeners();
      triggerSync();
    }
    return res;
  }

  Future<Result<void, AppError>> signOut() async {
    final repo = authRepository;
    if (repo != null) {
      await repo.signOut();
    }
    _currentProfile = Profile.guest();
    _cloudSync = false;
    _syncStatusMessage = 'Sync is off.';
    _persist();
    notifyListeners();
    return const Result.success(null);
  }

  Future<Result<void, AppError>> deleteAccount() async {
    final repo = authRepository;
    if (repo != null) {
      final res = await repo.deleteAccount();
      if (res.isFailure) return res;
    }
    _currentProfile = Profile.guest();
    _cloudSync = false;
    _syncStatusMessage = 'Sync is off.';
    _persist();
    notifyListeners();
    return const Result.success(null);
  }

  Future<Result<void, AppError>> mergeGuestWithAccount() async {
    if (_currentProfile.isGuest || syncRepository == null) {
      return const Result.failure(ValidationError('Must be signed in to merge libraries.'));
    }
    final res = await syncRepository!.mergeGuestLibraryWithAccount(_currentProfile.id);
    if (res.isSuccess) {
      triggerSync();
    }
    return res;
  }

  // Playback Actions
  void setAudioQuality(String quality) {
    _audioQuality = quality;
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

  // Appearance Actions
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
