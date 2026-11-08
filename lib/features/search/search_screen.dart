import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../core/components/cavia_page_header.dart';
import '../../core/components/cavia_section_header.dart';
import '../../core/components/cavia_search_field.dart';
import '../../core/components/cavia_filter_control.dart';
import '../../core/components/cavia_track_row.dart';
import '../../core/components/cavia_artwork.dart';
import '../../core/components/cavia_feedback_states.dart';
import '../../core/models/music_models.dart';
import '../../core/state/playback_controller.dart';
import '../../core/state/library_controller.dart';
import '../../core/state/app_state_scope.dart';
import '../../core/search/search_service.dart';
import '../../core/search/local_search_service.dart';
import '../../core/domain/repositories/search_repository.dart';
import '../../core/providers/music_provider.dart';
import '../albums/album_detail_screen.dart';
import '../artists/artist_detail_screen.dart';
import '../playlists/playlist_detail_screen.dart';

/// Redesigned Search Screen: Explicit Search State Machine × Zero Dead Handlers.
/// Operates on a clean dark surface without distracting backdrop imagery.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  SearchService? _onlineSearchService;
  LocalSearchService? _localSearchService;

  SearchFilterCategory _selectedCategory = SearchFilterCategory.all;

  SearchResults _localResults = const SearchResults();
  SearchResponse? _onlineResults;
  bool _isSearchingLocal = false;
  bool _isSearchingOnline = false;
  String? _onlineSearchError;
  String _lastQuery = '';
  int _searchSequence = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_localSearchService == null) {
      final library = AppStateScope.libraryOf(context);
      final settings = AppStateScope.settingsOf(context);
      final repo = library.searchRepository;
      final registry = settings.providerRegistry;
      if (repo != null) {
        _localSearchService = LocalSearchService(searchRepository: repo);
      }
      if (repo != null && registry != null) {
        _onlineSearchService = SearchService(
          providerRegistry: registry,
          searchRepository: repo,
        );
      }
    }
  }

  @override
  void dispose() {
    _onlineSearchService?.cancel();
    _localSearchService?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool _includeCategory(SearchFilterCategory cat) {
    return _selectedCategory == SearchFilterCategory.all || _selectedCategory == cat;
  }

  void _onCategoryChanged(SearchFilterCategory cat) {
    if (_selectedCategory == cat) return;
    setState(() => _selectedCategory = cat);
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      // Re-run search immediately with new category filter, clearing previous results
      _runSearch(query, forceRefresh: true);
    }
  }

  void _onSearchChanged(String val) {
    final query = val.trim();
    if (query.isEmpty) {
      _onlineSearchService?.cancel();
      _localSearchService?.cancel();
      _searchSequence++;
      setState(() {
        _localResults = const SearchResults();
        _onlineResults = null;
        _isSearchingLocal = false;
        _isSearchingOnline = false;
        _onlineSearchError = null;
        _lastQuery = '';
      });
      return;
    }

    _runSearch(query);
  }

  Future<void> _runSearch(String query, {bool forceRefresh = false}) async {
    if (!forceRefresh && query == _lastQuery && !_isSearchingOnline && !_isSearchingLocal) return;
    _lastQuery = query;

    // Immediately cancel in-flight operations from previous queries
    _onlineSearchService?.cancel();
    _localSearchService?.cancel();

    final currentSeq = ++_searchSequence;

    // Immediately clear previous results and reset loading/error state
    setState(() {
      _localResults = const SearchResults();
      _onlineResults = null;
      _isSearchingLocal = true;
      _isSearchingOnline = true;
      _onlineSearchError = null;
    });

    // 1. Local catalog search
    final localRes = await _localSearchService?.search(query);
    if (!mounted || currentSeq != _searchSequence) return;
    setState(() {
      _isSearchingLocal = false;
      if (localRes != null && localRes.isSuccess) {
        _localResults = localRes.dataOrNull!;
      } else {
        _localResults = const SearchResults();
      }
    });

    // 2. Online providers search
    final online = _onlineSearchService;
    if (online == null) {
      if (mounted && currentSeq == _searchSequence) {
        setState(() => _isSearchingOnline = false);
      }
      return;
    }

    final onlineRes = await online.debouncedSearch(
      query: query,
      category: _selectedCategory,
    );
    if (!mounted || currentSeq != _searchSequence) return;

    setState(() {
      _isSearchingOnline = false;
      if (onlineRes.isSuccess) {
        _onlineResults = onlineRes.dataOrNull!;
        _onlineSearchError = null;
      } else {
        final err = onlineRes.errorOrNull;
        if (err != null && !err.userMessage.contains('Superseded')) {
          _onlineSearchError = err.userMessage;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final library = AppStateScope.libraryOf(context);
    final playback = AppStateScope.playbackOf(context);

    return ListenableBuilder(
      listenable: Listenable.merge([library, playback]),
      builder: (context, _) {
        final query = _searchController.text.trim();
        final isSearching = query.isNotEmpty;

        final localSongs = _includeCategory(SearchFilterCategory.songs)
            ? _localResults.songs
            : const <Song>[];
        final localAlbums = _includeCategory(SearchFilterCategory.albums)
            ? _localResults.albums
            : const <Album>[];
        final localArtists = _includeCategory(SearchFilterCategory.artists)
            ? _localResults.artists
            : const <Artist>[];
        final localPlaylists = _includeCategory(SearchFilterCategory.playlists)
            ? _localResults.playlists
            : const <Playlist>[];

        final onlineSongs = _includeCategory(SearchFilterCategory.songs)
            ? (_onlineResults?.songs ?? const <SearchResultItem>[])
            : const <SearchResultItem>[];
        final onlineAlbums = _includeCategory(SearchFilterCategory.albums)
            ? (_onlineResults?.albums ?? const <SearchResultItem>[])
            : const <SearchResultItem>[];
        final onlineArtists = _includeCategory(SearchFilterCategory.artists)
            ? (_onlineResults?.artists ?? const <SearchResultItem>[])
            : const <SearchResultItem>[];
        final onlinePlaylists = _includeCategory(SearchFilterCategory.playlists)
            ? (_onlineResults?.playlists ?? const <SearchResultItem>[])
            : const <SearchResultItem>[];

        final totalResultsCount = localSongs.length +
            localAlbums.length +
            localArtists.length +
            localPlaylists.length +
            onlineSongs.length +
            onlineAlbums.length +
            onlineArtists.length +
            onlinePlaylists.length;

        return Scaffold(
          backgroundColor: CaviaColors.background,
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CaviaPageHeader(
                  title: 'Search',
                  kanji: '探',
                  sectionLabel: 'S E A R C H',
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: CaviaSearchField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    onChanged: _onSearchChanged,
                    onClear: () {
                      _onlineSearchService?.cancel();
                      _localSearchService?.cancel();
                      _searchSequence++;
                      setState(() {
                        _localResults = const SearchResults();
                        _onlineResults = null;
                        _isSearchingLocal = false;
                        _isSearchingOnline = false;
                        _onlineSearchError = null;
                        _lastQuery = '';
                      });
                    },
                  ),
                ),

                // Category Filter Bar (Only shown when searching)
                if (isSearching)
                  CaviaFilterControl(
                    selected: _selectedCategory,
                    onSelected: _onCategoryChanged,
                  ),

                const SizedBox(height: 8),

                // Content View
                Expanded(
                  child: !isSearching
                      ? _buildInitialState(library)
                      : _buildSearchResults(
                          hasResults: totalResultsCount > 0,
                          localSongs: localSongs,
                          localAlbums: localAlbums,
                          localArtists: localArtists,
                          localPlaylists: localPlaylists,
                          onlineSongs: onlineSongs,
                          onlineAlbums: onlineAlbums,
                          onlineArtists: onlineArtists,
                          onlinePlaylists: onlinePlaylists,
                          playback: playback,
                          library: library,
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInitialState(LibraryController library) {
    final history = library.searchHistory;

    if (history.isEmpty) {
      return const CaviaEmptyState(
        icon: Icons.search_rounded,
        title: 'Search Cavia Music',
        subtitle: 'Find your favorite songs, artists, albums and playlists across your local library and streams.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'RECENT SEARCHES',
                style: CaviaTypography.sectionLabel,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: library.clearSearchHistory,
              child: const Text(
                'Clear all',
                style: TextStyle(
                  color: CaviaColors.vermilionBright,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...history.map(
          (query) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.history_rounded,
              color: CaviaColors.textSilver,
              size: 20,
            ),
            title: Text(
              query,
              style: CaviaTypography.titleSmall.copyWith(fontWeight: FontWeight.w400),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: CaviaColors.textDim,
                size: 18,
              ),
              onPressed: () => library.removeSearchHistory(query),
              tooltip: 'Remove',
            ),
            onTap: () {
              _searchController.text = query;
              _runSearch(query);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults({
    required bool hasResults,
    required List<Song> localSongs,
    required List<Album> localAlbums,
    required List<Artist> localArtists,
    required List<Playlist> localPlaylists,
    required List<SearchResultItem> onlineSongs,
    required List<SearchResultItem> onlineAlbums,
    required List<SearchResultItem> onlineArtists,
    required List<SearchResultItem> onlinePlaylists,
    required PlaybackController playback,
    required LibraryController library,
  }) {
    if (!hasResults) {
      if (_isSearchingOnline || _isSearchingLocal) {
        return const CaviaLoadingState(
          message: 'Searching catalog and streams...',
        );
      }

      return CaviaEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No Results Found',
        subtitle: _onlineSearchError ?? 'Try searching with a different track title, artist name, or album.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 140),
      children: [
        // Songs Section (Local + Online Deduplicated)
        if (localSongs.isNotEmpty || onlineSongs.isNotEmpty) ...[
          const CaviaSectionHeader(title: 'Songs'),
          ...localSongs.map((song) {
            final isCurrent = playback.currentSong?.id == song.id;
            return CaviaTrackRow(
              track: song,
              isCurrent: isCurrent,
              isPlaying: isCurrent && playback.isPlaying,
              onTap: () => playback.playNow(song),
            );
          }),
          ...onlineSongs.map((item) {
            final song = item.trackData;
            if (song == null) return const SizedBox.shrink();
            final isCurrent = playback.currentSong?.id == song.id;
            return CaviaTrackRow(
              track: song,
              isCurrent: isCurrent,
              isPlaying: isCurrent && playback.isPlaying,
              onTap: () => playback.playNow(song),
            );
          }),
          const SizedBox(height: 16),
        ],

        // Albums Section
        if (localAlbums.isNotEmpty || onlineAlbums.isNotEmpty) ...[
          const CaviaSectionHeader(title: 'Albums'),
          ...localAlbums.map(
            (album) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              leading: CaviaArtwork(
                imageAsset: album.artworkAsset,
                width: 48,
                height: 48,
                radius: 8,
              ),
              title: Text(
                album.title,
                style: CaviaTypography.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${album.artist}${album.year > 0 ? ' • ${album.year}' : ''}',
                style: CaviaTypography.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AlbumDetailScreen(album: album),
                  ),
                );
              },
            ),
          ),
          ...onlineAlbums.map(
            (item) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              leading: CaviaArtwork(
                imageAsset: item.artworkUrl ?? '',
                width: 48,
                height: 48,
                radius: 8,
              ),
              title: Text(
                item.title,
                style: CaviaTypography.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                item.subtitle,
                style: CaviaTypography.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: CaviaColors.textSilver, size: 20),
              onTap: () {
                final album = Album(
                  id: item.id,
                  title: item.title,
                  artist: item.subtitle,
                  year: DateTime.now().year,
                  artworkAsset: item.artworkUrl,
                  sourceAttribution: item.sourceAttribution,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AlbumDetailScreen(album: album),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Artists Section
        if (localArtists.isNotEmpty || onlineArtists.isNotEmpty) ...[
          const CaviaSectionHeader(title: 'Artists'),
          ...localArtists.map(
            (artist) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              leading: ClipOval(
                child: CaviaArtwork(
                  imageAsset: artist.portraitAsset,
                  width: 48,
                  height: 48,
                  radius: 999,
                ),
              ),
              title: Text(
                artist.name,
                style: CaviaTypography.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${artist.albums.length} albums',
                style: CaviaTypography.bodySmall,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArtistDetailScreen(artist: artist),
                  ),
                );
              },
            ),
          ),
          ...onlineArtists.map(
            (item) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              leading: ClipOval(
                child: CaviaArtwork(
                  imageAsset: item.artworkUrl ?? '',
                  width: 48,
                  height: 48,
                  radius: 999,
                ),
              ),
              title: Text(
                item.title,
                style: CaviaTypography.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                item.subtitle.isNotEmpty ? item.subtitle : 'Artist',
                style: CaviaTypography.bodySmall,
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: CaviaColors.textSilver, size: 20),
              onTap: () {
                final artist = Artist(
                  id: item.id,
                  name: item.title,
                  portraitAsset: item.artworkUrl,
                  sourceAttribution: item.sourceAttribution,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArtistDetailScreen(artist: artist),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Playlists Section
        if (localPlaylists.isNotEmpty || onlinePlaylists.isNotEmpty) ...[
          const CaviaSectionHeader(title: 'Playlists'),
          ...localPlaylists.map(
            (playlist) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              leading: CaviaArtwork(
                imageAsset: playlist.artworkAsset,
                width: 48,
                height: 48,
                radius: 8,
              ),
              title: Text(
                playlist.name,
                style: CaviaTypography.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${playlist.trackCount} tracks',
                style: CaviaTypography.bodySmall,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlaylistDetailScreen(playlistId: playlist.id),
                  ),
                );
              },
            ),
          ),
          ...onlinePlaylists.map(
            (item) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
              leading: CaviaArtwork(
                imageAsset: item.artworkUrl ?? '',
                width: 48,
                height: 48,
                radius: 8,
              ),
              title: Text(
                item.title,
                style: CaviaTypography.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                item.subtitle,
                style: CaviaTypography.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: CaviaColors.textSilver, size: 20),
              onTap: () {
                final pl = Playlist(
                  id: item.id,
                  name: item.title,
                  description: item.subtitle,
                  artworkAsset: item.artworkUrl,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlaylistDetailScreen(playlistId: pl.id),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
