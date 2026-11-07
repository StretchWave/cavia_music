import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/database/cavia_database.dart';
import '../domain/models/track.dart';
import 'cache_entry.dart';
import 'cache_manager.dart';
import 'cache_state.dart';

class _ActiveDownload {
  final String trackId;
  final File tmpFile;
  final IOSink sink;
  StreamSubscription<List<int>>? subscription;
  final Completer<void> completer;
  bool isCancelled = false;

  _ActiveDownload({
    required this.trackId,
    required this.tmpFile,
    required this.sink,
    required this.completer,
  });
}

/// Concrete SQLite & filesystem implementation of [CacheManager].
class LocalCacheManager implements CacheManager {
  final CaviaDatabase db;
  final Directory? customDirectory;
  final Map<String, _ActiveDownload> _activeDownloads = {};
  final Map<String, StreamController<CacheState>> _stateControllers = {};

  LocalCacheManager({
    required this.db,
    this.customDirectory,
  });

  Future<Directory> _getCacheDirectory() async {
    if (customDirectory != null) {
      if (!await customDirectory!.exists()) {
        await customDirectory!.create(recursive: true);
      }
      return customDirectory!;
    }
    final appCache = await getApplicationCacheDirectory();
    final cacheDir = Directory(p.join(appCache.path, 'cavia_cache'));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  StreamController<CacheState> _getOrCreateStateController(String trackId) {
    return _stateControllers.putIfAbsent(
      trackId,
      () => StreamController<CacheState>.broadcast(),
    );
  }

  void _notifyTrackState(String trackId, CacheState state) {
    if (_stateControllers.containsKey(trackId)) {
      _stateControllers[trackId]?.add(state);
    }
  }

  @override
  Stream<CacheState> watchTrackCacheState(String trackId) {
    return _getOrCreateStateController(trackId).stream;
  }

  @override
  Future<CacheEntry?> getCacheEntry(String trackId) async {
    final query = db.select(db.dbCacheEntries)
      ..where((tbl) => tbl.trackId.equals(trackId));
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return _mapRowToEntry(row);
  }

  @override
  Stream<List<CacheEntry>> watchCacheEntries() {
    return (db.select(db.dbCacheEntries)
          ..orderBy([
            (tbl) => OrderingTerm(
                expression: tbl.cachedAt, mode: OrderingMode.desc)
          ]))
        .watch()
        .map((rows) => rows.map(_mapRowToEntry).toList());
  }

  @override
  Future<List<CacheEntry>> getAllCacheEntries() async {
    final rows = await (db.select(db.dbCacheEntries)
          ..orderBy([
            (tbl) => OrderingTerm(
                expression: tbl.cachedAt, mode: OrderingMode.desc)
          ]))
        .get();
    return rows.map(_mapRowToEntry).toList();
  }

  @override
  Future<CacheState> getTrackCacheState(String trackId) async {
    if (_activeDownloads.containsKey(trackId)) {
      return CacheState.downloading;
    }
    final entry = await getCacheEntry(trackId);
    if (entry == null) return CacheState.notCached;
    return entry.downloadState;
  }

  @override
  Future<CacheEntry?> cacheTrack({
    required Track track,
    required Stream<List<int>> Function() byteStreamProvider,
    int? expectedSize,
    String? sha256Hash,
    String mimeType = 'audio/mpeg',
  }) async {
    if (_activeDownloads.containsKey(track.id)) {
      // Already downloading
      return null;
    }

    final cacheDir = await _getCacheDirectory();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final tmpFile = File(p.join(cacheDir.path, '${track.id}_$nowMs.tmp'));
    final sink = tmpFile.openWrite();
    final completer = Completer<void>();

    final download = _ActiveDownload(
      trackId: track.id,
      tmpFile: tmpFile,
      sink: sink,
      completer: completer,
    );
    _activeDownloads[track.id] = download;

    _notifyTrackState(track.id, CacheState.waiting);
    _notifyTrackState(track.id, CacheState.downloading);

    String actualSha256 = '';
    final digestSink = ChunkedConversionSink<Digest>.withCallback((digests) {
      if (digests.isNotEmpty) {
        actualSha256 = digests.single.toString();
      }
    });
    final chunkSink = sha256.startChunkedConversion(digestSink);

    try {
      final byteStream = byteStreamProvider();
      final sub = byteStream.listen(
        (chunk) {
          if (download.isCancelled) return;
          sink.add(chunk);
          chunkSink.add(chunk);
        },
        onError: (err) {
          if (!completer.isCompleted) {
            completer.completeError(err);
          }
        },
        onDone: () {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        cancelOnError: true,
      );
      download.subscription = sub;

      await completer.future;

      if (download.isCancelled) {
        try {
          await sink.close();
        } catch (_) {}
        if (await tmpFile.exists()) {
          try {
            await tmpFile.delete();
          } catch (_) {}
        }
        _notifyTrackState(track.id, CacheState.notCached);
        return null;
      }

      await sink.flush();
      await sink.close();
      chunkSink.close();

      final fileSize = await tmpFile.length();

      // Integrity check on size
      if (expectedSize != null && expectedSize > 0 && fileSize != expectedSize) {
        if (await tmpFile.exists()) await tmpFile.delete();
        _notifyTrackState(track.id, CacheState.corrupted);
        return null;
      }

      // Integrity check on hash
      if (sha256Hash != null &&
          sha256Hash.isNotEmpty &&
          actualSha256.toLowerCase() != sha256Hash.toLowerCase()) {
        if (await tmpFile.exists()) await tmpFile.delete();
        _notifyTrackState(track.id, CacheState.corrupted);
        return null;
      }

      // Promote .tmp to permanent cache file
      final ext = mimeType.contains('flac') ? 'flac' : 'mp3';
      final finalPath = p.join(cacheDir.path, '${track.id}.$ext');
      final finalFile = File(finalPath);
      if (await finalFile.exists()) {
        await finalFile.delete();
      }
      await tmpFile.rename(finalPath);

      final now = DateTime.now();

      // Ensure base Track record exists in DbTracks to satisfy foreign key constraint
      final existingTrack = await (db.select(db.dbTracks)..where((t) => t.id.equals(track.id))).getSingleOrNull();
      if (existingTrack == null) {
        await db.into(db.dbTracks).insertOnConflictUpdate(
          DbTracksCompanion(
            id: Value(track.id),
            providerId: Value(track.providerId),
            providerTrackId: Value(track.providerTrackId),
            title: Value(track.title),
            artist: Value(track.artist),
            artistsJson: Value(jsonEncode(track.artists)),
            album: Value(track.album),
            durationMs: Value(track.duration.inMilliseconds),
            artworkUri: Value(track.artworkUri),
            isrc: Value(track.isrc),
            explicit: Value(track.explicit),
            sourceAttribution: Value(track.sourceAttribution),
            dateAdded: Value(track.dateAdded),
            isCached: const Value(true),
            localCachePath: Value(finalPath),
          ),
        );
      } else {
        await (db.update(db.dbTracks)..where((t) => t.id.equals(track.id)))
            .write(DbTracksCompanion(
          isCached: const Value(true),
          localCachePath: Value(finalPath),
        ));
      }

      final companion = DbCacheEntriesCompanion(
        trackId: Value(track.id),
        cacheKey: Value(track.id),
        filePath: Value(finalPath),
        contentSizeBytes: Value(fileSize),
        mimeType: Value(mimeType),
        durationMs: Value(track.duration.inMilliseconds),
        providerId: Value(track.providerId),
        downloadState: const Value('availableOffline'),
        sha256Hash: Value(actualSha256),
        cachedAt: Value(now),
        lastAccessedAt: Value(now),
      );

      await db.into(db.dbCacheEntries).insertOnConflictUpdate(companion);

      _notifyTrackState(track.id, CacheState.availableOffline);

      return CacheEntry(
        trackId: track.id,
        cacheKey: track.id,
        filePath: finalPath,
        contentSizeBytes: fileSize,
        mimeType: mimeType,
        durationMs: track.duration.inMilliseconds,
        providerId: track.providerId,
        downloadState: CacheState.availableOffline,
        sha256Hash: actualSha256,
        cachedAt: now,
        lastAccessedAt: now,
      );
    } catch (e) {
      if (await tmpFile.exists()) {
        try {
          await sink.close();
          await tmpFile.delete();
        } catch (_) {}
      }
      _notifyTrackState(track.id, CacheState.failed);
      return null;
    } finally {
      _activeDownloads.remove(track.id);
    }
  }

  @override
  Future<void> cancelDownload(String trackId) async {
    final download = _activeDownloads[trackId];
    if (download != null) {
      download.isCancelled = true;
      await download.subscription?.cancel();
      if (!download.completer.isCompleted) {
        download.completer.complete();
      }
      _notifyTrackState(trackId, CacheState.notCached);
    }
  }

  @override
  Future<int> calculateTotalCacheSize() async {
    final cacheDir = await _getCacheDirectory();
    int totalBytes = 0;
    if (await cacheDir.exists()) {
      await for (final entity in cacheDir.list(recursive: false)) {
        if (entity is File) {
          totalBytes += await entity.length();
        }
      }
    }
    return totalBytes;
  }

  @override
  Future<int> evictLru({required int bytesToFree, String? activeTrackId}) async {
    if (bytesToFree <= 0) return 0;

    final entries = await (db.select(db.dbCacheEntries)
          ..orderBy([
            (tbl) => OrderingTerm(
                expression: tbl.lastAccessedAt, mode: OrderingMode.asc)
          ]))
        .get();

    int freedBytes = 0;

    for (final row in entries) {
      // Active track is never evicted
      if (activeTrackId != null && row.trackId == activeTrackId) {
        continue;
      }

      final file = File(row.filePath);
      final size = row.contentSizeBytes;
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }

      await (db.delete(db.dbCacheEntries)
            ..where((tbl) => tbl.trackId.equals(row.trackId)))
          .go();

      await (db.update(db.dbTracks)..where((t) => t.id.equals(row.trackId)))
          .write(const DbTracksCompanion(
        isCached: Value(false),
        localCachePath: Value(null),
      ));

      _notifyTrackState(row.trackId, CacheState.removedFromCache);

      freedBytes += size;
      if (freedBytes >= bytesToFree) {
        break;
      }
    }

    return freedBytes;
  }

  @override
  Future<int> clearCache({String? activeTrackId}) async {
    final entries = await db.select(db.dbCacheEntries).get();
    int freedBytes = 0;

    for (final row in entries) {
      if (activeTrackId != null && row.trackId == activeTrackId) {
        // Protect actively playing track
        continue;
      }

      final file = File(row.filePath);
      if (await file.exists()) {
        try {
          freedBytes += await file.length();
          await file.delete();
        } catch (_) {}
      } else {
        freedBytes += row.contentSizeBytes;
      }

      await (db.delete(db.dbCacheEntries)
            ..where((tbl) => tbl.trackId.equals(row.trackId)))
          .go();

      await (db.update(db.dbTracks)..where((t) => t.id.equals(row.trackId)))
          .write(const DbTracksCompanion(
        isCached: Value(false),
        localCachePath: Value(null),
      ));

      _notifyTrackState(row.trackId, CacheState.removedFromCache);
    }

    // Clean any orphaned .tmp or unreferenced files inside cache dir
    final cacheDir = await _getCacheDirectory();
    if (await cacheDir.exists()) {
      await for (final entity in cacheDir.list(recursive: false)) {
        if (entity is File) {
          final isProtected = activeTrackId != null &&
              p.basenameWithoutExtension(entity.path) == activeTrackId;
          if (!isProtected) {
            try {
              await entity.delete();
            } catch (_) {}
          }
        }
      }
    }

    return freedBytes;
  }

  @override
  Future<bool> verifyIntegrity(String trackId) async {
    final entry = await getCacheEntry(trackId);
    if (entry == null) return false;

    final file = File(entry.filePath);
    if (!await file.exists()) {
      await _markCorrupted(trackId);
      return false;
    }

    final len = await file.length();
    if (len != entry.contentSizeBytes) {
      try {
        await file.delete();
      } catch (_) {}
      await _markCorrupted(trackId);
      return false;
    }

    if (entry.sha256Hash != null && entry.sha256Hash!.isNotEmpty) {
      final digest = await sha256.bind(file.openRead()).first;
      if (digest.toString().toLowerCase() != entry.sha256Hash!.toLowerCase()) {
        try {
          await file.delete();
        } catch (_) {}
        await _markCorrupted(trackId);
        return false;
      }
    }

    return true;
  }

  Future<void> _markCorrupted(String trackId) async {
    await (db.delete(db.dbCacheEntries)
          ..where((tbl) => tbl.trackId.equals(trackId)))
        .go();

    await (db.update(db.dbTracks)..where((t) => t.id.equals(trackId)))
        .write(const DbTracksCompanion(
      isCached: Value(false),
      localCachePath: Value(null),
    ));

    _notifyTrackState(trackId, CacheState.corrupted);
  }

  @override
  Future<void> markAccessed(String trackId, [DateTime? accessedAt]) async {
    final now = accessedAt ?? DateTime.now();
    await (db.update(db.dbCacheEntries)
          ..where((tbl) => tbl.trackId.equals(trackId)))
        .write(DbCacheEntriesCompanion(
      lastAccessedAt: Value(now),
    ));
  }

  @override
  Future<void> deleteCacheEntry(String trackId) async {
    final entry = await getCacheEntry(trackId);
    if (entry != null) {
      final file = File(entry.filePath);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
      await (db.delete(db.dbCacheEntries)
            ..where((tbl) => tbl.trackId.equals(trackId)))
          .go();

      await (db.update(db.dbTracks)..where((t) => t.id.equals(trackId)))
          .write(const DbTracksCompanion(
        isCached: Value(false),
        localCachePath: Value(null),
      ));

      _notifyTrackState(trackId, CacheState.removedFromCache);
    }
  }

  CacheEntry _mapRowToEntry(DbCacheEntry row) {
    return CacheEntry(
      trackId: row.trackId,
      cacheKey: row.cacheKey,
      filePath: row.filePath,
      contentSizeBytes: row.contentSizeBytes,
      mimeType: row.mimeType,
      durationMs: row.durationMs,
      providerId: row.providerId,
      downloadState: _parseCacheState(row.downloadState),
      sha256Hash: row.sha256Hash,
      cachedAt: row.cachedAt,
      lastAccessedAt: row.lastAccessedAt,
    );
  }

  CacheState _parseCacheState(String state) {
    return CacheState.values.firstWhere(
      (e) => e.name == state,
      orElse: () => CacheState.availableOffline,
    );
  }
}
