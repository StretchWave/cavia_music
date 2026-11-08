import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import '../../core/components/cavia_artwork.dart';
import '../../core/components/cavia_track_row.dart';
import '../../core/components/cavia_dialog.dart';
import '../../core/components/cavia_feedback_states.dart';
import '../../core/components/toast.dart';
import '../../core/models/music_models.dart';
import '../../core/state/app_state_scope.dart';
import 'playlist_edit_dialog.dart';

/// Redesigned Playlist Detail Screen: Stable Keys for Duplicates × Unified CaviaTrackRow.
class PlaylistDetailScreen extends StatelessWidget {
  final String playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  String _formatTotalDuration(List<Song> songs) {
    final totalSec = songs.fold<int>(0, (sum, s) => sum + s.duration.inSeconds);
    final min = totalSec ~/ 60;
    return '$min min';
  }

  @override
  Widget build(BuildContext context) {
    final library = AppStateScope.libraryOf(context);
    final playback = AppStateScope.playbackOf(context);
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = (screenHeight * 0.40).clamp(280.0, 360.0);
    final artSize = (heroHeight * 0.48).clamp(130.0, 170.0);

    return StreamBuilder<List<Song>>(
      stream: library.watchPlaylistSongs(playlistId),
      initialData: const <Song>[],
      builder: (context, songsSnapshot) {
        final songs = songsSnapshot.data ?? const <Song>[];

        return ListenableBuilder(
          listenable: Listenable.merge([library, playback]),
          builder: (context, _) {
            final playlistList = library.playlists.where((p) => p.id == playlistId);
            if (playlistList.isEmpty) {
              return Scaffold(
                backgroundColor: CaviaColors.background,
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                body: const CaviaEmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Playlist Not Found',
                  subtitle: 'This playlist may have been deleted or moved.',
                ),
              );
            }
            final playlist = playlistList.first;

            return Scaffold(
              backgroundColor: CaviaColors.background,
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: heroHeight,
                    pinned: true,
                    backgroundColor: CaviaColors.background.withValues(alpha: 0.9),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      color: CaviaColors.textIvory,
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'Back',
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, size: 20),
                        color: CaviaColors.textIvory,
                        tooltip: 'Edit Playlist',
                        onPressed: () => PlaylistEditDialog.show(context, playlist),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 20),
                        color: CaviaColors.vermilionBright,
                        tooltip: 'Delete Playlist',
                        onPressed: () async {
                          final confirm = await CaviaDialog.show(
                            context,
                            title: 'Delete Playlist',
                            content: 'Are you sure you want to remove "${playlist.name}"? This action cannot be undone.',
                            confirmLabel: 'Delete',
                            isDestructive: true,
                          );
                          if (confirm == true && context.mounted) {
                            library.deletePlaylist(playlist.id);
                            Navigator.pop(context);
                            CaviaToast.show(context, 'Playlist deleted');
                          }
                        },
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 36),
                            CaviaArtwork(
                              imageAsset: playlist.artworkAsset,
                              width: artSize,
                              height: artSize,
                              radius: CaviaGlass.radiusCard,
                              heroTag: 'playlist_${playlist.id}',
                            ),
                            const SizedBox(height: 14),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                playlist.name,
                                style: CaviaTypography.displayMedium.copyWith(fontSize: 20),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${songs.length} tracks • ${_formatTotalDuration(songs)}',
                              style: CaviaTypography.caption,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Actions: Play & Shuffle
                  if (songs.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  playback.playQueue(songs, initialIndex: 0);
                                },
                                icon: const Icon(Icons.play_arrow_rounded),
                                label: const Text('Play All'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: CaviaColors.vermilion,
                                  foregroundColor: CaviaColors.textIvory,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(CaviaGlass.radiusPill),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  playback.playQueue(songs, shuffle: true);
                                },
                                icon: const Icon(Icons.shuffle_rounded),
                                label: const Text('Shuffle'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: CaviaColors.textIvory,
                                  side: const BorderSide(color: CaviaColors.glassBorder),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(CaviaGlass.radiusPill),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Optional Description
                  if (playlist.description.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                        child: Text(
                          playlist.description,
                          style: CaviaTypography.bodySmall,
                        ),
                      ),
                    ),

                  // Track List with Safe Dismissible Keys
                  if (songs.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: CaviaEmptyState(
                        icon: Icons.queue_music_rounded,
                        title: 'Playlist is Empty',
                        subtitle: 'Search tracks and add them to this playlist.',
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final song = songs[index];
                          final isCurrent = playback.currentSong?.id == song.id;

                          return Dismissible(
                            // Unique key supporting duplicate entries at distinct positions
                            key: ValueKey('${playlist.id}_${song.id}_$index'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: CaviaColors.vermilion.withValues(alpha: 0.3),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: CaviaColors.vermilionBright,
                              ),
                            ),
                            onDismissed: (_) async {
                              final removed = await library.removePlaylistEntry(
                                playlist.id,
                                trackId: song.id,
                              );
                              if (context.mounted && removed) {
                                CaviaToast.show(
                                  context,
                                  'Removed "${song.title}" from playlist',
                                  icon: Icons.remove_circle_outline_rounded,
                                );
                              }
                            },
                            child: CaviaTrackRow(
                              track: song,
                              index: index,
                              showIndex: true,
                              isCurrent: isCurrent,
                              isPlaying: isCurrent && playback.isPlaying,
                              onTap: () => playback.playQueue(songs, initialIndex: index),
                            ),
                          );
                        },
                        childCount: songs.length,
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
