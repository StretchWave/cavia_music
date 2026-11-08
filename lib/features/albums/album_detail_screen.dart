import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import '../../core/components/cavia_artwork.dart';
import '../../core/components/cavia_track_row.dart';
import '../../core/components/cavia_feedback_states.dart';
import '../../core/components/toast.dart';
import '../../core/models/music_models.dart';
import '../../core/state/app_state_scope.dart';

/// Redesigned Album Detail Screen: Responsive Hero × Unified CaviaTrackRow.
class AlbumDetailScreen extends StatelessWidget {
  final Album album;

  const AlbumDetailScreen({super.key, required this.album});

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

    return ListenableBuilder(
      listenable: Listenable.merge([library, playback]),
      builder: (context, _) {
        final currentAlbum = library.albums.firstWhere(
          (a) => a.id == album.id,
          orElse: () => album,
        );
        final songs = currentAlbum.songs;

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
                    tooltip: currentAlbum.isSaved ? 'Unsave' : 'Save Album',
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 36),
                        CaviaArtwork(
                          imageAsset: currentAlbum.artworkAsset,
                          width: artSize,
                          height: artSize,
                          radius: CaviaGlass.radiusCard,
                          heroTag: 'album_${currentAlbum.id}',
                        ),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            currentAlbum.title,
                            style: CaviaTypography.displayMedium.copyWith(fontSize: 20),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${currentAlbum.artist} • ${currentAlbum.year > 0 ? '${currentAlbum.year} • ' : ''}${songs.length} tracks (${_formatTotalDuration(songs)})',
                          style: CaviaTypography.caption,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Actions (Play / Shuffle)
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
                            label: const Text('Play Album'),
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

              // Track List or Empty State
              if (songs.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: CaviaEmptyState(
                    icon: Icons.album_outlined,
                    title: 'No Tracks Available',
                    subtitle: 'This album has no associated audio tracks in your catalog.',
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = songs[index];
                      final isCurrent = playback.currentSong?.id == song.id;

                      return CaviaTrackRow(
                        track: song,
                        index: index,
                        showIndex: true,
                        showArtwork: false,
                        isCurrent: isCurrent,
                        isPlaying: isCurrent && playback.isPlaying,
                        onTap: () => playback.playQueue(songs, initialIndex: index),
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
  }
}
