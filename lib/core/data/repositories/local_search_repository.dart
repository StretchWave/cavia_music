import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/track.dart';
import '../../domain/models/album.dart';
import '../../domain/models/artist.dart';
import '../../domain/models/playlist.dart';
import '../../domain/repositories/search_repository.dart';
import '../../domain/result/result.dart';
import '../../domain/result/app_error.dart';
import '../database/cavia_database.dart';

class LocalSearchRepository implements SearchRepository {
  final CaviaDatabase db;
  final Uuid _uuid = const Uuid();
  static int _microTick = 0;

  LocalSearchRepository(this.db);

  String _resolveProfile(String? profileId) => profileId ?? 'guest';

  @override
  Future<Result<SearchResults, AppError>> search(String query, {String? profileId}) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      return const Result.success(SearchResults());
    }

    try {
      final pid = _resolveProfile(profileId);
      final pattern = '%$cleanQuery%';

      // 1. Search Songs
      final trackQuery = (db.select(db.dbTracks)
            ..where((tbl) =>
                tbl.title.lower().like(pattern) |
                tbl.artist.lower().like(pattern) |
                tbl.album.lower().like(pattern)))
          .join([
        leftOuterJoin(
          db.dbLikedSongs,
          db.dbLikedSongs.trackId.equalsExp(db.dbTracks.id) &
              db.dbLikedSongs.profileId.equals(pid),
        ),
      ]);

      final trackRows = await trackQuery.get();
      final songs = trackRows.map((r) {
        final t = r.readTable(db.dbTracks);
        final isLiked = r.readTableOrNull(db.dbLikedSongs) != null;
        return Track(
          id: t.id,
          providerId: t.providerId,
          providerTrackId: t.providerTrackId,
          title: t.title,
          artist: t.artist,
          artists: t.artistsJson == '[]'
              ? [t.artist]
              : List<String>.from((jsonDecode(t.artistsJson) as List).map((e) => e.toString())),
          album: t.album,
          duration: Duration(milliseconds: t.durationMs),
          artworkUri: t.artworkUri,
          filePath: t.filePath,
          dateAdded: t.dateAdded,
          isLiked: isLiked,
          isCached: t.isCached,
        );
      }).toList();

      // 2. Search Albums
      final albumRows = await (db.select(db.dbAlbums)
            ..where((tbl) => tbl.title.lower().like(pattern) | tbl.artist.lower().like(pattern)))
          .get();
      final albums = albumRows
          .map((a) => Album(
                id: a.id,
                title: a.title,
                artist: a.artist,
                year: a.year ?? 0,
                artworkUri: a.artworkUri,
                isSaved: a.isSaved,
              ))
          .toList();

      // 3. Search Artists
      final artistRows = await (db.select(db.dbArtists)..where((tbl) => tbl.name.lower().like(pattern))).get();
      final artists = artistRows
          .map((a) => Artist(
                id: a.id,
                name: a.name,
                portraitUri: a.portraitUri,
                isFollowed: a.isFollowed,
              ))
          .toList();

      // 4. Search Playlists
      final playlistRows = await (db.select(db.dbPlaylists)
            ..where((tbl) =>
                tbl.profileId.equals(pid) &
                tbl.isDeleted.equals(false) &
                tbl.name.lower().like(pattern)))
          .get();
      final playlists = playlistRows
          .map((p) => Playlist(
                id: p.id,
                profileId: p.profileId,
                name: p.name,
                description: p.description,
                artworkUri: p.artworkUri,
                createdAt: p.createdAt,
                updatedAt: p.updatedAt,
              ))
          .toList();

      return Result.success(SearchResults(
        songs: songs,
        albums: albums,
        artists: artists,
        playlists: playlists,
      ));
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Search failed: $e', cause: st));
    }
  }

  @override
  Stream<List<String>> watchSearchHistory({String? profileId}) {
    final pid = _resolveProfile(profileId);
    final query = db.select(db.dbSearchHistory)
      ..where((tbl) => tbl.profileId.equals(pid))
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
      ])
      ..limit(10);

    return query.watch().map((rows) => rows.map((r) => r.query).toList());
  }

  @override
  Future<Result<void, AppError>> addSearchQuery(String query, {String? profileId}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const Result.success(null);

    try {
      final pid = _resolveProfile(profileId);
      final now = DateTime.now().toUtc().add(Duration(seconds: ++_microTick));
      final id = _uuid.v4();

      await db.transaction(() async {
        // Prevent duplicates: delete any existing identical query for this profile
        await (db.delete(db.dbSearchHistory)
              ..where((tbl) => tbl.profileId.equals(pid) & tbl.query.equals(trimmed)))
            .go();

        // Insert as newest
        await db.into(db.dbSearchHistory).insert(
              DbSearchHistoryCompanion.insert(
                id: id,
                profileId: Value(pid),
                query: trimmed,
                createdAt: now,
              ),
            );

        // Keep maximum 10 items
        final all = await (db.select(db.dbSearchHistory)
              ..where((tbl) => tbl.profileId.equals(pid))
              ..orderBy([
                (tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc),
              ]))
            .get();

        if (all.length > 10) {
          for (int i = 10; i < all.length; i++) {
            await (db.delete(db.dbSearchHistory)..where((tbl) => tbl.id.equals(all[i].id))).go();
          }
        }
      });

      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to add search history: $e', cause: st));
    }
  }

  @override
  Future<Result<void, AppError>> removeSearchQuery(String query, {String? profileId}) async {
    try {
      final pid = _resolveProfile(profileId);
      await (db.delete(db.dbSearchHistory)
            ..where((tbl) => tbl.profileId.equals(pid) & tbl.query.equals(query)))
          .go();
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to remove search history: $e', cause: st));
    }
  }

  @override
  Future<Result<void, AppError>> clearSearchHistory({String? profileId}) async {
    try {
      final pid = _resolveProfile(profileId);
      await (db.delete(db.dbSearchHistory)..where((tbl) => tbl.profileId.equals(pid))).go();
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to clear search history: $e', cause: st));
    }
  }
}
