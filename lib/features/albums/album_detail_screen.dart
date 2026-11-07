import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import '../../core/components/japanese_scenery_background.dart';
import '../../core/components/artwork_view.dart';
import '../../core/components/context_menus.dart';
import '../../core/components/toast.dart';
import '../../core/models/music_models.dart';
import '../../core/state/app_state_scope.dart';

class AlbumDetailScreen extends StatelessWidget {
  final Album album;

  const AlbumDetailScreen({super.key, required this.album});

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

    return ListenableBuilder(
      listenable: Listenable.merge([library, playback]),
      builder: (context, _) {
        final currentAlbum = library.albums.firstWhere(
          (a) => a.id == album.id,
          orElse: () => album,
        );
        final songs = currentAlbum.songs;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Atmospheric Background
              JapaneseSceneryBackground(
                imageAsset: currentAlbum.artworkAsset,
                opacity: 0.35,
              ),

              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 330,
                    pinned: true,
                    backgroundColor: CaviaColors.background.withValues(alpha: 0.8),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: CaviaColors.textIvory,
                      onPressed: () => Navigator.pop(context),
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          currentAlbum.isSaved
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: currentAlbum.isSaved
                              ? CaviaColors.vermilionBright
                              : CaviaColors.textIvory,
                        ),
                        onPressed: () {
                          library.toggleSaveAlbum(currentAlbum.id);
                          CaviaToast.show(
                            context,
                            currentAlbum.isSaved
                                ? 'Removed from saved albums'
                                : 'Saved to library',
                            icon: Icons.favorite_rounded,
                          );
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
                              imageAsset: currentAlbum.artworkAsset,
                              width: 160,
                              height: 160,
                              radius: CaviaGlass.radiusCard,
                              heroTag: 'album_${currentAlbum.id}',
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currentAlbum.title,
                              style: CaviaTypography.display.copyWith(fontSize: 22),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${currentAlbum.artist} • ${currentAlbum.year} • ${songs.length} tracks (${_formatTotalDuration(songs)})',
                              style: CaviaTypography.caption,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Actions
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (songs.isNotEmpty) {
                                  playback.playNow(songs.first);
                                }
                              },
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Play Album'),
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
                                  final shuffled = List<Song>.from(songs)..shuffle();
                                  playback.playNow(shuffled.first);
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

                  // Track List
                  SliverPadding(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final song = songs[index];
                          final isCurrent =
                              playback.currentSong?.id == song.id;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            leading: SizedBox(
                              width: 32,
                              child: isCurrent
                                  ? const Icon(
                                      Icons.graphic_eq_rounded,
                                      color: CaviaColors.vermilionBright,
                                      size: 18,
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: CaviaTypography.caption,
                                      textAlign: TextAlign.center,
                                    ),
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
                              playback.playNow(song);
                            },
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
  }
}
