import 'dart:async';
import '../domain/models/track.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/repositories/track_repository.dart';
import '../domain/result/result.dart';
import '../providers/provider_registry.dart';
import 'cache_entry.dart';
import 'cache_manager.dart';
import 'cache_state.dart';

/// Structured result of an offline caching eligibility evaluation.
class CacheEligibilityResult {
  final bool isEligible;
  final bool isLocalOwned;
  final String? rejectionReason;
  final CacheState state;

  const CacheEligibilityResult({
    required this.isEligible,
    this.isLocalOwned = false,
    this.rejectionReason,
    required this.state,
  });

  factory CacheEligibilityResult.eligible() {
    return const CacheEligibilityResult(
      isEligible: true,
      state: CacheState.eligible,
    );
  }

  factory CacheEligibilityResult.localOwned({String? reason}) {
    return CacheEligibilityResult(
      isEligible: false,
      isLocalOwned: true,
      rejectionReason: reason ?? 'Original user file already present on local storage.',
      state: CacheState.availableOffline,
    );
  }

  factory CacheEligibilityResult.notSupported({String? reason}) {
    return CacheEligibilityResult(
      isEligible: false,
      rejectionReason: reason ?? CacheMessages.notSupportedBySource,
      state: CacheState.notSupportedBySource,
    );
  }
}

/// Central coordinator for offline caching, eviction policies, and storage limits.
class CachingCoordinator {
  final CacheManager cacheManager;
  final ProviderRegistry providerRegistry;
  final SettingsRepository? settingsRepository;
  final TrackRepository? trackRepository;
  final String? Function()? getActivePlayingTrackId;

  /// Default cache limit is 1.2 GB (1,288,490,188 bytes)
  static const int defaultMaxCacheSizeBytes = 1200 * 1024 * 1024;
  int maxCacheSizeBytes;

  CachingCoordinator({
    required this.cacheManager,
    required this.providerRegistry,
    this.settingsRepository,
    this.trackRepository,
    this.getActivePlayingTrackId,
    int? maxCacheSizeBytes,
  }) : maxCacheSizeBytes = maxCacheSizeBytes ?? defaultMaxCacheSizeBytes;

  /// Checks whether a track is eligible for offline caching.
  ///
  /// Strictly enforces:
  /// 1. YouTube audiovisual content is NEVER cached (rejects with [CacheMessages.notSupportedBySource]).
  /// 2. Spotify tracks are NEVER cached (metadata only; rejects with [CacheMessages.notSupportedBySource]).
  /// 3. Providers with [cachingPermission == false] are rejected.
  /// 4. Local files already owned on device are NOT copied into a redundant second cache.
  CacheEligibilityResult checkEligibility(Track track) {
    // 1. Local owned files check: avoid redundant duplication
    if (track.providerId == 'local' || track.isLocal) {
      return CacheEligibilityResult.localOwned();
    }

    // 2. YouTube exclusion
    if (track.providerId.toLowerCase() == 'youtube') {
      return CacheEligibilityResult.notSupported(
        reason: CacheMessages.notSupportedBySource,
      );
    }

    // 3. Spotify exclusion
    if (track.providerId.toLowerCase() == 'spotify') {
      return CacheEligibilityResult.notSupported(
        reason: CacheMessages.notSupportedBySource,
      );
    }

    // 4. Provider capability inspection
    final provider = providerRegistry.getProvider(track.providerId);
    if (provider == null) {
      return CacheEligibilityResult.notSupported(
        reason: "Source provider '${track.providerId}' is not available.",
      );
    }

    if (!provider.capabilities.cachingPermission ||
        !provider.capabilities.offlineAvailability) {
      return CacheEligibilityResult.notSupported(
        reason: CacheMessages.notSupportedBySource,
      );
    }

    return CacheEligibilityResult.eligible();
  }

  /// Request caching for an eligible track.
  Future<Result<CacheEntry?, String>> requestCacheTrack({
    required Track track,
    required Stream<List<int>> Function() byteStreamProvider,
    int? expectedSize,
    String? sha256Hash,
    String mimeType = 'audio/mpeg',
  }) async {
    // 1. Check if offline caching is globally enabled
    final prefs = await settingsRepository?.getPreferences();
    final isCachingEnabled = prefs?.offlineCaching ?? true;
    if (!isCachingEnabled) {
      return const Result.failure(CacheMessages.cachingDisabled);
    }

    // 2. Check eligibility
    final eligibility = checkEligibility(track);
    if (eligibility.isLocalOwned) {
      // Already stored locally on user device
      return const Result.success(null);
    }
    if (!eligibility.isEligible) {
      return Result.failure(
        eligibility.rejectionReason ?? CacheMessages.notSupportedBySource,
      );
    }

    // 3. Check cache size limit & run LRU eviction if needed
    final currentSize = await cacheManager.calculateTotalCacheSize();
    final candidateSize = expectedSize ?? (5 * 1024 * 1024); // 5MB estimate if unknown
    final effectiveLimit = maxCacheSizeBytes;
    if (currentSize + candidateSize > effectiveLimit) {
      final bytesToFree = (currentSize + candidateSize) - effectiveLimit;
      final activeTrackId = getActivePlayingTrackId?.call();
      await cacheManager.evictLru(
        bytesToFree: bytesToFree,
        activeTrackId: activeTrackId,
      );
    }

    // 4. Download and cache
    final entry = await cacheManager.cacheTrack(
      track: track,
      byteStreamProvider: byteStreamProvider,
      expectedSize: expectedSize,
      sha256Hash: sha256Hash,
      mimeType: mimeType,
    );

    if (entry == null) {
      return const Result.failure(CacheMessages.cachingFailed);
    }

    // 5. Update cached size in settings repository if available
    final newSize = await cacheManager.calculateTotalCacheSize();
    if (prefs != null) {
      await settingsRepository?.updatePreferences(
        prefs.copyWith(currentCacheSizeBytes: newSize.toDouble()),
      );
    }

    return Result.success(entry);
  }

  /// Handles user toggling offline caching ON or OFF.
  ///
  /// CRITICAL GUARANTEE: Turning caching off must NEVER automatically clear the cache.
  /// Existing valid cached content is strictly preserved for offline playback.
  Future<void> onOfflineCachingToggled(bool enabled) async {
    final prefs = await settingsRepository?.getPreferences();
    if (prefs != null) {
      await settingsRepository?.updatePreferences(
        prefs.copyWith(offlineCaching: enabled),
      );
    }

    if (!enabled) {
      // Safely stop background transfers without deleting cached files
      final entries = await cacheManager.getAllCacheEntries();
      for (final entry in entries) {
        if (entry.downloadState == CacheState.downloading ||
            entry.downloadState == CacheState.waiting) {
          await cacheManager.cancelDownload(entry.trackId);
        }
      }
    }
  }

  /// Clears app-managed cached audio and updates storage records.
  ///
  /// Returns [CacheMessages.cacheCleared] on success,
  /// or [CacheMessages.noChangesMade] if user cancelled or declined confirmation.
  Future<String> executeClearCache({required bool userConfirmed}) async {
    if (!userConfirmed) {
      return CacheMessages.noChangesMade;
    }

    final activeTrackId = getActivePlayingTrackId?.call();
    await cacheManager.clearCache(activeTrackId: activeTrackId);

    // Update settings repository
    final prefs = await settingsRepository?.getPreferences();
    if (prefs != null) {
      final remainingSize = await cacheManager.calculateTotalCacheSize();
      await settingsRepository?.updatePreferences(
        prefs.copyWith(currentCacheSizeBytes: remainingSize.toDouble()),
      );
    } else {
      await settingsRepository?.clearCache();
    }

    return CacheMessages.cacheCleared;
  }

  /// Formats byte quantities into standard human-readable units (e.g. 1.2 GB, 45.2 MB, 0 MB).
  static String formatStorageSize(num bytes) {
    if (bytes <= 0) return '0 MB';
    const kb = 1024;
    const mb = 1024 * kb;
    const gb = 1024 * mb;

    if (bytes >= gb) {
      final value = bytes / gb;
      return '${value.toStringAsFixed(1)} GB';
    } else if (bytes >= mb) {
      final value = bytes / mb;
      return '${value.toStringAsFixed(0)} MB';
    } else if (bytes >= kb) {
      final value = (bytes / kb).round();
      return '$value KB';
    } else {
      return '$bytes B';
    }
  }
}
