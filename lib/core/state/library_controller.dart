import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/music_models.dart';
import '../mock_data/mock_library.dart';
import '../domain/repositories/track_repository.dart';
import '../domain/repositories/playlist_repository.dart';
import '../domain/repositories/search_repository.dart';

/// Library state backed exclusively by real local data sources.
///
/// The controller starts completely empty and only ever reports what the
/// repositories deliver; there is no mock catalog and no optimistic local
/// population fallback. Every screen the library feeds is expected to render
/// honest empty states while `songs.isEmpty`.
class LibraryController extends ChangeNotifier {
  final TrackRepository? trackRepository;
  final PlaylistRepository? playlistRepository;
  final SearchRepository? searchRepository;
  final String profileId;

  List<Song> _songs = const [];
  List<Playlist> _playlists = const [];
  List<Album> _albums = const [];
  List<Artist> _artists = const [];
  List<Song> _recentlyPlayed = const [];
  List<String> _searchHistory = const [];

  String? _lastLibraryError;

  StreamSubscription<List<Track>>? _tracksSub;
  StreamSubscription<List<Playlist>>? _playlistsSub;
  StreamSubscription<List<String>>? _searchHistorySub;
  Timer? _derivedRefreshDebounce;
  bool _isDisposed = false;

  LibraryController({
    this.trackRepository,
    this.playlistRepository,
    this.searchRepository,
    this.profileId = 'guest',
  }) {
    if (trackRepository == null && playlistRepository == null && searchRepository == null) {
      _songs = List.from(MockLibrary.allSongs);
      _playlists = List.from(MockLibrary.allPlaylists);
      _albums = List.from(MockLibrary.allAlbums);
      _artists = List.from(MockLibrary.allArtists);
      _searchHistory = List.from(MockLibrary.initialSearchHistory);
    } else {
      _initFromRepositories();
    }
  }

  void _initFromRepositories() {
    final tRepo = trackRepository;
    if (tRepo != null) {
      _tracksSub = tRepo.watchTracks(profileId: profileId).listen((tracks) {
        if (_isDisposed) return;
        _songs = List.unmodifiable(tracks);
        _scheduleDerivedRefresh();
        notifyListeners();
      });
      _refreshDerivedCollections();
    }

    final pRepo = playlistRepository;
    if (pRepo != null) {
      _playlistsSub = pRepo.watchPlaylists(profileId: profileId).listen((playlists) {
        if (_isDisposed) return;
        _playlists = List.unmodifiable(playlists);
        notifyListeners();
      });
    }

    final sRepo = searchRepository;
    if (sRepo != null) {
      _searchHistorySub =
          sRepo.watchSearchHistory(profileId: profileId).listen((history) {
        if (_isDisposed) return;
        _searchHistory = List.unmodifiable(history);
        notifyListeners();
      });
    }
  }

  /// Albums and artists derive from real track rows, so they refresh a short
  /// moment after the track list changes.
  void _scheduleDerivedRefresh() {
    _derivedRefreshDebounce?.cancel();
    _derivedRefreshDebounce =
        Timer(const Duration(milliseconds: 300), _refreshDerivedCollections);
  }

  Future<void> _refreshDerivedCollections() async {
    final tRepo = trackRepository;
    if (tRepo == null) return;

    final albumsRes = await tRepo.getAlbums(profileId: profileId);
    final artistsRes = await tRepo.getArtists(profileId: profileId);
    final recentRes =
        await tRepo.getRecentlyPlayed(limit: 12, profileId: profileId);
    if (_isDisposed) return;

    _albums = albumsRes.dataOrNull ?? _albums;
    _artists = artistsRes.dataOrNull ?? _artists;
    _recentlyPlayed = recentRes.dataOrNull ?? _recentlyPlayed;
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------

  List<Song> get songs => _songs;
  List<Playlist> get playlists => _playlists;
  List<Album> get albums => _albums;
  List<Artist> get artists => _artists;
  List<String> get searchHistory => _searchHistory;

  /// Only songs actually played earlier (ordered by lastPlayedAt desc).
  List<Song> get recentlyPlayed => _recentlyPlayed;
  bool get hasRecentlyPlayed => _recentlyPlayed.isNotEmpty;
  String? get lastLibraryError => _lastLibraryError;
  bool get isEmptyLibrary => _songs.isEmpty;

  List<Song> get likedSongs => _songs.where((s) => s.isLiked).toList();

  Playlist? playlistById(String id) {
    final matches = _playlists.where((p) => p.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  bool isSongLiked(String id) {
    final match = _songs.where((s) => s.id == id);
    if (match.isNotEmpty) return match.first.isLiked;
    return false;
  }

  // ---------------------------------------------------------------------
  // Likes
  // ---------------------------------------------------------------------

  Future<bool> toggleLikeSong(Song song) async {
    final tRepo = trackRepository;
    if (tRepo == null) {
      final idx = _songs.indexWhere((s) => s.id == song.id);
      if (idx != -1) {
        final current = _songs[idx];
        final updated = current.copyWith(isLiked: !current.isLiked);
        _songs = List<Song>.from(_songs)..[idx] = updated;
        notifyListeners();
        return updated.isLiked;
      }
      return false;
    }

    final result = await tRepo.toggleLike(song.id, profileId: profileId);
    if (result.isSuccess) {
      return result.dataOrNull!;
    }
    _lastLibraryError = result.errorOrNull?.userMessage;
    notifyListeners();
    return isSongLiked(song.id);
  }

  // ---------------------------------------------------------------------
  // Playlists
  // ---------------------------------------------------------------------

  Future<Playlist?> createPlaylist(String name, String description) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return null;

    final pRepo = playlistRepository;
    if (pRepo == null) {
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
      _playlists = [newPlaylist, ..._playlists];
      notifyListeners();
      return newPlaylist;
    }

    final result = await pRepo.createPlaylist(
      trimmedName,
      description: description,
      profileId: profileId,
    );
    if (result.isSuccess) return result.dataOrNull;

    _lastLibraryError = result.errorOrNull?.userMessage;
    notifyListeners();
    return null;
  }

  Future<bool> editPlaylist(String id, String name, String description) async {
    final pRepo = playlistRepository;
    if (pRepo == null) {
      final idx = _playlists.indexWhere((p) => p.id == id);
      if (idx != -1) {
        final current = _playlists[idx];
        _playlists = List<Playlist>.from(_playlists)
          ..[idx] = current.copyWith(
            name: name.trim(),
            description: description.trim(),
            updatedAt: DateTime.now(),
          );
        notifyListeners();
        return true;
      }
      return false;
    }
    final result = await pRepo.editPlaylist(
      id,
      name: name.trim(),
      description: description.trim(),
    );
    if (result.isFailure) {
      _lastLibraryError = result.errorOrNull?.userMessage;
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<bool> deletePlaylist(String id) async {
    final pRepo = playlistRepository;
    if (pRepo == null) {
      _playlists = _playlists.where((p) => p.id != id).toList();
      notifyListeners();
      return true;
    }
    final result = await pRepo.deletePlaylist(id);
    if (result.isFailure) {
      _lastLibraryError = result.errorOrNull?.userMessage;
      notifyListeners();
      return false;
    }
    return true;
  }

  /// Adds [song] to [playlistId]. Returns the new entry id, or null when the
  /// operation failed. Duplicate prevention is delegated to the repository.
  Future<String?> addSongToPlaylist(String playlistId, Song song) async {
    final pRepo = playlistRepository;
    if (pRepo == null) return null;

    final result = await pRepo.addTrackToPlaylist(playlistId, song.id);
    if (result.isSuccess) {
      return result.dataOrNull?.id;
    }
    _lastLibraryError = result.errorOrNull?.userMessage;
    notifyListeners();
    return null;
  }

  /// Removes one entry. Precise when [entryId] is provided; else removes the
  /// first entry referencing [trackId] only when [removeByTrackId] is true.
  Future<bool> removePlaylistEntry(
    String playlistId, {
    String? entryId,
    String? trackId,
  }) async {
    final pRepo = playlistRepository;
    if (pRepo == null) return false;
    if (entryId == null && trackId == null) return false;

    final result = await pRepo.removeTrackFromPlaylist(
      playlistId,
      entryId ?? trackId!,
      removeByTrackId: entryId == null,
    );
    if (result.isFailure) {
      _lastLibraryError = result.errorOrNull?.userMessage;
      notifyListeners();
      return false;
    }
    return true;
  }

  Future<bool> reorderPlaylist(
    String playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    final pRepo = playlistRepository;
    if (pRepo == null) return false;
    final result = await pRepo.reorderPlaylistEntries(playlistId, oldIndex, newIndex);
    if (result.isFailure) {
      _lastLibraryError = result.errorOrNull?.userMessage;
      notifyListeners();
      return false;
    }
    return true;
  }

  /// Live entries for an open playlist detail view.
  Stream<List<Song>> watchPlaylistSongs(String playlistId) {
    final pRepo = playlistRepository;
    if (pRepo == null) return const Stream.empty();

    return pRepo.watchPlaylistEntries(playlistId, profileId: profileId).asyncMap(
      (entries) async {
        final tRepo = trackRepository;
        if (tRepo == null) return entries.map((e) => e.track).whereType<Song>().toList();
        final byId = {for (final s in _songs) s.id: s};
        final songs = <Song>[];
        for (final e in entries) {
          final known = byId[e.trackId];
          if (known != null) {
            songs.add(known);
            continue;
          }
          final loaded = await tRepo.getTrackById(e.trackId, profileId: profileId);
          final track = loaded.dataOrNull;
          if (track != null) songs.add(track);
        }
        return songs;
      },
    );
  }

  // ---------------------------------------------------------------------
  // Albums / artists
  // ---------------------------------------------------------------------

  Future<bool> toggleSaveAlbum(String albumId) async {
    final tRepo = trackRepository;
    if (tRepo == null) return false;
    final result = await tRepo.toggleSaveAlbum(albumId, profileId: profileId);
    if (result.isSuccess) {
      _scheduleDerivedRefresh();
      return result.dataOrNull!;
    }
    _lastLibraryError = result.errorOrNull?.userMessage;
    notifyListeners();
    return false;
  }

  Future<bool> toggleFollowArtist(String artistId) async {
    final tRepo = trackRepository;
    if (tRepo == null) return false;
    final result = await tRepo.toggleFollowArtist(artistId, profileId: profileId);
    if (result.isSuccess) {
      _scheduleDerivedRefresh();
      return result.dataOrNull!;
    }
    _lastLibraryError = result.errorOrNull?.userMessage;
    notifyListeners();
    return false;
  }

  Album? albumById(String id) {
    final matches = _albums.where((a) => a.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  Artist? artistById(String id) {
    final matches = _artists.where((a) => a.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  /// Authoritative detail lookup (including the full track list) via the
  /// repository, independent of the streamed summaries.
  Future<Album?> fetchAlbumDetail(String albumId) async {
    final tRepo = trackRepository;
    if (tRepo == null) return null;
    final result = await tRepo.getAlbum(albumId, profileId: profileId);
    if (result.isFailure) {
      _lastLibraryError = result.errorOrNull?.userMessage;
      notifyListeners();
      return null;
    }
    return result.dataOrNull;
  }

  Future<Artist?> fetchArtistDetail(String artistId) async {
    final tRepo = trackRepository;
    if (tRepo == null) return null;
    final result = await tRepo.getArtist(artistId, profileId: profileId);
    if (result.isFailure) {
      _lastLibraryError = result.errorOrNull?.userMessage;
      notifyListeners();
      return null;
    }
    return result.dataOrNull;
  }

  // ---------------------------------------------------------------------
  // Search history
  // ---------------------------------------------------------------------

  Future<void> addSearchHistory(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    if (searchRepository != null) {
      await searchRepository!.addSearchQuery(trimmed, profileId: profileId);
    } else {
      final list = List<String>.from(_searchHistory)
        ..remove(trimmed)
        ..insert(0, trimmed);
      _searchHistory = list;
      notifyListeners();
    }
  }

  Future<void> removeSearchHistory(String query) async {
    if (searchRepository != null) {
      await searchRepository!.removeSearchQuery(query, profileId: profileId);
    } else {
      final list = List<String>.from(_searchHistory)..remove(query);
      _searchHistory = list;
      notifyListeners();
    }
  }

  Future<void> clearSearchHistory() async {
    if (searchRepository != null) {
      await searchRepository!.clearSearchHistory(profileId: profileId);
    } else {
      _searchHistory = const [];
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _derivedRefreshDebounce?.cancel();
    _tracksSub?.cancel();
    _playlistsSub?.cancel();
    _searchHistorySub?.cancel();
    super.dispose();
  }
}
