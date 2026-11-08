import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_glass.dart';
import '../../app/theme/cavia_typography.dart';
import '../../core/components/cavia_page_header.dart';
import '../../core/components/cavia_section_header.dart';
import '../../core/components/cavia_album_card.dart';
import '../../core/components/cavia_playlist_card.dart';
import '../../core/components/cavia_feedback_states.dart';
import '../../core/state/app_state_scope.dart';
import '../playlists/create_playlist_dialog.dart';
import '../playlists/playlist_detail_screen.dart';
import '../spotify_import/spotify_import_screen.dart';
import 'liked_songs_screen.dart';
import 'collections/playlists_collection_screen.dart';
import 'collections/albums_collection_screen.dart';
import 'collections/artists_collection_screen.dart';

/// Redesigned Library Screen: Japanese Editorial × Restrained Liquid Glass.
/// Prioritizes the user's music collection over dashboard shortcuts.
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
        final isEmpty = library.songs.isEmpty && library.playlists.isEmpty;

        return Scaffold(
          backgroundColor: CaviaColors.background,
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                // Top Editorial App Header
                SliverToBoxAdapter(
                  child: CaviaPageHeader(
                    title: 'Library',
                    kanji: '藏',
                    sectionLabel: 'L I B R A R Y',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_rounded, size: 24),
                          color: CaviaColors.vermilionBright,
                          tooltip: 'Create Playlist',
                          onPressed: () => CreatePlaylistDialog.show(context),
                        ),
                        IconButton(
                          icon: const Icon(Icons.download_rounded, size: 20),
                          color: CaviaColors.textSilver,
                          tooltip: 'Import Playlist',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SpotifyImportScreen(),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_outlined, size: 20),
                          color: CaviaColors.textSilver,
                          tooltip: 'Settings',
                          onPressed: onOpenSettings,
                        ),
                      ],
                    ),
                  ),
                ),

                // Honest Empty State
                if (isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: CaviaEmptyState(
                      icon: Icons.library_music_rounded,
                      title: 'Your Library is Empty',
                      subtitle: 'Add tracks from Search or import your existing playlists to begin.',
                      actionLabel: 'Import Playlist',
                      onAction: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SpotifyImportScreen(),
                          ),
                        );
                      },
                    ),
                  )
                else ...[
                  // Collection Navigation Chips (Playlists, Albums, Artists)
                  SliverToBoxAdapter(
                    child: _buildCollectionChips(context, library),
                  ),

                  // Liked Songs Card
                  if (library.likedSongs.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildLikedSongsCard(context, library, playback),
                    ),

                  // Recently Played (Only rendered when there is actual playback history!)
                  if (library.recentlyPlayed.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: CaviaSectionHeader(title: 'Recently Played'),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 175,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: library.recentlyPlayed.length,
                          itemBuilder: (context, index) {
                            final song = library.recentlyPlayed[index];

                            return Container(
                              width: 130,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              child: CaviaAlbumCard(
                                album: library.albums.firstWhere(
                                  (a) => a.title == song.album,
                                  orElse: () => library.albums.isNotEmpty
                                      ? library.albums.first
                                      : library.albums.first,
                                ),
                                onTap: () => playback.playNow(song),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  // Playlists Collection Preview
                  if (library.playlists.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: CaviaSectionHeader(
                        title: 'Playlists',
                        trailing: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PlaylistsCollectionScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'See all',
                            style: TextStyle(
                              color: CaviaColors.vermilionBright,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 175,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: library.playlists.length,
                          itemBuilder: (context, index) {
                            final pl = library.playlists[index];
                            return Container(
                              width: 140,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              child: CaviaPlaylistCard(
                                playlist: pl,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PlaylistDetailScreen(playlistId: pl.id),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  // Albums Collection Preview
                  if (library.albums.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: CaviaSectionHeader(
                        title: 'Albums',
                        trailing: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AlbumsCollectionScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'See all',
                            style: TextStyle(
                              color: CaviaColors.vermilionBright,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 190,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: library.albums.length,
                          itemBuilder: (context, index) {
                            final album = library.albums[index];
                            return Container(
                              width: 140,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              child: CaviaAlbumCard(
                                album: album,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AlbumsCollectionScreen(),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],

                  // Bottom padding for mini-player clearance
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCollectionChips(BuildContext context, dynamic library) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _CollectionChip(
            label: 'Playlists (${library.playlists.length})',
            icon: Icons.queue_music_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PlaylistsCollectionScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          _CollectionChip(
            label: 'Albums (${library.albums.length})',
            icon: Icons.album_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AlbumsCollectionScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          _CollectionChip(
            label: 'Artists (${library.artists.length})',
            icon: Icons.person_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ArtistsCollectionScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLikedSongsCard(
    BuildContext context,
    dynamic library,
    dynamic playback,
  ) {
    final count = library.likedSongs.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Material(
        color: CaviaColors.cardBackground,
        borderRadius: BorderRadius.circular(CaviaGlass.radiusCard),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LikedSongsScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(CaviaGlass.radiusCard),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(CaviaGlass.radiusCard),
              border: Border.all(color: CaviaColors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(CaviaGlass.radiusMedium),
                    color: CaviaColors.vermilion.withValues(alpha: 0.18),
                    border: Border.all(
                      color: CaviaColors.vermilionBright.withValues(alpha: 0.5),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: CaviaColors.vermilionBright,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Liked Songs',
                        style: CaviaTypography.titleMedium,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$count tracks saved',
                        style: CaviaTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.play_circle_fill_rounded,
                    color: CaviaColors.vermilionBright,
                    size: 38,
                  ),
                  onPressed: () {
                    playback.playQueue(library.likedSongs);
                  },
                  tooltip: 'Play Liked Songs',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CollectionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CollectionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: CaviaColors.glassSurface,
        borderRadius: BorderRadius.circular(CaviaGlass.radiusPill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CaviaGlass.radiusPill),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(CaviaGlass.radiusPill),
              border: Border.all(color: CaviaColors.glassBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: CaviaColors.textSilver),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: CaviaTypography.labelMedium.copyWith(
                    color: CaviaColors.textIvory,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
