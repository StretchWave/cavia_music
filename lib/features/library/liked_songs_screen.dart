import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../core/components/japanese_scenery_background.dart';
import '../../core/components/artwork_view.dart';
import '../../core/components/context_menus.dart';
import '../../core/state/app_state_scope.dart';

/// Liked Songs view backed exclusively by the real like rows in the local
/// database (`watchLikedTracks` family). No cached playlist approximation.
class LikedSongsScreen extends StatelessWidget {
  const LikedSongsScreen({super.key});

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final library = AppStateScope.libraryOf(context);
    final playback = AppStateScope.playbackOf(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const JapaneseSceneryBackground(
            imageAsset: 'assets/images/bg_library.jpg',
            opacity: 0.45,
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          color: CaviaColors.textIvory,
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.favorite_rounded,
                              color: CaviaColors.vermilionBright,
                              size: 20,
                            ),
                            Text(
                              'Liked Songs',
                              style: CaviaTypography.display.copyWith(fontSize: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                SliverPadding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 120),
                  sliver: ListenableBuilder(
                    listenable: library,
                    builder: (context, _) {
                      final songs = library.likedSongs;

                      if (songs.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(top: 48),
                            child: Center(
                              child: Text(
                                'No liked songs yet. Tap the heart on any track.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverList(
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
                              leading: ArtworkView(
                                imageAsset: song.artworkAsset,
                                width: 48,
                                height: 48,
                                radius: 10,
                                heroTag: 'liked_${song.id}',
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
                              trailing: Text(
                                song.duration > Duration.zero
                                    ? _formatDuration(song.duration)
                                    : '',
                                style: CaviaTypography.caption.copyWith(
                                  color: CaviaColors.textDim,
                                ),
                              ),
                              onTap: () => playback.playNow(song),
                              onLongPress: () =>
                                  TrackContextMenu.show(context, song),
                            );
                          },
                          childCount: songs.length,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
