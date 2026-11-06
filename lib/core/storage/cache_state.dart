/// Explicit cache states for tracks in Cavia Music.
enum CacheState {
  notCached,
  eligible,
  waiting,
  downloading,
  availableOffline,
  failed,
  corrupted,
  expired,
  notSupportedBySource,
  removedFromCache,
}

extension CacheStateX on CacheState {
  String get displayName {
    switch (this) {
      case CacheState.notCached:
        return 'Not Cached';
      case CacheState.eligible:
        return 'Eligible';
      case CacheState.waiting:
        return 'Waiting';
      case CacheState.downloading:
        return 'Downloading';
      case CacheState.availableOffline:
        return 'Available offline';
      case CacheState.failed:
        return 'Download Failed';
      case CacheState.corrupted:
        return 'Corrupted';
      case CacheState.expired:
        return 'Expired';
      case CacheState.notSupportedBySource:
        return 'Not Supported';
      case CacheState.removedFromCache:
        return 'Removed';
    }
  }

  /// Official user-facing message corresponding to the cache state or scenario.
  String get statusMessage {
    switch (this) {
      case CacheState.availableOffline:
        return 'Available offline';
      case CacheState.notSupportedBySource:
        return "This source doesn't allow offline caching.";
      case CacheState.failed:
      case CacheState.corrupted:
        return "Couldn't finish caching this track.";
      case CacheState.notCached:
      case CacheState.removedFromCache:
      case CacheState.expired:
        return "This track isn't cached for offline playback.";
      case CacheState.waiting:
        return 'Waiting to download...';
      case CacheState.downloading:
        return 'Downloading for offline playback...';
      case CacheState.eligible:
        return 'Ready to cache';
    }
  }

  bool get isPlayableOffline => this == CacheState.availableOffline;
}

/// Standardized UI notification strings for offline caching.
abstract final class CacheMessages {
  static const String availableOffline = 'Available offline';
  static const String notCached = "This track isn't cached for offline playback.";
  static const String cachingDisabled = 'Offline caching is disabled.';
  static const String notSupportedBySource = "This source doesn't allow offline caching.";
  static const String cachingFailed = "Couldn't finish caching this track.";
  static const String cacheCleared = 'Cache cleared';
  static const String noChangesMade = 'No changes made';
}

