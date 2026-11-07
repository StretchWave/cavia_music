import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import '../../core/components/japanese_scenery_background.dart';
import '../../core/components/artwork_view.dart';
import '../../core/components/context_menus.dart';
import '../../core/components/cavia_dialog.dart';
import '../../core/components/toast.dart';
import '../../core/models/music_models.dart';
import '../../core/state/app_state_scope.dart';
import 'playlist_edit_dialog.dart';

class PlaylistDetailScreen extends StatelessWidget {
  final String playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  String _formatTotalDuration(List<Song> songs) {
    final totalSec = songs.fold<int>(0, (sum, s) => sum + s.duration.inSeconds);
    final min = totalSec ~/ 60;
    return '$min min';
  }

  String _formatTrackDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final library = AppStateScope.libraryOf(context);
    final playback = AppStateScope.playbackOf(context);

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
              return const Scaffold(
                body: Center(child: Text('Playlist not found')),
              );
            }
            final playlist = playlistList.first;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Atmospheric Background
              JapaneseSceneryBackground(
                imageAsset: playlist.artworkAsset,
                opacity: 0.3,
              ),

              CustomScrollView(
                slivers: [
                  // App Bar with Hero Artwork
                  SliverAppBar(
                    expandedHeight: 320,
                    pinned: true,
                    backgroundColor: CaviaColors.background.withValues(alpha: 0.8),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: CaviaColors.textIvory,
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded),
                        color: CaviaColors.textIvory,
                        tooltip: 'Edit Playlist',
                        onPressed: () => PlaylistEditDialog.show(context, playlist),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded),
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
                            const SizedBox(height: 40),
                            ArtworkView(
                              imageAsset: playlist.artworkAsset,
                              width: 160,
                              height: 160,
                              radius: CaviaGlass.radiusCard,
                              heroTag: 'playlist_${playlist.id}',
                            ),
                            const SizedBox(height: 16),
                            Text(
                              playlist.name,
                              style: CaviaTypography.display.copyWith(fontSize: 22),
                              textAlign: TextAlign.center,
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
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (songs.isNotEmpty) {
                                  playback.playQueue(songs, initialIndex: 0);
                                }
                              },
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Play All'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CaviaColors.vermilion,
                                foregroundColor: CaviaColors.textIvory,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                if (songs.isNotEmpty) {
                                  playback.playQueue(songs, shuffle: true);
                                }
                              },
                              icon: const Icon(Icons.shuffle_rounded),
                              label: const Text('Shuffle'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: CaviaColors.textIvory,
                                side: const BorderSide(color: CaviaColors.glassBorder),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Description if available
                  if (playlist.description.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        child: Text(
                          playlist.description,
                          style: CaviaTypography.body.copyWith(
                            color: CaviaColors.textSilver,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 12)),

                  // Track list with Reorder
                  SliverPadding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
                    sliver: songs.isEmpty
                        ? const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 48),
                              child: Center(
                                child: Text(
                                  'Playlist is empty. Add some music.',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final song = songs[index];
                          final isCurrent =
                              playback.currentSong?.id == song.id;

                          return Dismissible(
                            key: ValueKey('${playlist.id}_${song.id}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: CaviaColors.vermilion.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: CaviaColors.vermilionBright,
                              ),
                            ),
                            onDismissed: (_) async {
                              final removed = await library
                                  .removePlaylistEntry(
                                    playlist.id,
                                    trackId: song.id,
                                  );
                              if (context.mounted) {
                                CaviaToast.show(
                                  context,
                                  removed
                                      ? 'Removed from playlist'
                                      : "Couldn't remove the entry",
                                );
                              }
                            },
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 24,
                                    child: Text(
                                      '${index + 1}',
                                      style: CaviaTypography.caption.copyWith(
                                        color: isCurrent
                                            ? CaviaColors.vermilionBright
                                            : CaviaColors.textDim,
                                      ),
                                    ),
                                  ),
                                  ArtworkView(
                                    imageAsset: song.artworkAsset,
                                    width: 44,
                                    height: 44,
                                    radius: 8,
                                  ),
                                ],
                              ),
                              title: Text(
                                song.title,
                                style: CaviaTypography.songTitle.copyWith(
                                  color: isCurrent
                                      ? CaviaColors.vermilionBright
                                      : CaviaColors.textIvory,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                song.artist,
                                style: CaviaTypography.artistSubtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatTrackDuration(song.duration),
                                    style: CaviaTypography.caption,
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
                                playback.playQueue(songs, initialIndex: index);
                              },
                            ),
                          );
                        },
                        childCount: songs.length,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
          },
        );
      },
    );
  }
}
