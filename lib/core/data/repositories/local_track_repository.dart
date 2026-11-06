import 'dart:convert';
import 'package:drift/drift.dart';
import '../../domain/models/track.dart';
import '../../domain/models/sync_operation.dart';
import '../../domain/repositories/track_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/result/result.dart';
import '../../domain/result/app_error.dart';
import '../database/cavia_database.dart';

class LocalTrackRepository implements TrackRepository {
  final CaviaDatabase db;
  final SyncRepository? syncRepository;

  LocalTrackRepository(this.db, {this.syncRepository});

  String _resolveProfile(String? profileId) => profileId ?? 'guest';

  Track _mapDbToDomain(DbTrack row, bool isLiked) {
    List<String> artists = [];
    try {
      final decoded = jsonDecode(row.artistsJson);
      if (decoded is List) artists = decoded.map((e) => e.toString()).toList();
    } catch (_) {}

    List<LyricLine> lyrics = [];
    try {
      final decoded = jsonDecode(row.lyricsJson);
      if (decoded is List) {
        lyrics = decoded
            .map((e) => LyricLine.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    return Track(
      id: row.id,
      providerId: row.providerId,
      providerTrackId: row.providerTrackId,
      title: row.title,
      artist: row.artist,
      artists: artists,
      album: row.album,
      duration: Duration(milliseconds: row.durationMs),
      artworkUri: row.artworkUri,
      isrc: row.isrc,
      explicit: row.explicit,
      availabilityState: switch (row.availabilityState) {
        'unavailable' => TrackAvailability.unavailable,
        'restricted' => TrackAvailability.restricted,
        _ => TrackAvailability.available,
      },
      sourceAttribution: row.sourceAttribution,
      dateAdded: row.dateAdded,
      isLiked: isLiked,
      isCached: row.isCached,
      localCachePath: row.localCachePath,
      lyrics: lyrics,
    );
  }

  @override
  Future<Result<List<Track>, AppError>> getAllTracks({String? profileId}) async {
    try {
      final pid = _resolveProfile(profileId);
      final query = db.select(db.dbTracks).join([
        leftOuterJoin(
          db.dbLikedSongs,
          db.dbLikedSongs.trackId.equalsExp(db.dbTracks.id) &
              db.dbLikedSongs.profileId.equals(pid),
        ),
      ]);

      final rows = await query.get();
      final tracks = rows.map((r) {
        final trackRow = r.readTable(db.dbTracks);
        final likedRow = r.readTableOrNull(db.dbLikedSongs);
        return _mapDbToDomain(trackRow, likedRow != null);
      }).toList();

      return Result.success(tracks);
    } catch (e, st) {
      return Result.failure(DatabaseError(
        details: 'Failed to query all tracks: $e',
        cause: st,
      ));
    }
  }

  @override
  Stream<List<Track>> watchTracks({String? profileId}) {
    final pid = _resolveProfile(profileId);
    final query = db.select(db.dbTracks).join([
      leftOuterJoin(
        db.dbLikedSongs,
        db.dbLikedSongs.trackId.equalsExp(db.dbTracks.id) &
            db.dbLikedSongs.profileId.equals(pid),
      ),
    ]);

    return query.watch().map((rows) {
      return rows.map((r) {
        final trackRow = r.readTable(db.dbTracks);
        final likedRow = r.readTableOrNull(db.dbLikedSongs);
        return _mapDbToDomain(trackRow, likedRow != null);
      }).toList();
    });
  }

  @override
  Stream<List<Track>> watchLikedTracks({String? profileId}) {
    final pid = _resolveProfile(profileId);
    final query = (db.select(db.dbLikedSongs)..where((tbl) => tbl.profileId.equals(pid)))
        .join([
      innerJoin(
        db.dbTracks,
        db.dbTracks.id.equalsExp(db.dbLikedSongs.trackId),
      ),
    ]);

    return query.watch().map((rows) {
      return rows.map((r) {
        final trackRow = r.readTable(db.dbTracks);
        return _mapDbToDomain(trackRow, true);
      }).toList();
    });
  }

  @override
  Future<Result<Track, AppError>> getTrackById(String id, {String? profileId}) async {
    try {
      final pid = _resolveProfile(profileId);
      final query = (db.select(db.dbTracks)..where((tbl) => tbl.id.equals(id))).join([
        leftOuterJoin(
          db.dbLikedSongs,
          db.dbLikedSongs.trackId.equalsExp(db.dbTracks.id) &
              db.dbLikedSongs.profileId.equals(pid),
        ),
      ]);

      final row = await query.getSingleOrNull();
      if (row == null) {
        return Result.failure(NotFoundError('Track not found with id $id'));
      }

      final trackRow = row.readTable(db.dbTracks);
      final likedRow = row.readTableOrNull(db.dbLikedSongs);
      return Result.success(_mapDbToDomain(trackRow, likedRow != null));
    } catch (e, st) {
      return Result.failure(DatabaseError(
        details: 'Failed to get track $id: $e',
        cause: st,
      ));
    }
  }

  @override
  Future<Result<bool, AppError>> isTrackLiked(String trackId, {String? profileId}) async {
    try {
      final pid = _resolveProfile(profileId);
      final existing = await (db.select(db.dbLikedSongs)
            ..where((tbl) => tbl.profileId.equals(pid) & tbl.trackId.equals(trackId)))
          .getSingleOrNull();
      return Result.success(existing != null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Error checking liked status: $e', cause: st));
    }
  }

  @override
  Future<Result<bool, AppError>> toggleLike(String trackId, {String? profileId}) async {
    final pid = _resolveProfile(profileId);
    try {
      return await db.transaction(() async {
        final existing = await (db.select(db.dbLikedSongs)
              ..where((tbl) => tbl.profileId.equals(pid) & tbl.trackId.equals(trackId)))
            .getSingleOrNull();

        final isNowLiked = existing == null;
        if (existing != null) {
          // Unlike
          await (db.delete(db.dbLikedSongs)
                ..where((tbl) => tbl.profileId.equals(pid) & tbl.trackId.equals(trackId)))
              .go();
        } else {
          // Like
          await db.into(db.dbLikedSongs).insert(
                DbLikedSongsCompanion.insert(
                  profileId: Value(pid),
                  trackId: trackId,
                  dateLiked: DateTime.now(),
                ),
                mode: InsertMode.insertOrIgnore, // Prevent duplicates
              );
        }

        if (syncRepository != null && pid != 'guest') {
          final now = DateTime.now();
          await syncRepository!.enqueueOperation(SyncOperation(
            id: 'sync_like_${trackId}_${now.millisecondsSinceEpoch}',
            profileId: pid,
            deviceId: 'local',
            entityType: SyncEntityType.likedTrack,
            entityId: trackId,
            operationType: isNowLiked ? SyncOperationType.create : SyncOperationType.delete,
            payload: {
              'is_liked': isNowLiked,
              'revision': 1,
            },
            createdAt: now,
            idempotencyKey: 'op_like_${pid}_${trackId}_${now.millisecondsSinceEpoch}',
          ));
        }

        return Result.success(isNowLiked);
      });
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to toggle like: $e', cause: st));
    }
  }

  @override
  Future<Result<void, AppError>> updatePlayStats(String trackId, Duration position, {String? profileId}) async {
    try {
      await (db.update(db.dbTracks)..where((tbl) => tbl.id.equals(trackId))).write(
        DbTracksCompanion(
          playCount: const Value.absent(), // Handled or incremented
          lastPlayedAt: Value(DateTime.now()),
        ),
      );
      await db.customStatement(
        'UPDATE tracks SET play_count = play_count + 1 WHERE id = ?',
        [trackId],
      );
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to update play stats: $e', cause: st));
    }
  }

  @override
  Future<Result<void, AppError>> insertTrack(Track track, {String? profileId}) async {
    try {
      await db.into(db.dbTracks).insertOnConflictUpdate(
            DbTracksCompanion.insert(
              id: track.id,
              providerId: Value(track.providerId),
              providerTrackId: Value(track.providerTrackId),
              title: track.title,
              artist: track.artist,
              artistsJson: Value(jsonEncode(track.artists)),
              album: track.album,
              durationMs: track.duration.inMilliseconds,
              artworkUri: track.artworkUri,
              isrc: Value(track.isrc),
              explicit: Value(track.explicit),
              availabilityState: Value(track.availabilityState.name),
              sourceAttribution: Value(track.sourceAttribution),
              dateAdded: track.dateAdded,
              isCached: Value(track.isCached),
              localCachePath: Value(track.localCachePath),
              lyricsJson: Value(jsonEncode(track.lyrics.map((l) => l.toJson()).toList())),
            ),
          );
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to insert track: $e', cause: st));
    }
  }
}

