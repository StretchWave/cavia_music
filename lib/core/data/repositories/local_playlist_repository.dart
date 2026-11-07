import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/playlist.dart';
import '../../domain/models/playlist_entry.dart';
import '../../domain/models/track.dart';
import '../../domain/models/sync_operation.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/result/app_error.dart';
import '../../domain/result/result.dart';
import '../database/cavia_database.dart';

/// SQLite-backed implementation of [PlaylistRepository].
///
/// Every playlist and entry key is a UUID so rows can be pushed to the
/// PostgreSQL cloud schema unchanged. All syncing mutations are recorded in
/// the durable outbox *inside the same transaction* as the local write, so a
/// crash can never produce a silently un-synced mutation.
class LocalPlaylistRepository implements PlaylistRepository {
  final CaviaDatabase db;
  final SyncRepository? syncRepository;

  /// Stable identity of THIS device for cloud-sync receipts.
  final String deviceId;

  LocalPlaylistRepository(this.db, {this.syncRepository, String? deviceId})
      : deviceId = deviceId ?? const Uuid().v4();

  static const Uuid _uuid = Uuid();

  static String _resolveProfile(String? profileId) => profileId ?? 'guest';

  static const String fallbackArtwork = 'assets/images/cover_zenith.jpg';

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

  Future<PlaylistEntry> _mapEntryRow(TypedResult r, String pid) async {
    final entry = r.readTable(db.dbPlaylistEntries);
    final trackRow = r.readTable(db.dbTracks);
    final isLiked = r.readTableOrNull(db.dbLikedSongs) != null;
    return PlaylistEntry(
      id: entry.id,
      playlistId: entry.playlistId,
      trackId: entry.trackId,
      position: entry.position,
      dateAdded: entry.dateAdded,
      track: _trackRowToTrack(trackRow, isLiked),
    );
  }

  Track _trackRowToTrack(DbTrack trackRow, bool isLiked) {
    final artists = trackRow.artistsJson == '[]'
        ? [trackRow.artist]
        : List<String>.from((jsonDecode(trackRow.artistsJson) as List).map((e) => e.toString()));
    return Track(
      id: trackRow.id,
      providerId: trackRow.providerId,
      providerTrackId: trackRow.providerTrackId,
      title: trackRow.title,
      artist: trackRow.artist,
      artists: artists,
      album: trackRow.album,
      albumArtist: trackRow.albumArtist,
      duration: Duration(milliseconds: trackRow.durationMs),
      artworkUri: trackRow.artworkUri,
      isrc: trackRow.isrc,
      explicit: trackRow.explicit,
      trackNumber: trackRow.trackNumber,
      discNumber: trackRow.discNumber,
      releaseYear: trackRow.releaseYear,
      genre: trackRow.genre,
      filePath: trackRow.filePath,
      fileFormat: trackRow.fileFormat,
      fileSizeBytes: trackRow.fileSizeBytes,
      dateAdded: trackRow.dateAdded,
      isLiked: isLiked,
      isCached: trackRow.isCached,
      localCachePath: trackRow.localCachePath,
      lyrics: _decodeLyrics(trackRow.lyricsJson),
      playCount: trackRow.playCount,
      lastPlayedAt: trackRow.lastPlayedAt,
    );
  }

  List<LyricLine> _decodeLyrics(String raw) {
    if (raw == '[]' || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(LyricLine.fromJson)
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  /// LEFT JOIN bringing in per-profile liked status for playlist tracks.
  /// (Kept inline per-query; drift's join builder is not a first-class type.)

  @override
  Stream<List<Playlist>> watchPlaylists({String? profileId}) {
    final pid = _resolveProfile(profileId);
    final playlistQuery = db.select(db.dbPlaylists)
      ..where((tbl) => tbl.profileId.equals(pid) & tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.updatedAt, mode: OrderingMode.desc)]);

    return playlistQuery.watch().asyncMap((playlists) async {
      if (playlists.isEmpty) return const <Playlist>[];
      // One batched query for every playlist's entry count.
      final counts = await db.customSelect(
        'SELECT playlist_id, COUNT(*) AS c FROM ${db.dbPlaylistEntries.actualTableName} WHERE playlist_id IN (${List.filled(playlists.length, '?').join(', ')}) GROUP BY playlist_id',
        variables: playlists.map((p) => Variable(p.id)).toList(),
      ).get();
      final countMap = {for (final row in counts) row.data['playlist_id'] as String: row.data['c'] as int};
      return playlists.map((p) => _mapDbPlaylist(p, countMap[p.id] ?? 0)).toList();
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
        final entries = await (db.select(db.dbPlaylistEntries)
              ..where((tbl) => tbl.playlistId.equals(p.id)))
            .get();
        results.add(_mapDbPlaylist(p, entries.length));
      }
      return Result.success(results);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to query playlists: $e', cause: st));
    }
  }

  @override
  Future<Result<Playlist, AppError>> getPlaylistById(String id, {String? profileId}) async {
    try {
      final p =
          await (db.select(db.dbPlaylists)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
      if (p == null || p.isDeleted) {
        return Result.failure(NotFoundError('Playlist not found with id $id'));
      }
      final entries = await (db.select(db.dbPlaylistEntries)
            ..where((tbl) => tbl.playlistId.equals(p.id)))
          .get();
      return Result.success(_mapDbPlaylist(p, entries.length));
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Error loading playlist: $e', cause: st));
    }
  }

  @override
  Stream<List<PlaylistEntry>> watchPlaylistEntries(String playlistId, {String? profileId}) {
    final pid = _resolveProfile(profileId);
    final query = (db.select(db.dbPlaylistEntries)
          ..where((tbl) => tbl.playlistId.equals(playlistId))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.position, mode: OrderingMode.asc)]))
        .join([
      innerJoin(db.dbTracks, db.dbTracks.id.equalsExp(db.dbPlaylistEntries.trackId)),
      leftOuterJoin(
        db.dbLikedSongs,
        db.dbLikedSongs.trackId.equalsExp(db.dbTracks.id) & db.dbLikedSongs.profileId.equals(pid),
      ),
    ]);

    return query.watch().asyncMap((rows) async {
      final entries = <PlaylistEntry>[];
      for (final r in rows) {
        entries.add(await _mapEntryRow(r, pid));
      }
      return entries;
    });
  }

  @override
  Future<Result<List<PlaylistEntry>, AppError>> getPlaylistEntries(String playlistId, {String? profileId}) async {
    try {
      final pid = _resolveProfile(profileId);
      final query = (db.select(db.dbPlaylistEntries)
            ..where((tbl) => tbl.playlistId.equals(playlistId))
            ..orderBy([(tbl) => OrderingTerm(expression: tbl.position, mode: OrderingMode.asc)]))
          .join([
        innerJoin(db.dbTracks, db.dbTracks.id.equalsExp(db.dbPlaylistEntries.trackId)),
        leftOuterJoin(
          db.dbLikedSongs,
          db.dbLikedSongs.trackId.equalsExp(db.dbTracks.id) & db.dbLikedSongs.profileId.equals(pid),
        ),
      ]);

      final rows = await query.get();
      final entries = <PlaylistEntry>[];
      for (final r in rows) {
        entries.add(await _mapEntryRow(r, pid));
      }
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
    String? sourceProvider,
    String? sourcePlaylistId,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      return const Result.failure(ValidationError('Playlist name cannot be empty.'));
    }

    final pid = _resolveProfile(profileId);
    final now = DateTime.now().toUtc();
    final playlistId = _uuid.v4();

    try {
      return await db.transaction(() async {
        await db.into(db.dbPlaylists).insert(
              DbPlaylistsCompanion.insert(
                id: playlistId,
                profileId: Value(pid),
                name: trimmedName,
                description: Value(description.trim()),
                artworkUri: fallbackArtwork,
                createdAt: now,
                updatedAt: now,
                revision: const Value(1),
                sourceProvider: Value(sourceProvider),
                sourcePlaylistId: Value(sourcePlaylistId),
              ),
            );

        if (initialTrackIds != null && initialTrackIds.isNotEmpty) {
          for (int i = 0; i < initialTrackIds.length; i++) {
            await db.into(db.dbPlaylistEntries).insert(
                  DbPlaylistEntriesCompanion.insert(
                    id: _uuid.v4(),
                    playlistId: playlistId,
                    trackId: initialTrackIds[i],
                    position: i,
                    dateAdded: now,
                    revision: const Value(1),
                  ),
                );
          }
        }

        final playlist = Playlist(
          id: playlistId,
          profileId: pid,
          name: trimmedName,
          description: description.trim(),
          artworkUri: fallbackArtwork,
          createdAt: now,
          updatedAt: now,
          trackCount: initialTrackIds?.length ?? 0,
        );

        if (syncRepository != null && pid != 'guest') {
          await syncRepository!.enqueueOperation(SyncOperation(
            id: 'sync_pl_${_uuid.v4()}',
            profileId: pid,
            deviceId: deviceId,
            entityType: SyncEntityType.playlist,
            entityId: playlistId,
            operationType: SyncOperationType.create,
            payload: {
              'name': trimmedName,
              'description': description.trim(),
              'artwork_uri': fallbackArtwork,
              'revision': 1,
              'updated_at': now.toIso8601String(),
              'source_provider': ?sourceProvider,
              'source_playlist_id': ?sourcePlaylistId,
            },
            createdAt: now,
            idempotencyKey: 'op_create_pl_${playlistId}_1',
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
      final txResult = await db.transaction<Result<void, AppError>>(() async {
        final existing = await (db.select(db.dbPlaylists)
              ..where((tbl) => tbl.id.equals(playlistId)))
            .getSingleOrNull();
        if (existing == null) {
          return Result.failure(const NotFoundError('Playlist not found.'));
        }

        final now = DateTime.now().toUtc();
        final newRevision = existing.revision + 1;
        await (db.update(db.dbPlaylists)..where((tbl) => tbl.id.equals(playlistId))).write(
          DbPlaylistsCompanion(
            name: name != null ? Value(name.trim()) : const Value.absent(),
            description:
                description != null ? Value(description.trim()) : const Value.absent(),
            artworkUri: artworkUri != null ? Value(artworkUri) : const Value.absent(),
            updatedAt: Value(now),
            revision: Value(newRevision),
          ),
        );

        if (syncRepository != null && existing.profileId != 'guest') {
          await syncRepository!.enqueueOperation(SyncOperation(
            id: 'sync_edit_pl_${_uuid.v4()}',
            profileId: existing.profileId,
            deviceId: deviceId,
            entityType: SyncEntityType.playlist,
            entityId: playlistId,
            operationType: SyncOperationType.update,
            payload: {
              'name': name?.trim() ?? existing.name,
              'description': description?.trim() ?? existing.description,
              'artwork_uri': artworkUri ?? existing.artworkUri,
              'revision': newRevision,
              'updated_at': now.toIso8601String(),
            },
            createdAt: now,
            idempotencyKey: 'op_edit_pl_${playlistId}_$newRevision',
          ));
        }
        return const Result.success(null);
      });
      return txResult;
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to edit playlist: $e', cause: st));
    }
  }

  @override
  Future<Result<void, AppError>> deletePlaylist(String playlistId) async {
    try {
      final existing =
          await (db.select(db.dbPlaylists)..where((tbl) => tbl.id.equals(playlistId)))
              .getSingleOrNull();
      if (existing == null) {
        return Result.failure(NotFoundError('Playlist not found.'));
      }
      if (existing.isSystem) {
        return Result.failure(OperationProhibitedError('System playlists cannot be deleted.'));
      }

      await db.transaction(() async {
        // Tombstone first (prevents resurrection by a concurrent remote push).
        await _writeTombstone(existing.profileId, SyncEntityType.playlist, playlistId);

        // Cascade delete entries
        await (db.delete(db.dbPlaylistEntries)
              ..where((tbl) => tbl.playlistId.equals(playlistId)))
            .go();
        await (db.delete(db.dbPlaylists)..where((tbl) => tbl.id.equals(playlistId))).go();

        if (syncRepository != null && existing.profileId != 'guest') {
          await syncRepository!.enqueueOperation(SyncOperation(
            id: 'sync_del_pl_${_uuid.v4()}',
            profileId: existing.profileId,
            deviceId: deviceId,
            entityType: SyncEntityType.playlist,
            entityId: playlistId,
            operationType: SyncOperationType.delete,
            payload: {'revision': existing.revision + 1},
            createdAt: DateTime.now().toUtc(),
            idempotencyKey: 'op_del_pl_${playlistId}_${existing.revision + 1}',
          ));
        }
      });

      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to delete playlist: $e', cause: st));
    }
  }

  @override
  Future<Result<PlaylistEntry, AppError>> addTrackToPlaylist(
    String playlistId,
    String trackId, {
    bool allowDuplicates = true,
  }) async {
    try {
      return await db.transaction(() async {
        final existing =
            await (db.select(db.dbPlaylists)..where((tbl) => tbl.id.equals(playlistId)))
                .getSingleOrNull();
        if (existing == null) {
          return Result.failure(NotFoundError('Playlist not found.'));
        }

        if (!allowDuplicates) {
          final dupe = await (db.select(db.dbPlaylistEntries)
                ..where((tbl) =>
                    tbl.playlistId.equals(playlistId) & tbl.trackId.equals(trackId)))
              .get();
          if (dupe.isNotEmpty) {
            return Result.failure(DuplicateError('This song is already in the playlist.'));
          }
        }

        final maxPosQuery = db.selectOnly(db.dbPlaylistEntries)
          ..addColumns([db.dbPlaylistEntries.position.max()])
          ..where(db.dbPlaylistEntries.playlistId.equals(playlistId));
        final maxPos = await maxPosQuery
            .map((r) => r.read(db.dbPlaylistEntries.position.max()))
            .getSingleOrNull();
        final newPosition = (maxPos ?? -1) + 1;

        final now = DateTime.now().toUtc();
        final entryId = _uuid.v4();
        final newEntryRevision = 1;
        final newPlaylistRevision = existing.revision + 1;

        await db.into(db.dbPlaylistEntries).insert(
              DbPlaylistEntriesCompanion.insert(
                id: entryId,
                playlistId: playlistId,
                trackId: trackId,
                position: newPosition,
                dateAdded: now,
                revision: const Value(1),
              ),
            );

        await (db.update(db.dbPlaylists)..where((tbl) => tbl.id.equals(playlistId))).write(
          DbPlaylistsCompanion(updatedAt: Value(now), revision: Value(newPlaylistRevision)),
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
            id: 'sync_pe_${_uuid.v4()}',
            profileId: existing.profileId,
            deviceId: deviceId,
            entityType: SyncEntityType.playlistEntry,
            entityId: entryId,
            operationType: SyncOperationType.create,
            payload: {
              'playlist_id': playlistId,
              'track_id': trackId,
              'position': newPosition,
              'revision': newEntryRevision,
              'date_added': now.toIso8601String(),
            },
            createdAt: now,
            idempotencyKey: 'op_add_pe_${entryId}_1',
          ));
        }

        return Result.success(entry);
      });
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to add track to playlist: $e', cause: st));
    }
  }

  @override
  Future<Result<void, AppError>> removeTrackFromPlaylist(
    String playlistId,
    String entryId, {
    bool removeByTrackId = false,
  }) async {
    try {
      return await db.transaction(() async {
        final existing =
            await (db.select(db.dbPlaylists)..where((tbl) => tbl.id.equals(playlistId)))
                .getSingleOrNull();
        if (existing == null) {
          return Result.failure(NotFoundError('Playlist not found.'));
        }

        final target = await (db.select(db.dbPlaylistEntries)
              ..where((tbl) =>
                  tbl.playlistId.equals(playlistId) &
                  (removeByTrackId
                      ? tbl.trackId.equals(entryId)
                      : tbl.id.equals(entryId))))
            .get();
        if (target.isEmpty) {
          return Result.failure(NotFoundError('Entry not found in playlist.'));
        }

        await (db.delete(db.dbPlaylistEntries)
              ..where((tbl) =>
                  tbl.playlistId.equals(playlistId) &
                  (removeByTrackId
                      ? tbl.trackId.equals(entryId)
                      : tbl.id.equals(entryId))))
            .go();

        for (final row in target) {
          if (syncRepository != null && existing.profileId != 'guest') {
            await syncRepository!.enqueueOperation(SyncOperation(
              id: 'sync_del_pe_${_uuid.v4()}',
              profileId: existing.profileId,
              deviceId: deviceId,
              entityType: SyncEntityType.playlistEntry,
              entityId: row.id,
              operationType: SyncOperationType.delete,
              payload: {'playlist_id': playlistId, 'revision': row.revision + 1},
              createdAt: DateTime.now().toUtc(),
              idempotencyKey: 'op_del_pe_${row.id}_${row.revision + 1}',
            ));
          }
        }

        // Compact positions and sync the final layout deterministically.
        final reordered = await _compactPositions(playlistId);
        if (syncRepository != null && existing.profileId != 'guest' && reordered != null) {
          await syncRepository!.enqueueOperation(SyncOperation(
            id: 'sync_reorder_pl_${_uuid.v4()}',
            profileId: existing.profileId,
            deviceId: deviceId,
            entityType: SyncEntityType.playlist,
            entityId: playlistId,
            operationType: SyncOperationType.reorder,
            payload: {
              'order': reordered, // entry ids in final order
            },
            createdAt: DateTime.now().toUtc(),
            idempotencyKey: 'op_reorder_pl_${playlistId}_${existing.revision + 1}',
          ));
        }

        await (db.update(db.dbPlaylists)..where((tbl) => tbl.id.equals(playlistId))).write(
          DbPlaylistsCompanion(
            updatedAt: Value(DateTime.now().toUtc()),
            revision: Value(existing.revision + 1),
          ),
        );
        return const Result.success(null);
      });
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
          if (mutable[i].position != i) {
            await (db.update(db.dbPlaylistEntries)
                  ..where((tbl) => tbl.id.equals(mutable[i].id)))
                .write(DbPlaylistEntriesCompanion(position: Value(i)));
          }
        }

        final existing =
            await (db.select(db.dbPlaylists)..where((tbl) => tbl.id.equals(playlistId)))
                .getSingleOrNull();

        await (db.update(db.dbPlaylists)..where((tbl) => tbl.id.equals(playlistId))).write(
          DbPlaylistsCompanion(
            updatedAt: Value(DateTime.now().toUtc()),
            revision: Value((existing?.revision ?? 1) + 1),
          ),
        );

        if (syncRepository != null && existing != null && existing.profileId != 'guest') {
          await syncRepository!.enqueueOperation(SyncOperation(
            id: 'sync_reorder_pl_${_uuid.v4()}',
            profileId: existing.profileId,
            deviceId: deviceId,
            entityType: SyncEntityType.playlist,
            entityId: playlistId,
            operationType: SyncOperationType.reorder,
            payload: {
              'order': mutable.map((e) => e.id).toList(),
            },
            createdAt: DateTime.now().toUtc(),
            idempotencyKey: 'op_reorder_pl_${playlistId}_${existing.revision + 1}',
          ));
        }

        return const Result.success(null);
      });
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to reorder playlist: $e', cause: st));
    }
  }

  /// Rewrites positions to 0..n-1 in current order. Returns the entry ids in
  /// final order (for a deterministic cloud-sync payload).
  Future<List<String>?> _compactPositions(String playlistId) async {
    final remaining = await (db.select(db.dbPlaylistEntries)
          ..where((tbl) => tbl.playlistId.equals(playlistId))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.position, mode: OrderingMode.asc)]))
        .get();
    final order = <String>[];
    for (int i = 0; i < remaining.length; i++) {
      order.add(remaining[i].id);
      if (remaining[i].position != i) {
        await (db.update(db.dbPlaylistEntries)..where((tbl) => tbl.id.equals(remaining[i].id)))
            .write(DbPlaylistEntriesCompanion(position: Value(i)));
      }
    }
    return order;
  }

  Future<void> _writeTombstone(String pid, SyncEntityType type, String entityId) async {
    await db.into(db.dbTombstones).insert(
          DbTombstonesCompanion.insert(
            id: _uuid.v4(),
            profileId: pid,
            entityType: type.name,
            entityId: entityId,
            deletedAt: DateTime.now().toUtc(),
          ),
        );
  }
}
