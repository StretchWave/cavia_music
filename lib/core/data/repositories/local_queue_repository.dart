import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:rxdart/rxdart.dart';

import '../../domain/models/playback_queue.dart';
import '../../domain/models/track.dart';
import '../../domain/repositories/queue_repository.dart';
import '../../domain/result/result.dart';
import '../../domain/result/app_error.dart';
import '../database/cavia_database.dart';

class LocalQueueRepository implements QueueRepository {
  final CaviaDatabase db;

  LocalQueueRepository(this.db);

  String _resolveProfile(String? profileId) => profileId ?? 'guest';

  QueueItem _mapItemRow(TypedResult r) {
    final qEntry = r.readTable(db.dbQueueEntries);
    final trackRow = r.readTable(db.dbTracks);
    final isLiked = r.readTableOrNull(db.dbLikedSongs) != null;
    return QueueItem(
      id: qEntry.id,
      trackId: qEntry.trackId,
      position: qEntry.position,
      track: _trackFromRow(trackRow, isLiked),
    );
  }

  Track _trackFromRow(DbTrack t, bool isLiked) {
    final artists = t.artistsJson == '[]'
        ? [t.artist]
        : List<String>.from((jsonDecode(t.artistsJson) as List).map((e) => e.toString()));
    List<LyricLine> lyrics = const [];
    try {
      final decoded = jsonDecode(t.lyricsJson);
      if (decoded is List) {
        lyrics = decoded.whereType<Map<String, dynamic>>().map(LyricLine.fromJson).toList();
      }
    } catch (_) {}
    return Track(
      id: t.id,
      providerId: t.providerId,
      providerTrackId: t.providerTrackId,
      title: t.title,
      artist: t.artist,
      artists: artists,
      album: t.album,
      albumArtist: t.albumArtist,
      duration: Duration(milliseconds: t.durationMs),
      artworkUri: t.artworkUri,
      isrc: t.isrc,
      explicit: t.explicit,
      trackNumber: t.trackNumber,
      discNumber: t.discNumber,
      releaseYear: t.releaseYear,
      genre: t.genre,
      filePath: t.filePath,
      fileFormat: t.fileFormat,
      fileSizeBytes: t.fileSizeBytes,
      dateAdded: t.dateAdded,
      isLiked: isLiked,
      isCached: t.isCached,
      localCachePath: t.localCachePath,
      lyrics: lyrics,
      playCount: t.playCount,
      lastPlayedAt: t.lastPlayedAt,
    );
  }

  @override
  Future<Result<PlaybackQueueState, AppError>> loadQueue({String? profileId}) async {
    try {
      final pid = _resolveProfile(profileId);

      final stateRow =
          await (db.select(db.dbQueueState)..where((tbl) => tbl.profileId.equals(pid)))
              .getSingleOrNull();

      final entriesQuery = (db.select(db.dbQueueEntries)
            ..where((tbl) => tbl.profileId.equals(pid))
            ..orderBy([(tbl) => OrderingTerm(expression: tbl.position, mode: OrderingMode.asc)]))
          .join([
        innerJoin(db.dbTracks, db.dbTracks.id.equalsExp(db.dbQueueEntries.trackId)),
        leftOuterJoin(
          db.dbLikedSongs,
          db.dbLikedSongs.trackId.equalsExp(db.dbTracks.id) &
              db.dbLikedSongs.profileId.equals(pid),
        ),
      ]);

      final rows = await entriesQuery.get();
      final items = rows.map(_mapItemRow).toList();

      final repeatMode = switch (stateRow?.repeatMode) {
        'all' => CaviaRepeatMode.all,
        'one' => CaviaRepeatMode.one,
        _ => CaviaRepeatMode.off,
      };

      return Result.success(PlaybackQueueState(
        items: items,
        currentIndex: stateRow?.currentIndex ?? (items.isNotEmpty ? 0 : -1),
        repeatMode: repeatMode,
        isShuffle: stateRow?.isShuffle ?? false,
        position: Duration(milliseconds: stateRow?.positionMs ?? 0),
        isPlaying: false, // never resume claiming to be playing across launches
        speed: stateRow?.speed ?? 1.0,
      ));
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to load queue: $e', cause: st));
    }
  }

  @override
  Future<Result<void, AppError>> saveQueue(PlaybackQueueState state, {String? profileId}) async {
    try {
      final pid = _resolveProfile(profileId);

      await db.transaction(() async {
        await (db.delete(db.dbQueueEntries)..where((tbl) => tbl.profileId.equals(pid))).go();

        for (int i = 0; i < state.items.length; i++) {
          final item = state.items[i];
          await db.into(db.dbQueueEntries).insert(
                DbQueueEntriesCompanion.insert(
                  id: item.id.isNotEmpty ? item.id : 'q_${pid}_$i',
                  profileId: Value(pid),
                  trackId: item.trackId,
                  position: i,
                ),
              );
        }

        await db.into(db.dbQueueState).insertOnConflictUpdate(
              DbQueueStateCompanion.insert(
                profileId: Value(pid),
                currentIndex: Value(state.currentIndex),
                repeatMode: Value(state.repeatMode.name),
                isShuffle: Value(state.isShuffle),
                positionMs: Value(state.position.inMilliseconds),
                isPlaying: Value(state.isPlaying && state.currentIndex >= 0),
                speed: Value(state.speed.clamp(0.25, 4.0)),
              ),
            );
      });

      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to persist queue: $e', cause: st));
    }
  }

  @override
  Stream<PlaybackQueueState> watchQueue({String? profileId}) {
    final pid = _resolveProfile(profileId);

    // Both tables must trigger rebuilds: entry mutations and state mutations
    // each separately produce a consistent re-loaded snapshot.
    final entriesWatch = (db.select(db.dbQueueEntries)
          ..where((tbl) => tbl.profileId.equals(pid)))
        .watch();
    final stateWatch =
        (db.select(db.dbQueueState)..where((tbl) => tbl.profileId.equals(pid))).watch();

    return MergeStream([entriesWatch, stateWatch])
        .asyncMap((_) => _loadQueueState(pid))
        .asBroadcastStream();
  }

  Future<PlaybackQueueState> _loadQueueState(String pid) async {
    final res = await loadQueue(profileId: pid);
    return res.dataOrNull ?? PlaybackQueueState.initial();
  }

  @override
  Future<Result<void, AppError>> clearQueue({String? profileId}) async {
    try {
      final pid = _resolveProfile(profileId);
      await db.transaction(() async {
        await (db.delete(db.dbQueueEntries)..where((tbl) => tbl.profileId.equals(pid))).go();
        await db.delete(db.dbQueueState).go();
      });
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to clear queue: $e', cause: st));
    }
  }
}
