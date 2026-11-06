import 'package:drift/drift.dart';
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

  @override
  Future<Result<PlaybackQueueState, AppError>> loadQueue({String? profileId}) async {
    try {
      final pid = _resolveProfile(profileId);

      final stateRow = await (db.select(db.dbQueueState)..where((tbl) => tbl.profileId.equals(pid))).getSingleOrNull();

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
      final items = rows.map((r) {
        final qEntry = r.readTable(db.dbQueueEntries);
        final trackRow = r.readTable(db.dbTracks);
        final isLiked = r.readTableOrNull(db.dbLikedSongs) != null;

        return QueueItem(
          id: qEntry.id,
          trackId: qEntry.trackId,
          position: qEntry.position,
          track: Track(
            id: trackRow.id,
            providerId: trackRow.providerId,
            providerTrackId: trackRow.providerTrackId,
            title: trackRow.title,
            artist: trackRow.artist,
            album: trackRow.album,
            duration: Duration(milliseconds: trackRow.durationMs),
            artworkUri: trackRow.artworkUri,
            dateAdded: trackRow.dateAdded,
            isLiked: isLiked,
            isCached: trackRow.isCached,
          ),
        );
      }).toList();

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
        isPlaying: stateRow?.isPlaying ?? false,
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
        // Clear previous queue entries for this profile
        await (db.delete(db.dbQueueEntries)..where((tbl) => tbl.profileId.equals(pid))).go();

        // Insert new entries
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

        // Upsert state
        await db.into(db.dbQueueState).insertOnConflictUpdate(
              DbQueueStateCompanion.insert(
                profileId: Value(pid),
                currentIndex: Value(state.currentIndex),
                repeatMode: Value(state.repeatMode.name),
                isShuffle: Value(state.isShuffle),
                positionMs: Value(state.position.inMilliseconds),
                isPlaying: Value(state.isPlaying),
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

    return db.select(db.dbQueueState).watch().asyncMap((_) async {
      final res = await loadQueue(profileId: pid);
      return res.dataOrNull ?? PlaybackQueueState.initial();
    });
  }

  @override
  Future<Result<void, AppError>> clearQueue({String? profileId}) async {
    try {
      final pid = _resolveProfile(profileId);
      await db.transaction(() async {
        await (db.delete(db.dbQueueEntries)..where((tbl) => tbl.profileId.equals(pid))).go();
        await (db.update(db.dbQueueState)..where((tbl) => tbl.profileId.equals(pid))).write(
          const DbQueueStateCompanion(
            currentIndex: Value(-1),
            positionMs: Value(0),
            isPlaying: Value(false),
          ),
        );
      });
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to clear queue: $e', cause: st));
    }
  }
}

