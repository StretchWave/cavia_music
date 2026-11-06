import '../models/track.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../models/playlist.dart';
import '../result/result.dart';
import '../result/app_error.dart';

class SearchResults {
  final List<Track> songs;
  final List<Album> albums;
  final List<Artist> artists;
  final List<Playlist> playlists;

  const SearchResults({
    this.songs = const [],
    this.albums = const [],
    this.artists = const [],
    this.playlists = const [],
  });

  bool get isEmpty => songs.isEmpty && albums.isEmpty && artists.isEmpty && playlists.isEmpty;
  bool get isNotEmpty => !isEmpty;
}

abstract class SearchRepository {
  Future<Result<SearchResults, AppError>> search(String query, {String? profileId});
  Stream<List<String>> watchSearchHistory({String? profileId});
  Future<Result<void, AppError>> addSearchQuery(String query, {String? profileId});
  Future<Result<void, AppError>> removeSearchQuery(String query, {String? profileId});
  Future<Result<void, AppError>> clearSearchHistory({String? profileId});
}

