import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import '../../core/components/glass_container.dart';
import '../../core/components/japanese_scenery_background.dart';
import '../../core/components/artwork_view.dart';
import '../../core/components/waveform_visualizer.dart';
import '../../core/components/animated_play_pause.dart';
import '../../core/components/context_menus.dart';
import '../../core/state/playback_controller.dart';
import '../../core/state/app_state_scope.dart';
import '../queue/queue_sheet.dart';
import '../lyrics/lyrics_screen.dart';

class FullPlayerView extends StatefulWidget {
  final VoidCallback onCollapse;

  const FullPlayerView({super.key, required this.onCollapse});

  @override
  State<FullPlayerView> createState() => _FullPlayerViewState();
}

class _FullPlayerViewState extends State<FullPlayerView> {
  bool _showQueue = false;
  bool _showLyrics = false;

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final playback = AppStateScope.playbackOf(context);
    final library = AppStateScope.libraryOf(context);

    return ListenableBuilder(
      listenable: Listenable.merge([playback, library]),
      builder: (context, _) {
        final song = playback.currentSong;
        final isLiked = library.isSongLiked(song.id);

        if (_showLyrics) {
          return LyricsScreen(
            onClose: () => setState(() => _showLyrics = false),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Atmospheric Background derived from artwork/sumi-e
              JapaneseSceneryBackground(
                imageAsset: song.artworkAsset,
                opacity: 0.35,
              ),

              // Main Player Content
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final artSize = (constraints.maxHeight * 0.38).clamp(180.0, 320.0);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight - 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Top Bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 32,
                                  ),
                                  color: CaviaColors.textIvory,
                                  onPressed: widget.onCollapse,
                                ),
                                Text(
                                  'NOW PLAYING',
                                  style: CaviaTypography.sectionLabel.copyWith(
                                    fontSize: 11,
                                    color: CaviaColors.textSilver,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.more_vert_rounded),
                                  color: CaviaColors.textIvory,
                                  onPressed: () => TrackContextMenu.show(context, song),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Large Album Artwork with Liquid Glass Arc Reflection
                            Center(
                              child: ArtworkView(
                                imageAsset: song.artworkAsset,
                                width: artSize,
                                height: artSize,
                                radius: CaviaGlass.radiusCard,
                                showGlassArc: true,
                                heroTag: 'player_artwork',
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Track Title, Artist & Like Heart
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        song.title,
                                        style: CaviaTypography.songTitleLarge,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        song.artist,
                                        style: CaviaTypography.artistSubtitle.copyWith(
                                          fontSize: 15,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    isLiked
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: isLiked
                                        ? CaviaColors.vermilionBright
                                        : CaviaColors.textSilver,
                                    size: 26,
                                  ),
                                  onPressed: () => library.toggleLikeSong(song),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Interactive Crimson Waveform Visualizer Scrubber
                            WaveformVisualizer(
                              progress: playback.progress,
                              isPlaying: playback.isPlaying,
                              onSeek: playback.seekTo,
                              height: 38,
                            ),
                            const SizedBox(height: 6),

                            // Timestamps (Current & Total)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(playback.currentPosition),
                                  style: CaviaTypography.caption,
                                ),
                                Text(
                                  _formatDuration(playback.totalDuration),
                                  style: CaviaTypography.caption,
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Playback Controls Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Shuffle
                                IconButton(
                                  icon: Icon(
                                    Icons.shuffle_rounded,
                                    color: playback.isShuffle
                                        ? CaviaColors.vermilionBright
                                        : CaviaColors.textSilver,
                                  ),
                                  onPressed: playback.toggleShuffle,
                                ),

                                // Previous
                                IconButton(
                                  icon: const Icon(
                                    Icons.skip_previous_rounded,
                                    size: 32,
                                  ),
                                  color: CaviaColors.textIvory,
                                  onPressed: playback.skipPrevious,
                                ),

                                // Large Concentric Glowing Play / Pause
                                AnimatedPlayPauseButton(
                                  isPlaying: playback.isPlaying,
                                  onTap: playback.togglePlayPause,
                                  size: 64,
                                  iconSize: 32,
                                ),

                                // Next
                                IconButton(
                                  icon: const Icon(
                                    Icons.skip_next_rounded,
                                    size: 32,
                                  ),
                                  color: CaviaColors.textIvory,
                                  onPressed: playback.skipNext,
                                ),

                                // Repeat Mode
                                IconButton(
                                  icon: Icon(
                                    playback.repeatMode == CaviaRepeatMode.one
                                        ? Icons.repeat_one_rounded
                                        : Icons.repeat_rounded,
                                    color: playback.repeatMode != CaviaRepeatMode.off
                                        ? CaviaColors.vermilionBright
                                        : CaviaColors.textSilver,
                                  ),
                                  onPressed: playback.cycleRepeatMode,
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Floating Bottom Glass Toolbar (Queue, Waveform/Equalizer, Lyrics)
                            GlassContainer(
                              radius: CaviaGlass.radiusPill,
                              blur: CaviaGlass.blurHeavy,
                              surfaceColor: CaviaColors.glassSurface,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 6,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.queue_music_rounded),
                                    color: _showQueue
                                        ? CaviaColors.vermilionBright
                                        : CaviaColors.textIvory,
                                    tooltip: 'Queue',
                                    onPressed: () {
                                      setState(() {
                                        _showQueue = !_showQueue;
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: const Icon(Icons.graphic_eq_rounded),
                                    color: playback.isPlaying
                                        ? CaviaColors.vermilionBright
                                        : CaviaColors.textSilver,
                                    tooltip: 'Visualizer',
                                    onPressed: () {},
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: const Icon(Icons.lyrics_rounded),
                                    color: CaviaColors.textIvory,
                                    tooltip: 'Lyrics',
                                    onPressed: () {
                                      setState(() {
                                        _showLyrics = true;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Queue Drawer Overlay
              if (_showQueue)
                Positioned.fill(
                  child: QueueSheet(
                    onClose: () => setState(() => _showQueue = false),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
