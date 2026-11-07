import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import '../../core/components/glass_container.dart';
import '../../core/components/japanese_scenery_background.dart';
import '../../core/components/artwork_view.dart';
import '../../core/state/app_state_scope.dart';
import '../playlists/playlist_detail_screen.dart';
import '../playlists/create_playlist_dialog.dart';
import 'liked_songs_screen.dart';
import '../albums/album_detail_screen.dart';
import '../artists/artist_detail_screen.dart';
import '../../core/components/toast.dart';
import '../../core/state/library_controller.dart';

class LibraryScreen extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const LibraryScreen({super.key, required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    final library = AppStateScope.libraryOf(context);
    final playback = AppStateScope.playbackOf(context);

    return ListenableBuilder(
      listenable: Listenable.merge([library, playback]),
      builder: (context, _) {
        final likedCount = library.likedSongs.length;
        final playlistsCount = library.playlists.length;
        final albumsCount = library.albums.length;
        final artistsCount = library.artists.length;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Atmospheric Japanese Ink & Pagoda Background
              const JapaneseSceneryBackground(
                imageAsset: 'assets/images/bg_library.jpg',
                opacity: 0.5,
              ),

              SafeArea(
                bottom: false,
                child: CustomScrollView(
                  slivers: [
                    // Top App Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Wordmark & Settings Shortcut
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    style: CaviaTypography.wordmark,
                                    children: [
                                      TextSpan(text: 'CAVIA '),
                                      TextSpan(
                                        text: '/',
                                        style: TextStyle(
                                          color: CaviaColors.vermilionBright,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.settings_outlined,
                                    color: CaviaColors.textSilver,
                                    size: 22,
                                  ),
                                  onPressed: onOpenSettings,
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Kanji Title & Section Subtitle
                            const Text('藏', style: CaviaTypography.kanjiHeader),
                            const SizedBox(height: 2),
                            const Text('L I B R A R Y', style: CaviaTypography.sectionLabel),
                          ],
                        ),
                      ),
                    ),

                    // Honest empty state: the library is backed by real data
                    // only; guiding copy replaces fabricated demo content.
                    if (library.songs.isEmpty && library.playlists.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(32, 8, 32, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your library is empty.',
                                style: CaviaTypography.songTitle,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Search & play streaming tracks to build history, '
                                'import a Spotify playlist, or like songs to fill '
                                'this shelf. Local music added through the import '
                                'engine also appears here automatically.',
                                style: CaviaTypography.caption,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // 2x2 Glass Shortcuts Grid (Liked, Playlists, Albums, Artists)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Liked Songs (with glowing vermilion accent)
                                Expanded(
                                  child: GlassContainer(
                                    height: 84,
                                    glow: true,
                                    radius: CaviaGlass.radiusCard,
                                    surfaceColor: CaviaColors.vermilion.withValues(alpha: 0.14),
                                    borderColor: CaviaColors.vermilionBright.withValues(alpha: 0.6),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const LikedSongsScreen(),
                                        ),
                                      );
                                    },
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.favorite_rounded,
                                            color: CaviaColors.vermilionBright,
                                            size: 26,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            '$likedCount Liked',
                                            style: CaviaTypography.songTitle.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Playlists
                                Expanded(
                                  child: GlassContainer(
                                    height: 84,
                                    radius: CaviaGlass.radiusCard,
                                    onTap: () {
                                      CreatePlaylistDialog.show(context);
                                    },
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.queue_music_rounded,
                                            color: CaviaColors.textIvory,
                                            size: 26,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            '$playlistsCount Playlists',
                                            style: CaviaTypography.songTitle,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                // Albums
                                Expanded(
                                  child: GlassContainer(
                                    height: 84,
                                    radius: CaviaGlass.radiusCard,
                                    onTap: () => _showAlbumsSheet(context, library),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.album_rounded,
                                            color: CaviaColors.textSilver,
                                            size: 26,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            '$albumsCount Albums',
                                            style: CaviaTypography.songTitle,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Artists
                                Expanded(
                                  child: GlassContainer(
                                    height: 84,
                                    radius: CaviaGlass.radiusCard,
                                    onTap: () => _showArtistsSheet(context, library),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.person_rounded,
                                            color: CaviaColors.textSilver,
                                            size: 26,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            '$artistsCount Artists',
                                            style: CaviaTypography.songTitle,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Recently Played Horizontal Carousel
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                        child: Text(
                          'RECENTLY PLAYED',
                          style: CaviaTypography.sectionLabel,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          itemCount: library.recentlyPlayed.length,
                          itemBuilder: (context, index) {
                            final song = library.recentlyPlayed[index];
                            return GestureDetector(
                              onTap: () => playback.playNow(song),
                              child: Container(
                                width: 100,
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ArtworkView(
                                      imageAsset: song.artworkAsset,
                                      width: 86,
                                      height: 86,
                                      radius: 16,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      song.title,
                                      style: CaviaTypography.caption.copyWith(
                                        color: CaviaColors.textIvory,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Your Playlists Header & Create Action
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'YOUR PLAYLISTS',
                              style: CaviaTypography.sectionLabel,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline_rounded,
                                color: CaviaColors.vermilionBright,
                                size: 22,
                              ),
                              tooltip: 'Create Playlist',
                              onPressed: () => CreatePlaylistDialog.show(context),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Playlists Grid / Cards
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final pl = library.playlists[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PlaylistDetailScreen(playlistId: pl.id),
                                  ),
                                );
                              },
                              child: GlassContainer(
                                radius: CaviaGlass.radiusCard,
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: ArtworkView(
                                          imageAsset: pl.artworkAsset,
                                          radius: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      pl.name,
                                      style: CaviaTypography.songTitle.copyWith(fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${pl.trackCount} tracks',
                                      style: CaviaTypography.caption,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          childCount: library.playlists.length,
                        ),
                      ),
                    ),

                    // Bottom padding for mini-player and bottom bar
                    const SliverToBoxAdapter(child: SizedBox(height: 140)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAlbumsSheet(BuildContext context, LibraryController library) {
    if (library.albums.isEmpty) {
      CaviaToast.show(context, 'No albums in your library yet', icon: Icons.album_outlined);
      return;
    }

    if (library.albums.length == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AlbumDetailScreen(album: library.albums.first),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: CaviaColors.overlaySheet,
      barrierColor: CaviaColors.scrim,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Albums (${library.albums.length})',
                      style: CaviaTypography.display.copyWith(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: CaviaColors.textSilver),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: CaviaColors.glassBorder),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: library.albums.length,
                  itemBuilder: (context, index) {
                    final album = library.albums[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
                        '${album.artist} • ${album.year} • ${album.songs.length} tracks',
                        style: CaviaTypography.artistSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AlbumDetailScreen(album: album),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showArtistsSheet(BuildContext context, LibraryController library) {
    if (library.artists.isEmpty) {
      CaviaToast.show(context, 'No artists in your library yet', icon: Icons.person_outline_rounded);
      return;
    }

    if (library.artists.length == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ArtistDetailScreen(artist: library.artists.first),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: CaviaColors.overlaySheet,
      barrierColor: CaviaColors.scrim,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Artists (${library.artists.length})',
                      style: CaviaTypography.display.copyWith(fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: CaviaColors.textSilver),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: CaviaColors.glassBorder),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: library.artists.length,
                  itemBuilder: (context, index) {
                    final artist = library.artists[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: artist.portraitAsset.startsWith('http://') ||
                                  artist.portraitAsset.startsWith('https://')
                              ? Image.network(
                                  artist.portraitAsset,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    color: CaviaColors.surfaceDark,
                                    child: const Icon(
                                      Icons.person_rounded,
                                      color: CaviaColors.textSilver,
                                      size: 24,
                                    ),
                                  ),
                                )
                              : Image.asset(
                                  artist.portraitAsset,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    color: CaviaColors.surfaceDark,
                                    child: const Icon(
                                      Icons.person_rounded,
                                      color: CaviaColors.textSilver,
                                      size: 24,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      title: Text(
                        artist.name,
                        style: CaviaTypography.songTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${artist.albums.length} albums • ${artist.popularSongs.length} tracks',
                        style: CaviaTypography.artistSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ArtistDetailScreen(artist: artist),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
