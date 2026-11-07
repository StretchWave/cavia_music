import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import '../../core/components/glass_container.dart';
import '../../core/components/japanese_scenery_background.dart';
import '../../core/components/artwork_view.dart';
import '../../core/components/context_menus.dart';
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

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  SearchService? _onlineSearchService;
  LocalSearchService? _localSearchService;

  String _selectedCategory = 'All'; // All, Songs, Albums, Artists, Playlists

  // Real persisted search results from the repositories.
  SearchResults _localResults = const SearchResults();
  SearchResponse? _onlineResults;
  bool _isSearchingOnline = false;
  String? _onlineSearchError;
  String _lastQuery = '';

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
    _searchController.dispose();
    super.dispose();
  }

  SearchFilterCategory get _categoryFilter {
    switch (_selectedCategory) {
      case 'Songs':
        return SearchFilterCategory.songs;
      case 'Albums':
        return SearchFilterCategory.albums;
      case 'Artists':
        return SearchFilterCategory.artists;
      case 'Playlists':
        return SearchFilterCategory.playlists;
      default:
        return SearchFilterCategory.all;
    }
  }

  bool _includeLocalCategory(String category) {
    return _selectedCategory == 'All' || _selectedCategory == category;
  }

  void _onSearchChanged(String val) {
    final query = val.trim();
    if (query.isEmpty) {
      _onlineSearchService?.cancel();
      setState(() {
        _localResults = const SearchResults();
        _onlineResults = null;
        _isSearchingOnline = false;
        _onlineSearchError = null;
        _lastQuery = '';
      });
      return;
    }

    setState(() {});
    _runSearch(query);
  }

  Future<void> _runSearch(String query) async {
    if (query == _lastQuery && !_isSearchingOnline) return;
    _lastQuery = query;

    // 1. Local catalog (debounced inside the service).
    final localRes = await _localSearchService?.search(query);
    if (!mounted || query != _lastQuery) return;
    if (localRes != null && localRes.isSuccess) {
      setState(() => _localResults = localRes.dataOrNull!);
    } else {
      setState(() => _localResults = const SearchResults());
    }

    // 2. Online providers: cancellation handled by the SearchService itself.
    final online = _onlineSearchService;
    if (online == null) return;

    if (mounted) setState(() => _isSearchingOnline = true);
    final onlineRes = await online.debouncedSearch(
      query: query,
      category: _categoryFilter,
    );
    if (!mounted || query != _lastQuery) return;

    if (onlineRes.isSuccess) {
      setState(() {
        _onlineResults = onlineRes.dataOrNull!;
        _isSearchingOnline = false;
        _onlineSearchError = null;
      });
    } else {
      setState(() {
        _isSearchingOnline = false;
        _onlineSearchError = onlineRes.errorOrNull?.userMessage;
      });
    }
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

        // Online results are filtered by the selected category server-side,
        // while local results are partitioned here.
        final localSongs =
            _includeLocalCategory('Songs') ? _localResults.songs : const <Song>[];
        final localAlbums =
            _includeLocalCategory('Albums') ? _localResults.albums : const <Album>[];
        final localArtists =
            _includeLocalCategory('Artists') ? _localResults.artists : const <Artist>[];
        final localPlaylists =
            _includeLocalCategory('Playlists') ? _localResults.playlists : const <Playlist>[];

        final onlineSongs = _includeLocalCategory('Songs')
            ? (_onlineResults?.songs ?? const <SearchResultItem>[])
            : const <SearchResultItem>[];
        final onlineAlbums = _includeLocalCategory('Albums')
            ? (_onlineResults?.albums ?? const <SearchResultItem>[])
            : const <SearchResultItem>[];
        final onlineArtists = _includeLocalCategory('Artists')
            ? (_onlineResults?.artists ?? const <SearchResultItem>[])
            : const <SearchResultItem>[];
        final onlinePlaylists = _includeLocalCategory('Playlists')
            ? (_onlineResults?.playlists ?? const <SearchResultItem>[])
            : const <SearchResultItem>[];

        final hasResults = localSongs.isNotEmpty ||
            localAlbums.isNotEmpty ||
            localArtists.isNotEmpty ||
            localPlaylists.isNotEmpty ||
            onlineSongs.isNotEmpty ||
            onlineAlbums.isNotEmpty ||
            onlineArtists.isNotEmpty ||
            onlinePlaylists.isNotEmpty;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Atmospheric Japanese Torii Lake Backdrop
              const JapaneseSceneryBackground(
                imageAsset: 'assets/images/bg_search.jpg',
                opacity: 0.5,
              ),

              SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Kanji
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('探', style: CaviaTypography.kanjiHeader),
                          SizedBox(height: 2),
                          Text(
                            'S E A R C H',
                            style: CaviaTypography.sectionLabel,
                          ),
                        ],
                      ),
                    ),

                    // Search Pill Input Field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GlassContainer(
                        radius: CaviaGlass.radiusPill,
                        blur: CaviaGlass.blurHeavy,
                        surfaceColor: CaviaColors.glassSurface,
                        borderColor: isSearching
                            ? CaviaColors.vermilionBright.withValues(alpha: 0.7)
                            : CaviaColors.glassBorder,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: CaviaColors.textSilver,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: const TextStyle(
                                  color: CaviaColors.textIvory,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Search music...',
                                  hintStyle: TextStyle(
                                    color: CaviaColors.textDim,
                                  ),
                                  border: InputBorder.none,
                                ),
                                onChanged: _onSearchChanged,
                              ),
                            ),
                            if (isSearching)
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                color: CaviaColors.textSilver,
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _localResults = const SearchResults();
                                    _onlineResults = null;
                                    _isSearchingOnline = false;
                                    _onlineSearchError = null;
                                    _lastQuery = '';
                                  });
                                },
                              ),
                            const Icon(
                              Icons.tune_rounded,
                              color: CaviaColors.textSilver,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Category Filter Pills (if searching)
                    if (isSearching)
                      SizedBox(
                        height: 38,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children:
                              ['All', 'Songs', 'Albums', 'Artists', 'Playlists']
                                  .map(
                                    (category) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: FilterChip(
                                        selected: _selectedCategory == category,
                                        label: Text(category),
                                        labelStyle: TextStyle(
                                          color: _selectedCategory == category
                                              ? CaviaColors.textIvory
                                              : CaviaColors.textSilver,
                                          fontWeight:
                                              _selectedCategory == category
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                          fontSize: 12,
                                        ),
                                        backgroundColor:
                                            CaviaColors.glassSurface,
                                        selectedColor: CaviaColors.vermilion,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          side: BorderSide(
                                            color: _selectedCategory == category
                                                ? CaviaColors.vermilionBright
                                                : CaviaColors.glassBorderSubtle,
                                          ),
                                        ),
                                        onSelected: (selected) {
                                          if (!selected) return;
                                          setState(() {
                                            _selectedCategory = category;
                                          });
                                          final q = _searchController.text.trim();
                                          if (q.isNotEmpty) _runSearch(q);
                                        },
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),

                    // Results or Recent Searches
                    Expanded(
                      child: isSearching
                          ? _buildSearchResults(
                              context,
                              hasResults: hasResults,
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
                            )
                          : _buildRecentSearches(context, library),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentSearches(BuildContext context, LibraryController library) {
    final history = library.searchHistory;

    if (history.isEmpty) {
      return Center(
        child: Text(
          'No recent searches',
          style: CaviaTypography.artistSubtitle,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('RECENT SEARCHES', style: CaviaTypography.sectionLabel),
            TextButton(
              onPressed: library.clearSearchHistory,
              child: Text(
                'Clear all',
                style: CaviaTypography.caption.copyWith(
                  color: CaviaColors.vermilionBright,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
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
              style: CaviaTypography.songTitle.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: CaviaColors.textDim,
                size: 18,
              ),
              onPressed: () => library.removeSearchHistory(query),
            ),
            onTap: () {
              _searchController.text = query;
              setState(() {});
              _runSearch(query);
            },
          ),
        ),
      ],
    );
  }

  Widget _onlineArtwork(SearchResultItem item, {bool circular = false}) {
    final url = item.artworkUrl;
    if (url == null || url.isEmpty) {
      return const SizedBox(
        width: 48,
        height: 48,
        child: Icon(
          Icons.music_note_rounded,
          size: 28,
          color: CaviaColors.textSilver,
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(circular ? 24 : 8),
      child: Image.network(
        url,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            Icons.music_note_rounded,
            size: 26,
            color: CaviaColors.textSilver,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context, {
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
      if (_isSearchingOnline) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: CaviaColors.vermilionBright,
                strokeWidth: 2,
              ),
              const SizedBox(height: 16),
              Text(
                'Searching local catalog & streams...',
                style: CaviaTypography.caption,
              ),
            ],
          ),
        );
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: CaviaColors.textDim,
            ),
            const SizedBox(height: 12),
            Text(
              'No results found',
              style: CaviaTypography.display.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 6),
            Text(
              _onlineSearchError ?? 'Try a different song, artist or album name',
              style: CaviaTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        if (localSongs.isNotEmpty) ...[
          _sectionHeader(' Songs'),
          ...localSongs.map(
            (song) => _buildSongTile(context, song, playback, null),
          ),
          const SizedBox(height: 16),
        ],

        if (onlineSongs.isNotEmpty) ...[
          _sectionHeader('Titles from Streams', isOnline: true),
          ...onlineSongs.map((item) {
            final song = item.trackData;
            if (song == null) return const SizedBox.shrink();
            return _buildSongTile(context, song, playback, item);
          }),
          const SizedBox(height: 16),
        ],

        if (localAlbums.isNotEmpty) ...[
          _sectionHeader(' Albums in Library'),
          ...localAlbums.map(
            (album) => ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              leading: ArtworkView(
                imageAsset: album.artworkAsset,
                width: 48,
                height: 48,
                radius: 8,
              ),
              title: Text(
                album.title,
                style: CaviaTypography.songTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${album.artist}${album.year > 0 ? ' • ${album.year}' : ''}',
                style: CaviaTypography.artistSubtitle,
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
          const SizedBox(height: 16),
        ],

        if (onlineAlbums.isNotEmpty) ...[
          _sectionHeader('Streamed Albums', isOnline: true),
          ...onlineAlbums.map(
            (item) => ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              leading: _onlineArtwork(item),
              trailing: const Icon(
                Icons.circle,
                size: 6,
                color: CaviaColors.textSilver,
              ),
              title: Text(
                item.title,
                style: CaviaTypography.songTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                item.subtitle,
                style: CaviaTypography.artistSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (localArtists.isNotEmpty) ...[
          _sectionHeader(' Artists in Library'),
          ...localArtists.map(
            (artist) => ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              leading: ArtworkView(
                imageAsset: artist.portraitAsset,
                width: 48,
                height: 48,
                radius: 24,
              ),
              title: Text(
                artist.name,
                style: CaviaTypography.songTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 16),
        ],

        if (onlineArtists.isNotEmpty) ...[
          _sectionHeader('Streamed Artists', isOnline: true),
          ...onlineArtists.map(
            (item) => ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              leading: _onlineArtwork(item, circular: true),
              title: Text(
                item.title,
                style: CaviaTypography.songTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                item.subtitle,
                style: CaviaTypography.artistSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (localPlaylists.isNotEmpty) ...[
          _sectionHeader(' Playlists in Library'),
          ...localPlaylists.map(
            (playlist) => ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              leading: ArtworkView(
                imageAsset: playlist.artworkAsset,
                width: 48,
                height: 48,
                radius: 8,
              ),
              title: Text(
                playlist.name,
                style: CaviaTypography.songTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${playlist.trackCount} ${playlist.trackCount == 1 ? 'track' : 'tracks'}',
                style: CaviaTypography.artistSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 16),
        ],

        if (onlinePlaylists.isNotEmpty) ...[
          _sectionHeader('Streamed Playlists', isOnline: true),
          ...onlinePlaylists.map(
            (item) => ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              leading: _onlineArtwork(item),
              title: Text(
                item.title,
                style: CaviaTypography.songTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                item.subtitle,
                style: CaviaTypography.artistSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () {},
            ),
          ),
        ],
      ],
    );
  }

  Widget _sectionHeader(String label, {bool isOnline = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 2),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: CaviaTypography.sectionLabel,
          ),
          if (isOnline) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: CaviaColors.vermilion.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: CaviaColors.vermilionBright,
                  width: 0.5,
                ),
              ),
              child: const Text(
                'STREAMING',
                style: TextStyle(
                  color: CaviaColors.vermilionBright,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSongTile(
    BuildContext context,
    Song song,
    PlaybackController playback,
    SearchResultItem? onlineItem,
  ) {
    final knownDuration = song.duration > Duration.zero;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 2),
      leading: ArtworkView(
        imageAsset: song.artworkAsset,
        width: 44,
        height: 44,
        radius: 8,
      ),
      title: Text(
        song.title,
        style: CaviaTypography.songTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${song.artist}${song.album.isEmpty ? '' : ' • ${song.album}'}',
        style: CaviaTypography.artistSubtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (knownDuration)
            Text(
              _formatDuration(song.duration),
              style: CaviaTypography.caption.copyWith(
                color: CaviaColors.textDim,
              ),
            ),
          IconButton(
            icon: const Icon(
              Icons.more_vert_rounded,
              size: 18,
              color: CaviaColors.textSilver,
            ),
            onPressed: () => TrackContextMenu.show(context, song),
          ),
        ],
      ),
      onTap: () {
        // The Track model already carries a real provider identity
        // ('local' or 'youtube_music'); playback resolution goes through
        // TrackResolver with no provider rewriting here.
        playback.playNow(song);
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${duration.inHours > 0 ? '${duration.inHours}:' : ''}'
        '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
