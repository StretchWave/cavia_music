import 'package:drift/drift.dart';
import '../../domain/models/playlist.dart';
import '../../domain/models/playlist_entry.dart';
import '../../domain/models/track.dart';
import '../../domain/models/sync_operation.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/result/result.dart';
import '../../domain/result/app_error.dart';
import '../database/cavia_database.dart';

class LocalPlaylistRepository implements PlaylistRepository {
  final CaviaDatabase db;
  final SyncRepository? syncRepository;

  LocalPlaylistRepository(this.db, {this.syncRepository});

  String _resolveProfile(String? profileId) => profileId ?? 'guest';

  Playlist _mapDbPlaylist(DbPlaylist row, int count, [List<Song> songs = const []]) {
    return Playlist(
      id: row.id,
      profileId: row.profileId,
      name: row.name,
      description: row.description,
      artworkUri: row.artworkUri,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isSystem: row.isSystem,
      isDeleted: row.isDeleted,
      trackCount: count,
      songs: songs,
    );
  }

  @override
  Stream<List<Playlist>> watchPlaylists({String? profileId}) {
    final pid = _resolveProfile(profileId);

    // Watch non-deleted playlists for this profile
    final playlistQuery = db.select(db.dbPlaylists)
      ..where((tbl) => tbl.profileId.equals(pid) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.updatedAt, mode: OrderingMode.desc)]);

    return playlistQuery.watch().asyncMap((playlists) async {
      final results = <Playlist>[];
      for (final p in playlists) {
        final entriesResult = await getPlaylistEntries(p.id);
        final songs = entriesResult.isSuccess
            ? entriesResult.dataOrNull!.where((e) => e.track != null).map((e) => e.track!).toList()
            : <Song>[];
        results.add(_mapDbPlaylist(p, songs.length, songs));
      }
      return results;
    });
  }

  @override
  Future<Result<List<Playlist>, AppError>> getAllPlaylists({String? profileId}) async {
    try {
      final pid = _resolveProfile(profileId);
      final playlists = await (db.select(db.dbPlaylists)
            ..where((tbl) => tbl.profileId.equals(pid) & tbl.isDeleted.equals(false))
            ..orderBy([(tbl) => OrderingTerm(expression: tbl.updatedAt, mode: OrderingMode.desc)]))
          .get();

      final results = <Playlist>[];
      for (final p in playlists) {
        final entriesResult = await getPlaylistEntries(p.id);
        final songs = entriesResult.isSuccess
            ? entriesResult.dataOrNull!.where((e) => e.track != null).map((e) => e.track!).toList()
            : <Song>[];
        results.add(_mapDbPlaylist(p, songs.length, songs));
      }
      return Result.success(results);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to query playlists: $e', cause: st));
    }
  }

  @override
  Future<Result<Playlist, AppError>> getPlaylistById(String id, {String? profileId}) async {
    try {
      final p = await (db.select(db.dbPlaylists)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      if (p == null || p.isDeleted) {
        return Result.failure(NotFoundError('Playlist not found with id $id'));
      }
      final entriesResult = await getPlaylistEntries(p.id);
      final songs = entriesResult.isSuccess
          ? entriesResult.dataOrNull!.where((e) => e.track != null).map((e) => e.track!).toList()
          : <Song>[];
      return Result.success(_mapDbPlaylist(p, songs.length, songs));
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Error loading playlist: $e', cause: st));
    }
  }

  @override
  Stream<List<PlaylistEntry>> watchPlaylistEntries(String playlistId) {
    final query = (db.select(db.dbPlaylistEntries)
          ..where((tbl) => tbl.playlistId.equals(playlistId))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.position, mode: OrderingMode.asc)]))
        .join([
      innerJoin(db.dbTracks, db.dbTracks.id.equalsExp(db.dbPlaylistEntries.trackId)),
      leftOuterJoin(
        db.dbLikedSongs,
        db.dbLikedSongs.trackId.equalsExp(db.dbTracks.id),
      ),
    ]);

    return query.watch().map((rows) {
      return rows.map((r) {
        final entry = r.readTable(db.dbPlaylistEntries);
        final trackRow = r.readTable(db.dbTracks);
        final isLiked = r.readTableOrNull(db.dbLikedSongs) != null;

        return PlaylistEntry(
          id: entry.id,
          playlistId: entry.playlistId,
          trackId: entry.trackId,
          position: entry.position,
          dateAdded: entry.dateAdded,
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
    });
  }

  @override
  Future<Result<List<PlaylistEntry>, AppError>> getPlaylistEntries(String playlistId) async {
    try {
      final query = (db.select(db.dbPlaylistEntries)
            ..where((tbl) => tbl.playlistId.equals(playlistId))
            ..orderBy([(tbl) => OrderingTerm(expression: tbl.position, mode: OrderingMode.asc)]))
          .join([
        innerJoin(db.dbTracks, db.dbTracks.id.equalsExp(db.dbPlaylistEntries.trackId)),
        leftOuterJoin(
          db.dbLikedSongs,
          db.dbLikedSongs.trackId.equalsExp(db.dbTracks.id),
        ),
      ]);

      final rows = await query.get();
      final entries = rows.map((r) {
        final entry = r.readTable(db.dbPlaylistEntries);
        final trackRow = r.readTable(db.dbTracks);
        final isLiked = r.readTableOrNull(db.dbLikedSongs) != null;

        return PlaylistEntry(
          id: entry.id,
          playlistId: entry.playlistId,
          trackId: entry.trackId,
          position: entry.position,
          dateAdded: entry.dateAdded,
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

      return Result.success(entries);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Error loading playlist entries: $e', cause: st));
    }
  }

  @override
  Future<Result<Playlist, AppError>> createPlaylist(
    String name, {
    String description = '',
    List<String>? initialTrackIds,
    String? profileId,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return const Result.failure(ValidationError('Playlist name cannot be empty.'));
    }

    final pid = _resolveProfile(profileId);
    final now = DateTime.now();
    final playlistId = 'pl_${now.millisecondsSinceEpoch}_${trimmedName.hashCode.abs()}';

    try {
      return await db.transaction(() async {
        await db.into(db.dbPlaylists).insert(
              DbPlaylistsCompanion.insert(
                id: playlistId,
                profileId: Value(pid),
                name: trimmedName,
                description: Value(description.trim()),
                artworkUri: 'assets/images/cover_zenith.jpg',
                createdAt: now,
                updatedAt: now,
              ),
            );

        if (initialTrackIds != null && initialTrackIds.isNotEmpty) {
          for (int i = 0; i < initialTrackIds.length; i++) {
            await db.into(db.dbPlaylistEntries).insert(
                  DbPlaylistEntriesCompanion.insert(
                    id: 'pe_${playlistId}_$i',
                    playlistId: playlistId,
                    trackId: initialTrackIds[i],
                    position: i,
                    dateAdded: now,
                  ),
                );
          }
        }

        final playlist = Playlist(
          id: playlistId,
          profileId: pid,
          name: trimmedName,
          description: description.trim(),
          artworkUri: 'assets/images/cover_zenith.jpg',
          createdAt: now,
          updatedAt: now,
          trackCount: initialTrackIds?.length ?? 0,
        );

        if (syncRepository != null && pid != 'guest') {
          await syncRepository!.enqueueOperation(SyncOperation(
            id: 'sync_pl_${playlistId}_${now.millisecondsSinceEpoch}',
            profileId: pid,
            deviceId: 'local',
            entityType: SyncEntityType.playlist,
            entityId: playlistId,
            operationType: SyncOperationType.create,
            payload: {
              'name': trimmedName,
              'description': description.trim(),
              'artwork_uri': 'assets/images/cover_zenith.jpg',
              'revision': 1,
            },
            createdAt: now,
            idempotencyKey: 'op_create_pl_$playlistId',
          ));
        }

        return Result.success(playlist);
      });
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to create playlist: $e', cause: st));
    }
  }

  @override
  Future<Result<void, AppError>> editPlaylist(
    String playlistId, {
    String? name,
    String? description,
    String? artworkUri,
  }) async {
    if (name != null && name.trim().isEmpty) {
      return const Result.failure(ValidationError('Playlist name cannot be empty.'));
    }

    try {
      final now = DateTime.now();
      await (db.update(db.dbPlaylists)..where((tbl) => tbl.id.equals(playlistId))).write(
        DbPlaylistsCompanion(
          name: name != null ? Value(name.trim()) : const Value.absent(),
          description: description != null ? Value(description.trim()) : const Value.absent(),
          artworkUri: artworkUri != null ? Value(artworkUri) : const Value.absent(),
          updatedAt: Value(now),
        ),
      );

      if (syncRepository != null) {
        final existing = await (db.select(db.dbPlaylists)..where((tbl) => tbl.id.equals(playlistId))).getSingleOrNull();
        if (existing != null && existing.profileId != 'guest') {
          await syncRepository!.enqueueOperation(SyncOperation(
            id: 'sync_edit_pl_${playlistId}_${now.millisecondsSinceEpoch}',
            profileId: existing.profileId,
            deviceId: 'local',
            entityType: SyncEntityType.playlist,
            entityId: playlistId,
            operationType: SyncOperationType.update,
            payload: {
              'name': name?.trim() ?? existing.name,
              'description': description?.trim() ?? existing.description,
              'artwork_uri': artworkUri ?? existing.artworkUri,
              'revision': 1,
            },
            createdAt: now,
            idempotencyKey: 'op_edit_pl_${playlistId}_${now.millisecondsSinceEpoch}',
          ));
        }
      }

      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to edit playlist: $e', cause: st));
    }
  }

  @override
  Future<Result<void, AppError>> deletePlaylist(String playlistId) async {
    try {
      final existing = await (db.select(db.dbPlaylists)..where((tbl) => tbl.id.equals(playlistId))).getSingleOrNull();
      if (existing == null) {
        return Result.failure(NotFoundError('Playlist not found.'));
      }
      if (existing.isSystem) {
        return const Result.failure(OperationProhibitedError('System playlists cannot be deleted.'));
      }

      await db.transaction(() async {
        // Cascade delete entries
        await (db.delete(db.dbPlaylistEntries)..where((tbl) => tbl.playlistId.equals(playlistId))).go();
        // Delete playlist
        await (db.delete(db.dbPlaylists)..where((tbl) => tbl.id.equals(playlistId))).go();

        if (syncRepository != null && existing.profileId != 'guest') {
          await syncRepository!.enqueueOperation(SyncOperation(
            id: 'sync_del_pl_${playlistId}_${DateTime.now().millisecondsSinceEpoch}',
            profileId: existing.profileId,
            deviceId: 'local',
            entityType: SyncEntityType.playlist,
            entityId: playlistId,
            operationType: SyncOperationType.delete,
            payload: {'revision': 1},
            createdAt: DateTime.now(),
            idempotencyKey: 'op_del_pl_$playlistId',
          ));
        }
      });

      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to delete playlist: $e', cause: st));
    }
  }

  @override
  Future<Result<PlaylistEntry, AppError>> addTrackToPlaylist(String playlistId, String trackId) async {
    try {
      return await db.transaction(() async {
        final existing = await (db.select(db.dbPlaylists)..where((tbl) => tbl.id.equals(playlistId))).getSingleOrNull();
        if (existing == null) {
          return Result.failure(NotFoundError('Playlist not found.'));
        }

        // Get max position
        final maxPosQuery = db.selectOnly(db.dbPlaylistEntries)
          ..addColumns([db.dbPlaylistEntries.position.max()])
          ..where(db.dbPlaylistEntries.playlistId.equals(playlistId));
        final maxPos = await maxPosQuery.map((r) => r.read(db.dbPlaylistEntries.position.max())).getSingleOrNull();
        final newPosition = (maxPos ?? -1) + 1;

        final now = DateTime.now();
        final entryId = 'pe_${playlistId}_${now.millisecondsSinceEpoch}_$newPosition';

        await db.into(db.dbPlaylistEntries).insert(
              DbPlaylistEntriesCompanion.insert(
                id: entryId,
                playlistId: playlistId,
                trackId: trackId,
                position: newPosition,
                dateAdded: now,
              ),
            );

        // Update playlist updated_at timestamp
        await (db.update(db.dbPlaylists)..where((tbl) => tbl.id.equals(playlistId))).write(
          DbPlaylistsCompanion(updatedAt: Value(now)),
        );

        final entry = PlaylistEntry(
          id: entryId,
          playlistId: playlistId,
          trackId: trackId,
          position: newPosition,
          dateAdded: now,
        );

        if (syncRepository != null && existing.profileId != 'guest') {
          await syncRepository!.enqueueOperation(SyncOperation(
            id: 'sync_pe_${entryId}_${now.millisecondsSinceEpoch}',
            profileId: existing.profileId,
            deviceId: 'local',
            entityType: SyncEntityType.playlistEntry,
            entityId: entryId,
            operationType: SyncOperationType.create,
            payload: {
              'playlist_id': playlistId,
              'track_id': trackId,
              'position': newPosition,
              'revision': 1,
            },
            createdAt: now,
            idempotencyKey: 'op_add_pe_$entryId',
          ));
        }

        return Result.success(entry);
      });
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to add track to playlist: $e', cause: st));
    }
  }

  @override
  Future<Result<void, AppError>> removeTrackFromPlaylist(String playlistId, String entryId) async {
    try {
      await db.transaction(() async {
        await (db.delete(db.dbPlaylistEntries)
              ..where((tbl) =>
                  tbl.playlistId.equals(playlistId) &
                  (tbl.id.equals(entryId) | tbl.trackId.equals(entryId))))
            .go();

        // Compact positions after removal
        final remaining = await (db.select(db.dbPlaylistEntries)
              ..where((tbl) => tbl.playlistId.equals(playlistId))
              ..orderBy([(tbl) => OrderingTerm(expression: tbl.position, mode: OrderingMode.asc)]))
            .get();

        for (int i = 0; i < remaining.length; i++) {
          if (remaining[i].position != i) {
            await (db.update(db.dbPlaylistEntries)..where((tbl) => tbl.id.equals(remaining[i].id))).write(
              DbPlaylistEntriesCompanion(position: Value(i)),
            );
          }
        }

        await (db.update(db.dbPlaylists)..where((tbl) => tbl.id.equals(playlistId))).write(
          DbPlaylistsCompanion(updatedAt: Value(DateTime.now())),
        );

        if (syncRepository != null) {
          final existing = await (db.select(db.dbPlaylists)..where((tbl) => tbl.id.equals(playlistId))).getSingleOrNull();
          if (existing != null && existing.profileId != 'guest') {
            await syncRepository!.enqueueOperation(SyncOperation(
              id: 'sync_del_pe_${entryId}_${DateTime.now().millisecondsSinceEpoch}',
              profileId: existing.profileId,
              deviceId: 'local',
              entityType: SyncEntityType.playlistEntry,
              entityId: entryId,
              operationType: SyncOperationType.delete,
              payload: {'playlist_id': playlistId, 'revision': 1},
              createdAt: DateTime.now(),
              idempotencyKey: 'op_del_pe_${playlistId}_$entryId',
            ));
          }
        }
      });

      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to remove track: $e', cause: st));
    }
  }

  @override
  Future<Result<void, AppError>> reorderPlaylistEntries(
    String playlistId,
    int oldPosition,
    int newPosition,
  ) async {
    try {
      return await db.transaction(() async {
        final entries = await (db.select(db.dbPlaylistEntries)
              ..where((tbl) => tbl.playlistId.equals(playlistId))
              ..orderBy([(tbl) => OrderingTerm(expression: tbl.position, mode: OrderingMode.asc)]))
            .get();

        if (oldPosition < 0 || oldPosition >= entries.length) {
          return const Result.failure(ValidationError('Invalid old position'));
        }

        final mutable = List<DbPlaylistEntry>.from(entries);
        if (oldPosition < newPosition) {
          newPosition -= 1;
        }
        newPosition = newPosition.clamp(0, mutable.length - 1);

        final moved = mutable.removeAt(oldPosition);
        mutable.insert(newPosition, moved);

        for (int i = 0; i < mutable.length; i++) {
          await (db.update(db.dbPlaylistEntries)..where((tbl) => tbl.id.equals(mutable[i].id))).write(
            DbPlaylistEntriesCompanion(position: Value(i)),
          );
        }

        await (db.update(db.dbPlaylists)..where((tbl) => tbl.id.equals(playlistId))).write(
          DbPlaylistsCompanion(updatedAt: Value(DateTime.now())),
        );

        if (syncRepository != null) {
          final existing = await (db.select(db.dbPlaylists)..where((tbl) => tbl.id.equals(playlistId))).getSingleOrNull();
          if (existing != null && existing.profileId != 'guest') {
            await syncRepository!.enqueueOperation(SyncOperation(
              id: 'sync_reorder_pl_${playlistId}_${DateTime.now().millisecondsSinceEpoch}',
              profileId: existing.profileId,
              deviceId: 'local',
              entityType: SyncEntityType.playlist,
              entityId: playlistId,
              operationType: SyncOperationType.reorder,
              payload: {'old_position': oldPosition, 'new_position': newPosition, 'revision': 1},
              createdAt: DateTime.now(),
              idempotencyKey: 'op_reorder_pl_${playlistId}_${DateTime.now().millisecondsSinceEpoch}',
            ));
          }
        }

        return const Result.success(null);
      });
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to reorder playlist: $e', cause: st));
    }
  }
}
