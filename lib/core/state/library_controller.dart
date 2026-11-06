import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/music_models.dart';
import '../mock_data/mock_library.dart';
import '../domain/repositories/track_repository.dart';
import '../domain/repositories/playlist_repository.dart';
import '../domain/repositories/search_repository.dart';

class LibraryController extends ChangeNotifier {
  final TrackRepository? trackRepository;
  final PlaylistRepository? playlistRepository;
  final SearchRepository? searchRepository;
  final String profileId;

  List<Song> _songs = List.from(MockLibrary.allSongs);
  List<Playlist> _playlists = List.from(MockLibrary.allPlaylists);
  final List<Album> _albums = List.from(MockLibrary.allAlbums);
  final List<Artist> _artists = List.from(MockLibrary.allArtists);
  List<String> _searchHistory = List.from(MockLibrary.initialSearchHistory);

  StreamSubscription<List<Track>>? _tracksSub;
  StreamSubscription<List<Track>>? _likedTracksSub;
  StreamSubscription<List<Playlist>>? _playlistsSub;
  StreamSubscription<List<String>>? _searchHistorySub;

  LibraryController({
    this.trackRepository,
    this.playlistRepository,
    this.searchRepository,
    this.profileId = 'guest',
  }) {
    if (trackRepository != null || playlistRepository != null || searchRepository != null) {
      _initFromRepositories();
    }
  }

  void _initFromRepositories() async {
    final tRepo = trackRepository;
    if (tRepo != null) {
      final res = await tRepo.getAllTracks(profileId: profileId);
      if (res.isSuccess && res.dataOrNull!.isNotEmpty) {
        _songs = res.dataOrNull!;
        notifyListeners();
      }
      _tracksSub = tRepo.watchTracks(profileId: profileId).listen((tracks) {
        if (tracks.isNotEmpty) {
          _songs = tracks;
          notifyListeners();
        }
      });
      _likedTracksSub = tRepo.watchLikedTracks(profileId: profileId).listen((liked) {
        notifyListeners();
      });
    }

    final pRepo = playlistRepository;
    if (pRepo != null) {
      final res = await pRepo.getAllPlaylists(profileId: profileId);
      if (res.isSuccess) {
        _playlists = res.dataOrNull!;
        notifyListeners();
      }
      _playlistsSub = pRepo.watchPlaylists(profileId: profileId).listen((playlists) {
        _playlists = playlists;
        notifyListeners();
      });
    }

    final sRepo = searchRepository;
    if (sRepo != null) {
      _searchHistorySub = sRepo.watchSearchHistory(profileId: profileId).listen((history) {
        _searchHistory = history;
        notifyListeners();
      });
    }
  }

  // Getters
  List<Song> get songs => _songs;
  List<Playlist> get playlists => _playlists;
  List<Album> get albums => _albums;
  List<Artist> get artists => _artists;
  List<String> get searchHistory => _searchHistory;

  List<Song> get likedSongs => _songs.where((s) => s.isLiked).toList();
  List<Song> get recentlyPlayed => _songs.take(5).toList();

  bool isSongLiked(String id) {
    final match = _songs.where((s) => s.id == id);
    if (match.isNotEmpty) return match.first.isLiked;
    return false;
  }

  Future<bool> toggleLikeSong(Song song) async {
    // Optimistic UI update
    final idx = _songs.indexWhere((s) => s.id == song.id);
    if (idx != -1) {
      final updated = _songs[idx].copyWith(isLiked: !_songs[idx].isLiked);
      _songs[idx] = updated;
      notifyListeners();
    }

    final tRepo = trackRepository;
    if (tRepo != null) {
      final result = await tRepo.toggleLike(song.id, profileId: profileId);
      if (result.isSuccess && idx != -1) {
        final isLiked = result.dataOrNull!;
        _songs[idx] = _songs[idx].copyWith(isLiked: isLiked);
        notifyListeners();
        return isLiked;
      }
    }
    return idx != -1 ? _songs[idx].isLiked : false;
  }

  Future<Playlist?> createPlaylist(String name, String description) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return null;

    final pRepo = playlistRepository;
    if (pRepo != null) {
      final result = await pRepo.createPlaylist(
        trimmedName,
        description: description,
        profileId: profileId,
      );
      if (result.isSuccess) {
        return result.dataOrNull;
      }
    } else {
      final newPlaylist = Playlist(
        id: 'pl_${DateTime.now().millisecondsSinceEpoch}',
        name: trimmedName,
        description: description.trim().isEmpty
            ? 'Personal sanctuary collection.'
            : description.trim(),
        artworkUri: 'assets/images/cover_zenith.jpg',
        songs: _songs.take(3).toList(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _playlists.insert(0, newPlaylist);
      notifyListeners();
      return newPlaylist;
    }
    return null;
  }

  Future<void> editPlaylist(String id, String name, String description) async {
    final pRepo = playlistRepository;
    if (pRepo != null) {
      await pRepo.editPlaylist(
        id,
        name: name,
        description: description,
      );
    } else {
      final idx = _playlists.indexWhere((p) => p.id == id);
      if (idx != -1) {
        _playlists[idx] = _playlists[idx].copyWith(
          name: name,
          description: description,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    }
  }

  Future<void> deletePlaylist(String id) async {
    final pRepo = playlistRepository;
    if (pRepo != null) {
      await pRepo.deletePlaylist(id);
    } else {
      _playlists.removeWhere((p) => p.id == id);
      notifyListeners();
    }
  }

  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    final pRepo = playlistRepository;
    if (pRepo != null) {
      await pRepo.addTrackToPlaylist(playlistId, song.id);
    } else {
      final idx = _playlists.indexWhere((p) => p.id == playlistId);
      if (idx != -1) {
        final pl = _playlists[idx];
        if (!pl.songs.any((s) => s.id == song.id)) {
          _playlists[idx] = pl.copyWith(songs: [...pl.songs, song]);
          notifyListeners();
        }
      }
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final pRepo = playlistRepository;
    if (pRepo != null) {
      await pRepo.removeTrackFromPlaylist(playlistId, songId);
    } else {
      final idx = _playlists.indexWhere((p) => p.id == playlistId);
      if (idx != -1) {
        final pl = _playlists[idx];
        _playlists[idx] = pl.copyWith(
          songs: pl.songs.where((s) => s.id != songId).toList(),
        );
        notifyListeners();
      }
    }
  }

  Future<void> reorderPlaylist(String playlistId, int oldIndex, int newIndex) async {
    final pRepo = playlistRepository;
    if (pRepo != null) {
      await pRepo.reorderPlaylistEntries(playlistId, oldIndex, newIndex);
    } else {
      final idx = _playlists.indexWhere((p) => p.id == playlistId);
      if (idx != -1) {
        final pl = _playlists[idx];
        final mutable = List<Song>.from(pl.songs);
        if (oldIndex < newIndex) newIndex -= 1;
        final moved = mutable.removeAt(oldIndex);
        mutable.insert(newIndex, moved);
        _playlists[idx] = pl.copyWith(songs: mutable);
        notifyListeners();
      }
    }
  }

  void toggleSaveAlbum(String albumId) {
    final idx = _albums.indexWhere((a) => a.id == albumId);
    if (idx != -1) {
      _albums[idx] = _albums[idx].copyWith(isSaved: !_albums[idx].isSaved);
      notifyListeners();
    }
  }

  void toggleFollowArtist(String artistId) {
    final idx = _artists.indexWhere((a) => a.id == artistId);
    if (idx != -1) {
      _artists[idx] = _artists[idx].copyWith(isFollowed: !_artists[idx].isFollowed);
      notifyListeners();
    }
  }

  Future<void> addSearchHistory(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final sRepo = searchRepository;
    if (sRepo != null) {
      await sRepo.addSearchQuery(trimmed, profileId: profileId);
    } else {
      _searchHistory.remove(trimmed);
      _searchHistory.insert(0, trimmed);
      if (_searchHistory.length > 8) {
        _searchHistory = _searchHistory.sublist(0, 8);
      }
      notifyListeners();
    }
  }

  Future<void> removeSearchHistory(String query) async {
    final sRepo = searchRepository;
    if (sRepo != null) {
      await sRepo.removeSearchQuery(query, profileId: profileId);
    } else {
      _searchHistory.remove(query);
      notifyListeners();
    }
  }

  Future<void> clearSearchHistory() async {
    final sRepo = searchRepository;
    if (sRepo != null) {
      await sRepo.clearSearchHistory(profileId: profileId);
    } else {
      _searchHistory.clear();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _tracksSub?.cancel();
    _likedTracksSub?.cancel();
    _playlistsSub?.cancel();
    _searchHistorySub?.cancel();
    super.dispose();
  }
}
