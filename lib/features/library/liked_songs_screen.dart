import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_glass.dart';
import '../../core/components/cavia_page_header.dart';
import '../../core/components/cavia_track_row.dart';
import '../../core/components/cavia_feedback_states.dart';
import '../../core/state/app_state_scope.dart';

/// Clean Liked Songs view backed exclusively by the user's liked tracks.
class LikedSongsScreen extends StatelessWidget {
  const LikedSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final library = AppStateScope.libraryOf(context);
    final playback = AppStateScope.playbackOf(context);

    return ListenableBuilder(
      listenable: Listenable.merge([library, playback]),
      builder: (context, _) {
        final songs = library.likedSongs;

        return Scaffold(
          backgroundColor: CaviaColors.background,
          body: SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: CaviaPageHeader(
                    title: 'Liked Songs',
                    subtitle: '${songs.length} tracks saved to your favorites',
                    showBackButton: true,
                  ),
                ),

                if (songs.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
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

                if (songs.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: CaviaEmptyState(
                      icon: Icons.favorite_border_rounded,
                      title: 'No Liked Songs Yet',
                      subtitle: 'Tap the heart icon on any track to save it here for offline listening.',
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
          ),
        );
      },
    );
  }
}
