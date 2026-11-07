import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/album.dart';
import '../../domain/models/artist.dart';
import '../../domain/models/sync_operation.dart';
import '../../domain/models/track.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/repositories/track_repository.dart';
import '../../domain/result/app_error.dart';
import '../../domain/result/result.dart';
import '../database/cavia_database.dart';

extension _FirstWhereOrNull<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final item in this) {
      if (test(item)) return item;
    }
    return null;
  }
}

/// SQLite-backed implementation of [TrackRepository].
///
/// Albums and artists are always *derived* from real track rows; their
/// `isSaved`/`isFollowed` flags plus artwork/year titles are reconciled into
/// lightweight helper tables only, so nothing can exist in the library pages
/// unless actual imported/liked tracks exist.
class LocalTrackRepository implements TrackRepository {
  final CaviaDatabase db;
  final SyncRepository? syncRepository;

  /// Stable identity of THIS device for cloud-sync receipts.
  final String deviceId;

  LocalTrackRepository(this.db, {this.syncRepository, String? deviceId})
      : deviceId = deviceId ?? const Uuid().v4();

  static String _resolveProfile(String? profileId) => profileId ?? 'guest';

  /// Stable identity for a derived album row.
  static String albumIdentityKey(String title, String displayArtist) =>
      'alb_${md5.convert(utf8.encode('${title.trim().toLowerCase()}|${displayArtist.trim().toLowerCase()}')).toString()}';

  /// Stable identity for a derived artist row.
  static String artistIdentityKey(String name) =>
      'art_${md5.convert(utf8.encode(name.trim().toLowerCase())).toString()}';

  // =========================================================================
  // Mapping
  // =========================================================================

  Track _mapDbToDomain(DbTrack row, bool isLiked) {
    List<String> artists = [];
    try {
      final decoded = jsonDecode(row.artistsJson);
      if (decoded is List) artists = decoded.map((e) => e.toString()).toList();
    } catch (_) {
      artists = [row.artist];
    }
    if (artists.isEmpty) artists = [row.artist];

    List<LyricLine> lyrics = [];
    try {
      final decoded = jsonDecode(row.lyricsJson);
      if (decoded is List) {
        lyrics = decoded
            .whereType<Map<String, dynamic>>()
            .map(LyricLine.fromJson)
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
      albumArtist: row.albumArtist,
      duration: Duration(milliseconds: row.durationMs),
      artworkUri: row.artworkUri,
      isrc: row.isrc,
      explicit: row.explicit,
      trackNumber: row.trackNumber,
      discNumber: row.discNumber,
      releaseYear: row.releaseYear,
      genre: row.genre,
      filePath: row.filePath,
      fileFormat: row.fileFormat,
      fileSizeBytes: row.fileSizeBytes,
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
      playCount: row.playCount,
      lastPlayedAt: row.lastPlayedAt,
    );
  }

  DbTracksCompanion _trackToCompanion(Track track) {
    final hasArtists = track.artists.isNotEmpty ? track.artists : [track.artist];
    return DbTracksCompanion.insert(
      id: track.id,
      providerId: Value(track.providerId),
      providerTrackId: Value(track.providerTrackId),
      title: track.title,
      artist: track.artist,
      artistsJson: Value(jsonEncode(hasArtists)),
      album: Value(track.album),
      albumArtist: Value(track.albumArtist),
      durationMs: track.duration.inMilliseconds,
      artworkUri: track.artworkUri,
      isrc: Value(track.isrc),
      explicit: Value(track.explicit),
      trackNumber: Value(track.trackNumber),
      discNumber: Value(track.discNumber),
      releaseYear: Value(track.releaseYear),
      genre: Value(track.genre),
      filePath: Value(track.filePath),
      fileFormat: Value(track.fileFormat),
      fileSizeBytes: Value(track.fileSizeBytes),
      availabilityState: Value(track.availabilityState.name),
      sourceAttribution: Value(track.sourceAttribution),
      dateAdded: track.dateAdded,
      isCached: Value(track.isCached),
      localCachePath: Value(track.localCachePath),
      lyricsJson: Value(jsonEncode(track.lyrics.map((l) => l.toJson()).toList())),
    );
  }

  Future<Track?> _fetchTrack(String id, String pid) async {
    final query = (db.select(db.dbTracks)..where((tbl) => tbl.id.equals(id))).join([
      leftOuterJoin(
        db.dbLikedSongs,
        db.dbLikedSongs.trackId.equalsExp(db.dbTracks.id) &
            db.dbLikedSongs.profileId.equals(pid),
      ),
    ]);
    final row = await query.getSingleOrNull();
    if (row == null) return null;
    final likedRow = row.readTableOrNull(db.dbLikedSongs);
    return _mapDbToDomain(row.readTable(db.dbTracks), likedRow != null);
  }

  @override
  Future<Result<void, AppError>> saveLyrics(
    String trackId,
    List<LyricLine> lines,
  ) async {
    try {
      final updated = await (db.update(db.dbTracks)
            ..where((tbl) => tbl.id.equals(trackId)))
          .write(DbTracksCompanion(
        lyricsJson: Value(jsonEncode(lines.map((l) => l.toJson()).toList())),
      ));

      if (updated == 0) {
        return Result.failure(NotFoundError('Track not found: $trackId'));
      }
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(
        userMessage: "Couldn't save lyrics for this track.",
        details: 'saveLyrics failed: $e',
        cause: st,
      ));
    }
  }

  // =========================================================================
  // Tracks
  // =========================================================================

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
      return Result.success(rows
          .map((r) {
            final trackRow = r.readTable(db.dbTracks);
            final likedRow = r.readTableOrNull(db.dbLikedSongs);
            return _mapDbToDomain(trackRow, likedRow != null);
          })
          .toList());
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to query all tracks: $e', cause: st));
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
    return query.watch().map((rows) => rows.map((r) {
          final trackRow = r.readTable(db.dbTracks);
          final likedRow = r.readTableOrNull(db.dbLikedSongs);
          return _mapDbToDomain(trackRow, likedRow != null);
        }).toList());
  }

  @override
  Stream<List<Track>> watchLikedTracks({String? profileId}) {
    final pid = _resolveProfile(profileId);
    final query =
        (db.select(db.dbLikedSongs)..where((tbl) => tbl.profileId.equals(pid))).join([
      innerJoin(db.dbTracks, db.dbTracks.id.equalsExp(db.dbLikedSongs.trackId)),
    ]);
    return query.watch().map((rows) => rows
        .map((r) => _mapDbToDomain(r.readTable(db.dbTracks), true))
        .toList());
  }

  @override
  Future<Result<Track, AppError>> getTrackById(String id, {String? profileId}) async {
    try {
      final track = await _fetchTrack(id, _resolveProfile(profileId));
      if (track == null) {
        return Result.failure(NotFoundError('Track not found with id $id'));
      }
      return Result.success(track);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to get track $id: $e', cause: st));
    }
  }

  @override
  Future<Result<List<Track>, AppError>> getRecentlyPlayed({
    int limit = 12,
    String? profileId,
  }) async {
    try {
      final pid = _resolveProfile(profileId);
      final query = (db.select(db.dbTracks)
            ..where((tbl) => tbl.lastPlayedAt.isNotNull())
            ..orderBy([
              (tbl) => OrderingTerm.desc(tbl.lastPlayedAt),
            ])
            ..limit(limit))
          .join([
        leftOuterJoin(
          db.dbLikedSongs,
          db.dbLikedSongs.trackId.equalsExp(db.dbTracks.id) &
              db.dbLikedSongs.profileId.equals(pid),
        ),
      ]);
      final rows = await query.get();
      return Result.success(rows.map((r) {
        final likedRow = r.readTableOrNull(db.dbLikedSongs);
        return _mapDbToDomain(r.readTable(db.dbTracks), likedRow != null);
      }).toList());
    } catch (e, st) {
      return Result.failure(
          DatabaseError(details: 'Failed to query recently played: $e', cause: st));
    }
  }

  @override
  Future<Result<List<Track>, AppError>> searchTracks(String query, {String? profileId}) async {
    try {
      final needle = query.trim().toLowerCase();
      if (needle.isEmpty) return const Result.success([]);
      final pid = _resolveProfile(profileId);
      final tracksResult = await getAllTracks(profileId: pid);
      if (tracksResult.isFailure) return Result.failure(tracksResult.errorOrNull!);
      final matches = tracksResult.dataOrNull!
          .where((t) =>
              t.title.toLowerCase().contains(needle) ||
              t.artist.toLowerCase().contains(needle) ||
              t.artists.any((a) => a.toLowerCase().contains(needle)) ||
              t.album.toLowerCase().contains(needle) ||
              (t.genre?.toLowerCase().contains(needle) ?? false))
          .toList();
      return Result.success(matches);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Track search failed: $e', cause: st));
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
        final now = DateTime.now();
        if (isNowLiked) {
          await db.into(db.dbLikedSongs).insertOnConflictUpdate(
                DbLikedSongsCompanion.insert(
                  profileId: Value(pid),
                  trackId: trackId,
                  dateLiked: now,
                ),
              );
        } else {
          await (db.delete(db.dbLikedSongs)
                ..where((tbl) => tbl.profileId.equals(pid) & tbl.trackId.equals(trackId)))
              .go();
        }

        await _enqueueLikeSync(pid, trackId, isNowLiked, now);

        return Result.success(isNowLiked);
      });
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to toggle like: $e', cause: st));
    }
  }

  Future<void> _enqueueLikeSync(
      String pid, String trackId, bool isNowLiked, DateTime now) async {
    final syncRepository = this.syncRepository;
    if (syncRepository == null || pid == 'guest') return;
    await syncRepository.enqueueOperation(SyncOperation(
      id: 'sync_like_${trackId}_${const Uuid().v4()}',
      profileId: pid,
      deviceId: deviceId,
      entityType: SyncEntityType.likedTrack,
      entityId: trackId,
      operationType:
          isNowLiked ? SyncOperationType.create : SyncOperationType.delete,
      payload: {
        'is_liked': isNowLiked,
        'revision': 1,
        'date_liked': now.toUtc().toIso8601String(),
      },
      createdAt: now,
      idempotencyKey: 'op_like_${pid}_${trackId}_${const Uuid().v4()}',
    ));
  }

  @override
  Future<Result<void, AppError>> updatePlayStats(String trackId, Duration position, {String? profileId}) async {
    try {
      await db.transaction(() async {
        await (db.update(db.dbTracks)..where((tbl) => tbl.id.equals(trackId))).write(
          DbTracksCompanion(
            playCount: const Value.absent(),
            lastPlayedAt: Value(DateTime.now()),
          ),
        );
        await db.customStatement(
          'UPDATE ${db.dbTracks.actualTableName} SET play_count = play_count + 1, last_played_at = ? WHERE id = ?',
          [DateTime.now().toIso8601String(), trackId],
        );
      });
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to update play stats: $e', cause: st));
    }
  }

  @override
  Future<Result<void, AppError>> insertTrack(Track track, {String? profileId}) async {
    try {
      await db.into(db.dbTracks).insertOnConflictUpdate(_trackToCompanion(track));
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to insert track: $e', cause: st));
    }
  }

  @override
  Future<Result<Track, AppError>> updateTrackMetadata(
    String trackId, {
    required String title,
    required String artist,
    String? album,
    String? genre,
    int? releaseYear,
    int? trackNumber,
    int? discNumber,
  }) async {
    try {
      final track = await _fetchTrack(trackId, _resolveProfile(null));
      if (track == null) {
        return Result.failure(NotFoundError('Track not found: $trackId'));
      }
      if (!track.isLocal) {
        return Result.failure(OperationProhibitedError(
            'Only locally imported tracks can have their metadata edited.'));
      }
      String? artistsJson;
      if (artist.contains(',') || track.artists.length > 1) {
        final list = artist
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
        artistsJson = jsonEncode(list);
      }
      final artists = artistsJson != null
          ? List<String>.from(jsonDecode(artistsJson) as List)
          : track.artists;

      await (db.update(db.dbTracks)..where((tbl) => tbl.id.equals(trackId))).write(
        DbTracksCompanion(
          title: Value(title.trim()),
          artist: Value(artist.trim()),
          artistsJson: Value(jsonEncode(
              artists.isNotEmpty ? artists : [artist.trim()])),
          album: Value(album ?? track.album),
          genre: Value(genre),
          releaseYear: Value(releaseYear),
          trackNumber: Value(trackNumber),
          discNumber: Value(discNumber),
        ),
      );
      final updated = await _fetchTrack(trackId, _resolveProfile(null));
      if (updated == null) {
        return const Result.failure(DatabaseError(details: 'Track disappeared after update'));
      }
      return Result.success(updated);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to update metadata: $e', cause: st));
    }
  }

  @override
  Future<Result<void, AppError>> removeTrack(String trackId, {String? profileId}) async {
    try {
      // FK cascade clears likes / queue rows / cache rows / playlist entries.
      // The original audio file is intentionally never deleted.
      await (db.delete(db.dbTracks)..where((tbl) => tbl.id.equals(trackId))).go();
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to remove track: $e', cause: st));
    }
  }

  @override
  Future<Result<bool, AppError>> trackExists(String trackId) async {
    try {
      final row = await (db.select(db.dbTracks)..where((tbl) => tbl.id.equals(trackId)))
          .getSingleOrNull();
      return Result.success(row != null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to check track existence: $e', cause: st));
    }
  }

  @override
  Future<Result<Track?, AppError>> findDuplicate(Track candidate, {String? profileId}) async {
    try {
      final tracksResult = await getAllTracks(profileId: profileId);
      if (tracksResult.isFailure) return Result.failure(tracksResult.errorOrNull!);
      final titleLc = candidate.title.trim().toLowerCase();
      final artistLc = candidate.artist.trim().toLowerCase();
      final durMs = candidate.duration.inMilliseconds;
      for (final t in tracksResult.dataOrNull!) {
        if (t.id == candidate.id) return Result.success(t);
        final tTitle = t.title.trim().toLowerCase();
        final tArtist = t.artist.trim().toLowerCase();
        if (tTitle == titleLc && tArtist == artistLc) {
          final delta = (t.duration.inMilliseconds - durMs).abs();
          if (delta <= 2000) return Result.success(t);
        }
      }
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Duplicate lookup failed: $e', cause: st));
    }
  }

  // =========================================================================
  // Albums (derived from track rows)
  // =========================================================================

  @override
  Future<Result<List<Album>, AppError>> getAlbums(
      {String? profileId, bool savedOnly = false}) async {
    try {
      final tracksResult = await getAllTracks(profileId: profileId);
      if (tracksResult.isFailure) return Result.failure(tracksResult.errorOrNull!);
      final albums = await _deriveAlbums(tracksResult.dataOrNull!);
      await _upsertAlbumHelperRows(albums);
      final result = savedOnly ? albums.where((a) => a.isSaved).toList() : albums;
      return Result.success(result);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to derive albums: $e', cause: st));
    }
  }

  @override
  Future<Result<Album, AppError>> getAlbum(String albumId, {String? profileId}) async {
    try {
      final result = await getAlbums(profileId: profileId);
      if (result.isFailure) return Result.failure(result.errorOrNull!);
      final match = result.dataOrNull!.where((a) => a.id == albumId).firstOrNull;
      if (match == null) {
        return Result.failure(NotFoundError('Album not found: $albumId'));
      }
      return Result.success(match);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to load album: $e', cause: st));
    }
  }

  @override
  Future<Result<bool, AppError>> toggleSaveAlbum(String albumId, {String? profileId}) async {
    try {
      return await db.transaction(() async {
        final existing =
            await (db.select(db.dbAlbums)..where((tbl) => tbl.id.equals(albumId)))
                .getSingleOrNull();
        final isNowSaved = existing?.isSaved != true;
        if (existing != null) {
          await (db.update(db.dbAlbums)..where((tbl) => tbl.id.equals(albumId)))
              .write(DbAlbumsCompanion(isSaved: Value(isNowSaved)));
        } else {
          final derived = await _deriveAlbums(
              (await getAllTracks(profileId: profileId)).dataOrNull ?? const []);
          final match = derived.where((a) => a.id == albumId).firstOrNull;
          if (match == null) {
            return Result.failure(NotFoundError('Album not found: $albumId'));
          }
          await db.into(db.dbAlbums).insert(
                DbAlbumsCompanion.insert(
                  id: albumId,
                  title: match.title,
                  artist: Value(match.artist),
                  year: Value(match.year),
                  artworkUri: Value(match.artworkUri),
                  sourceAttribution: Value(match.sourceAttribution),
                  isSaved: Value(true),
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
        return Result.success(isNowSaved);
      });
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to toggle album save: $e', cause: st));
    }
  }

  /// Groups real tracks into album objects. Group key:
  /// `(album title, display artist = albumArtist ?? artist)`.
  Future<List<Album>> _deriveAlbums(List<Track> tracks) async {
    final savedFlags = <String, bool>{};
    for (final row in await db.select(db.dbAlbums).get()) {
      savedFlags[row.id] = row.isSaved;
    }

    final groups = <String, List<Track>>{};
    for (final t in tracks) {
      final title = t.album.trim();
      if (title.isEmpty) continue;
      final displayArtist = (t.albumArtist ?? t.artist).trim();
      final key = '${title.toLowerCase()}|${displayArtist.toLowerCase()}';
      groups.putIfAbsent(key, () => []).add(t);
    }

    final albums = <Album>[];
    groups.forEach((key, albumTracks) {
      final first = albumTracks.first;
      final displayArtist = (first.albumArtist ?? first.artist).trim();
      final id = albumIdentityKey(first.album, displayArtist);
      albumTracks.sort((a, b) {
        if (a.discNumber != b.discNumber) {
          return (a.discNumber ?? 1).compareTo(b.discNumber ?? 1);
        }
        return (a.trackNumber ?? 0).compareTo(b.trackNumber ?? 0);
      });
      final years =
          albumTracks.map((t) => t.releaseYear).whereType<int>().toList();
      final year = years.isNotEmpty ? years.reduce((a, b) => a > b ? a : b) : 0;
      final artwork = albumTracks
          .map((t) => t.artworkUri)
          .firstWhere((u) => u.trim().isNotEmpty, orElse: () => '');
      final attribution = albumTracks
          .map((t) => t.sourceAttribution)
          .firstWhereOrNull((s) => s != null);
      albums.add(Album(
        id: id,
        title: first.album,
        artist: displayArtist,
        year: year,
        artworkUri: artwork,
        sourceAttribution: attribution,
        isSaved: savedFlags[id] ?? false,
        tracks: albumTracks,
      ));
    });
    albums.sort((a, b) => b.tracks.first.dateAdded.compareTo(a.tracks.first.dateAdded));
    return albums;
  }

  /// Keeps helper rows in sync with derived albums without ever clobbering a
  /// user's saved flag (`INSERT OR IGNORE`).
  Future<void> _upsertAlbumHelperRows(List<Album> albums) async {
    for (final album in albums) {
      await db.into(db.dbAlbums).insert(
            DbAlbumsCompanion.insert(
              id: album.id,
              title: album.title,
              artist: Value(album.artist),
              year: Value(album.year),
              artworkUri: Value(album.artworkUri),
              sourceAttribution: Value(album.sourceAttribution),
              isSaved: Value(album.isSaved),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  // =========================================================================
  // Artists (derived from track rows)
  // =========================================================================

  @override
  Future<Result<List<Artist>, AppError>> getArtists(
      {String? profileId, bool followedOnly = false}) async {
    try {
      final tracksResult = await getAllTracks(profileId: profileId);
      if (tracksResult.isFailure) return Result.failure(tracksResult.errorOrNull!);
      final artists = await _deriveArtists(tracksResult.dataOrNull!);
      await _upsertArtistHelperRows(artists);
      final result = followedOnly ? artists.where((a) => a.isFollowed).toList() : artists;
      return Result.success(result);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to derive artists: $e', cause: st));
    }
  }

  @override
  Future<Result<Artist, AppError>> getArtist(String artistId, {String? profileId}) async {
    try {
      final result = await getArtists(profileId: profileId);
      if (result.isFailure) return Result.failure(result.errorOrNull!);
      final match = result.dataOrNull!.where((a) => a.id == artistId).firstOrNull;
      if (match == null) {
        return Result.failure(NotFoundError('Artist not found: $artistId'));
      }
      return Result.success(match);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to load artist: $e', cause: st));
    }
  }

  @override
  Future<Result<bool, AppError>> toggleFollowArtist(String artistId, {String? profileId}) async {
    try {
      return await db.transaction(() async {
        final existing =
            await (db.select(db.dbArtists)..where((tbl) => tbl.id.equals(artistId)))
                .getSingleOrNull();
        final isNowFollowed = existing?.isFollowed != true;
        if (existing != null) {
          await (db.update(db.dbArtists)..where((tbl) => tbl.id.equals(artistId)))
              .write(DbArtistsCompanion(isFollowed: Value(isNowFollowed)));
        } else {
          final derived = await _deriveArtists(
              (await getAllTracks(profileId: profileId)).dataOrNull ?? const []);
          final match = derived.where((a) => a.id == artistId).firstOrNull;
          if (match == null) {
            return Result.failure(NotFoundError('Artist not found: $artistId'));
          }
          await db.into(db.dbArtists).insert(
                DbArtistsCompanion.insert(
                  id: artistId,
                  name: match.name,
                  portraitUri: Value(match.portraitUri),
                  sourceAttribution: Value(match.sourceAttribution),
                  isFollowed: Value(true),
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
        return Result.success(isNowFollowed);
      });
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to toggle artist follow: $e', cause: st));
    }
  }

  Future<List<Artist>> _deriveArtists(List<Track> tracks) async {
    final followedFlags = <String, bool>{};
    for (final row in await db.select(db.dbArtists).get()) {
      followedFlags[row.id] = row.isFollowed;
    }

    // Group by primary artist (display artist). Featured performers inside
    // `artists` credit lists point to the same derived artist entries.
    final byPrimary = <String, Track>{};
    final creditTracks = <String, List<Track>>{};
    for (final t in tracks) {
      final name = t.artist.trim();
      if (name.isEmpty) continue;
      creditTracks.putIfAbsent(name.toLowerCase(), () => []).add(t);
      byPrimary[name.toLowerCase()] = t;
      for (final extra in t.artists) {
        final extraName = extra.trim();
        if (extraName.isEmpty || extraName.toLowerCase() == name.toLowerCase()) continue;
        creditTracks.putIfAbsent(extraName.toLowerCase(), () => []).add(t);
        byPrimary.putIfAbsent(extraName.toLowerCase(), () => t);
      }
    }

    final artists = <Artist>[];
    creditTracks.forEach((key, artistTracks) {
      final displayName = byPrimary[key]?.artist ?? artistTracks.first.artist;
      final id = artistIdentityKey(displayName);
      final ordered = [...artistTracks]..sort((a, b) => b.playCount.compareTo(a.playCount));
      final portrait = artistTracks
          .map((t) => t.artworkUri)
          .firstWhere((u) => u.trim().isNotEmpty, orElse: () => '');
      final attribution =
          artistTracks.map((t) => t.sourceAttribution).firstWhereOrNull((s) => s != null);

      final albumIdsSeen = <String>{};
      final albums = <Album>[];
      final singles = <Track>[];
      for (final t in artistTracks) {
        final albumTitle = t.album.trim();
        if (albumTitle.isEmpty) {
          singles.add(t);
          continue;
        }
        final albumId = albumIdentityKey(albumTitle, (t.albumArtist ?? t.artist).trim());
        if (!albumIdsSeen.add(albumId)) continue;
        final albumTracks = tracks
            .where((x) =>
                x.album.trim().toLowerCase() == albumTitle.toLowerCase() &&
                ((x.albumArtist ?? x.artist).trim().toLowerCase() ==
                    (t.albumArtist ?? t.artist).trim().toLowerCase()))
            .toList()
          ..sort((a, b) => (a.trackNumber ?? 0).compareTo(b.trackNumber ?? 0));
        if (albumTracks.isEmpty) continue;
        final years = albumTracks.map((x) => x.releaseYear).whereType<int>().toList();
        albums.add(Album(
          id: albumId,
          title: albumTitle,
          artist: t.albumArtist ?? t.artist,
          year: years.isNotEmpty ? years.reduce((a, b) => a > b ? a : b) : 0,
          artworkUri: albumTracks
              .map((x) => x.artworkUri)
              .firstWhere((u) => u.trim().isNotEmpty, orElse: () => ''),
          isSaved: false,
          tracks: albumTracks,
        ));
      }
      albums.sort((a, b) => b.year.compareTo(a.year));

      artists.add(Artist(
        id: id,
        name: displayName,
        portraitUri: portrait,
        sourceAttribution: attribution,
        isFollowed: followedFlags[id] ?? false,
        popularTracks: ordered.take(6).toList(),
        singles: singles,
        albums: albums,
      ));
    });
    artists.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return artists;
  }

  Future<void> _upsertArtistHelperRows(List<Artist> artists) async {
    for (final artist in artists) {
      await db.into(db.dbArtists).insert(
            DbArtistsCompanion.insert(
              id: artist.id,
              name: artist.name,
              portraitUri: Value(artist.portraitUri),
              sourceAttribution: Value(artist.sourceAttribution),
              isFollowed: Value(artist.isFollowed),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }
}
