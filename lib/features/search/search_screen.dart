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
import '../../core/innertube/innertube_client.dart';
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
  final InnerTubeClient _innerTubeClient = InnerTubeClient();
  String _selectedCategory = 'All'; // All, Songs, Albums, Artists, Playlists

  List<Song> _onlineResults = [];
  bool _isSearchingOnline = false;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val, LibraryController library) {
    _debounceTimer?.cancel();
    final query = val.trim();
    if (query.isEmpty) {
      setState(() {
        _onlineResults = [];
        _isSearchingOnline = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      _performOnlineSearch(query, library);
    });
    setState(() {});
  }

  void _performOnlineSearch(String query, LibraryController library) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    setState(() => _isSearchingOnline = true);

    final res = await _innerTubeClient.searchSongs(trimmed);
    if (!mounted) return;

    if (res.isSuccess) {
      final items = res.dataOrNull ?? [];
      final songs = items.map((i) {
        return Song(
          id: 'yt_${i.videoId}',
          title: i.title,
          artist: i.artist,
          album: i.album,
          duration: i.duration,
          artworkAsset: i.artworkUrl.isNotEmpty
              ? i.artworkUrl
              : 'assets/images/cover_zenith.jpg',
          isLiked: library.isSongLiked('yt_${i.videoId}'),
          isCached: false,
        );
      }).toList();

      setState(() {
        _onlineResults = songs;
        _isSearchingOnline = false;
      });
    } else {
      setState(() => _isSearchingOnline = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final library = AppStateScope.libraryOf(context);
    final playback = AppStateScope.playbackOf(context);

    return ListenableBuilder(
      listenable: Listenable.merge([library, playback]),
      builder: (context, _) {
        final query = _searchController.text.trim().toLowerCase();
        final isSearching = query.isNotEmpty;

        // Filter results
        final matchingSongs = library.songs.where((s) {
          return s.title.toLowerCase().contains(query) ||
              s.artist.toLowerCase().contains(query) ||
              s.album.toLowerCase().contains(query);
        }).toList();

        final matchingAlbums = library.albums.where((a) {
          return a.title.toLowerCase().contains(query) ||
              a.artist.toLowerCase().contains(query);
        }).toList();

        final matchingArtists = library.artists.where((a) {
          return a.name.toLowerCase().contains(query);
        }).toList();

        final matchingPlaylists = library.playlists.where((p) {
          return p.name.toLowerCase().contains(query);
        }).toList();

        final hasResults =
            matchingSongs.isNotEmpty ||
            matchingAlbums.isNotEmpty ||
            matchingArtists.isNotEmpty ||
            matchingPlaylists.isNotEmpty ||
            _onlineResults.isNotEmpty ||
            _isSearchingOnline;

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
                                onChanged: (val) =>
                                    _onSearchChanged(val, library),
                                onSubmitted: (val) {
                                  if (val.trim().isNotEmpty) {
                                    library.addSearchHistory(val.trim());
                                    _performOnlineSearch(val.trim(), library);
                                  }
                                },
                              ),
                            ),
                            if (isSearching)
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                color: CaviaColors.textSilver,
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _onlineResults = [];
                                    _isSearchingOnline = false;
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
                                          setState(() {
                                            _selectedCategory = category;
                                          });
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
                              matchingSongs: matchingSongs,
                              matchingAlbums: matchingAlbums,
                              matchingArtists: matchingArtists,
                              matchingPlaylists: matchingPlaylists,
                              playback: playback,
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
              _performOnlineSearch(query, library);
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults(
    BuildContext context, {
    required bool hasResults,
    required List<Song> matchingSongs,
    required List<Album> matchingAlbums,
    required List<Artist> matchingArtists,
    required List<Playlist> matchingPlaylists,
    required PlaybackController playback,
  }) {
    if (!hasResults) {
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
              'Try a different song, artist or album name',
              style: CaviaTypography.caption,
            ),
          ],
        ),
      );
    }

    final showSongs =
        _selectedCategory == 'All' || _selectedCategory == 'Songs';
    final showAlbums =
        _selectedCategory == 'All' || _selectedCategory == 'Albums';
    final showArtists =
        _selectedCategory == 'All' || _selectedCategory == 'Artists';
    final showPlaylists =
        _selectedCategory == 'All' || _selectedCategory == 'Playlists';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        if (showSongs && matchingSongs.isNotEmpty) ...[
          Text('SONGS', style: CaviaTypography.sectionLabel),
          const SizedBox(height: 8),
          ...matchingSongs.map(
            (song) => ListTile(
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
                '${song.artist} • ${song.album}',
                style: CaviaTypography.artistSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  size: 18,
                  color: CaviaColors.textSilver,
                ),
                onPressed: () => TrackContextMenu.show(context, song),
              ),
              onTap: () => playback.playNow(song),
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (showSongs && _onlineResults.isNotEmpty) ...[
          Row(
            children: [
              Text('ONLINE SONGS', style: CaviaTypography.sectionLabel),
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
          ),
          const SizedBox(height: 8),
          ..._onlineResults.map(
            (song) => ListTile(
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
                '${song.artist} • ${song.album}',
                style: CaviaTypography.artistSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  size: 18,
                  color: CaviaColors.textSilver,
                ),
                onPressed: () => TrackContextMenu.show(context, song),
              ),
              onTap: () => playback.playNow(song),
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (_isSearchingOnline)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: CaviaColors.vermilionBright,
                ),
              ),
            ),
          ),

        if (showAlbums && matchingAlbums.isNotEmpty) ...[
          Text('ALBUMS', style: CaviaTypography.sectionLabel),
          const SizedBox(height: 8),
          ...matchingAlbums.map(
            (album) => ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              leading: ArtworkView(
                imageAsset: album.artworkAsset,
                width: 44,
                height: 44,
                radius: 8,
              ),
              title: Text(album.title, style: CaviaTypography.songTitle),
              subtitle: Text(
                '${album.artist} • ${album.year}',
                style: CaviaTypography.artistSubtitle,
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

        if (showArtists && matchingArtists.isNotEmpty) ...[
          Text('ARTISTS', style: CaviaTypography.sectionLabel),
          const SizedBox(height: 8),
          ...matchingArtists.map(
            (artist) => ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              leading: CircleAvatar(
                backgroundImage: AssetImage(artist.portraitAsset),
                radius: 22,
              ),
              title: Text(artist.name, style: CaviaTypography.songTitle),
              subtitle: Text(
                '${artist.albums.length} albums',
                style: CaviaTypography.artistSubtitle,
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

        if (showPlaylists && matchingPlaylists.isNotEmpty) ...[
          Text('PLAYLISTS', style: CaviaTypography.sectionLabel),
          const SizedBox(height: 8),
          ...matchingPlaylists.map(
            (pl) => ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              leading: ArtworkView(
                imageAsset: pl.artworkAsset,
                width: 44,
                height: 44,
                radius: 8,
              ),
              title: Text(pl.name, style: CaviaTypography.songTitle),
              subtitle: Text(
                '${pl.songs.length} tracks',
                style: CaviaTypography.artistSubtitle,
              ),
              onTap: () {
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
