import 'cache_state.dart';

/// Domain representation of a cached audio asset.
class CacheEntry {
  final String trackId;
  final String cacheKey;
  final String filePath;
  final int contentSizeBytes;
  final String mimeType;
  final int? durationMs;
  final String providerId;
  final CacheState downloadState;
  final String? sha256Hash;
  final DateTime cachedAt;
  final DateTime lastAccessedAt;

  const CacheEntry({
    required this.trackId,
    required this.cacheKey,
    required this.filePath,
    required this.contentSizeBytes,
    this.mimeType = 'audio/mpeg',
    this.durationMs,
    required this.providerId,
    this.downloadState = CacheState.availableOffline,
    this.sha256Hash,
    required this.cachedAt,
    required this.lastAccessedAt,
  });

  CacheEntry copyWith({
    String? trackId,
    String? cacheKey,
    String? filePath,
    int? contentSizeBytes,
    String? mimeType,
    int? durationMs,
    String? providerId,
    CacheState? downloadState,
    String? sha256Hash,
    DateTime? cachedAt,
    DateTime? lastAccessedAt,
  }) {
    return CacheEntry(
      trackId: trackId ?? this.trackId,
      cacheKey: cacheKey ?? this.cacheKey,
      filePath: filePath ?? this.filePath,
      contentSizeBytes: contentSizeBytes ?? this.contentSizeBytes,
      mimeType: mimeType ?? this.mimeType,
      durationMs: durationMs ?? this.durationMs,
      providerId: providerId ?? this.providerId,
      downloadState: downloadState ?? this.downloadState,
      sha256Hash: sha256Hash ?? this.sha256Hash,
      cachedAt: cachedAt ?? this.cachedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheEntry &&
          runtimeType == other.runtimeType &&
          trackId == other.trackId &&
          filePath == other.filePath &&
          contentSizeBytes == other.contentSizeBytes &&
          downloadState == other.downloadState;

  @override
  int get hashCode =>
      trackId.hashCode ^
      filePath.hashCode ^
      contentSizeBytes.hashCode ^
      downloadState.hashCode;

  @override
  String toString() =>
      'CacheEntry(trackId: $trackId, path: $filePath, size: $contentSizeBytes, state: $downloadState)';
}

