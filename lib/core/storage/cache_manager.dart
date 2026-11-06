import 'dart:async';
import '../domain/models/track.dart';
import 'cache_entry.dart';
import 'cache_state.dart';

/// Abstract contract for local disk caching of audio streams.
abstract class CacheManager {
  /// Retrieves the cache entry for a track, if it exists.
  Future<CacheEntry?> getCacheEntry(String trackId);

  /// Streams real-time updates for all cache entries.
  Stream<List<CacheEntry>> watchCacheEntries();

  /// Gets all cache entries currently recorded.
  Future<List<CacheEntry>> getAllCacheEntries();

  /// Gets the current cache state for a specific track.
  Future<CacheState> getTrackCacheState(String trackId);

  /// Streams state updates for a specific track.
  Stream<CacheState> watchTrackCacheState(String trackId);

  /// Downloads and caches an audio stream for a track.
  Future<CacheEntry?> cacheTrack({
    required Track track,
    required Stream<List<int>> Function() byteStreamProvider,
    int? expectedSize,
    String? sha256Hash,
    String mimeType = 'audio/mpeg',
  });

  /// Cancels an in-progress download for a track.
  Future<void> cancelDownload(String trackId);

  /// Computes the total storage used by app-managed cache files (in bytes).
  Future<int> calculateTotalCacheSize();

  /// Evicts least-recently-used tracks to free up at least [bytesToFree] bytes.
  /// Never evicts [activeTrackId] if specified.
  Future<int> evictLru({required int bytesToFree, String? activeTrackId});

  /// Clears all app-managed cache files and records.
  /// Does NOT touch original user files outside the cache directory.
  /// Preserves [activeTrackId] if actively playing.
  Future<int> clearCache({String? activeTrackId});

  /// Verifies file existence and SHA-256 integrity of a cached track.
  Future<bool> verifyIntegrity(String trackId);

  /// Updates the `lastAccessedAt` timestamp for LRU tracking.
  Future<void> markAccessed(String trackId, [DateTime? accessedAt]);

  /// Deletes a specific cached file and removes its database record.
  Future<void> deleteCacheEntry(String trackId);
}
