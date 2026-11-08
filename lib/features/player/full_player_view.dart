import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import '../../core/components/cavia_glass_surface.dart';
import '../../core/components/cavia_artwork.dart';
import '../../core/components/cavia_scrub_bar.dart';
import '../../core/components/animated_play_pause.dart';
import '../../core/components/context_menus.dart';
import '../../core/components/cavia_bottom_sheet.dart';
import '../../core/state/playback_controller.dart';
import '../../core/state/app_state_scope.dart';
import '../queue/queue_sheet.dart';
import '../lyrics/lyrics_screen.dart';

/// Redesigned Full Player: Dominant Artwork × Real Scrubber × Restrained Ambient Bloom.
class FullPlayerView extends StatefulWidget {
  final VoidCallback onCollapse;

  const FullPlayerView({super.key, required this.onCollapse});

  @override
  State<FullPlayerView> createState() => _FullPlayerViewState();
}

class _FullPlayerViewState extends State<FullPlayerView> {
  bool _showLyrics = false;

  void _openQueueSheet(BuildContext context) {
    CaviaBottomSheet.show(
      context: context,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      child: const SizedBox(
        height: 520,
        child: QueueSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playback = AppStateScope.playbackOf(context);
    final library = AppStateScope.libraryOf(context);

    return ListenableBuilder(
      listenable: Listenable.merge([playback, library]),
      builder: (context, _) {
        final song = playback.currentSong;
        if (song == null) {
          return Scaffold(
            backgroundColor: CaviaColors.background,
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 32),
                      color: CaviaColors.textIvory,
                      onPressed: widget.onCollapse,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Nothing is playing yet',
                      style: CaviaTypography.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final isLiked = library.isSongLiked(song.id);

        if (_showLyrics) {
          return LyricsScreen(
            onClose: () => setState(() => _showLyrics = false),
          );
        }

        return Scaffold(
          backgroundColor: CaviaColors.background,
          body: Stack(
            children: [
              // Restrained Ambient Bloom from Artwork
              Positioned.fill(
                child: Opacity(
                  opacity: 0.25,
                  child: CaviaArtwork(
                    imageAsset: song.artworkAsset,
                    radius: 0,
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        CaviaColors.backgroundElevated,
                        CaviaColors.background,
                        CaviaColors.background,
                      ],
                      stops: [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // Main Content
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final artSize = (constraints.maxHeight * 0.40).clamp(200.0, 340.0);

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
                                    size: 30,
                                  ),
                                  color: CaviaColors.textIvory,
                                  tooltip: 'Collapse',
                                  onPressed: widget.onCollapse,
                                ),
                                const Text(
                                  'NOW PLAYING',
                                  style: CaviaTypography.overline,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.more_vert_rounded),
                                  color: CaviaColors.textIvory,
                                  tooltip: 'Track options',
                                  onPressed: () => TrackContextMenu.show(context, song),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Hero Artwork with Liquid Glass Arc
                            Center(
                              child: CaviaArtwork(
                                imageAsset: song.artworkAsset,
                                width: artSize,
                                height: artSize,
                                radius: CaviaGlass.radiusCard,
                                showGlassArc: true,
                              ),
                            ),

                            const SizedBox(height: 20),

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
                                        style: CaviaTypography.displayMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        song.artist,
                                        style: CaviaTypography.bodyMedium.copyWith(
                                          color: CaviaColors.textSilver,
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
                                  tooltip: isLiked ? 'Unlike track' : 'Like track',
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // High-Precision Interactive Scrubber
                            CaviaScrubBar(
                              position: playback.currentPosition,
                              duration: playback.totalDuration,
                              isPlaying: playback.isPlaying,
                              onSeek: playback.seekTo,
                            ),

                            const SizedBox(height: 16),

                            // Primary Playback Controls
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
                                  tooltip: playback.isShuffle ? 'Shuffle on' : 'Shuffle off',
                                  onPressed: playback.toggleShuffle,
                                ),

                                // Skip Previous
                                IconButton(
                                  icon: const Icon(
                                    Icons.skip_previous_rounded,
                                    size: 34,
                                  ),
                                  color: CaviaColors.textIvory,
                                  tooltip: 'Previous',
                                  onPressed: playback.skipPrevious,
                                ),

                                // Glowing Concentric Play / Pause
                                AnimatedPlayPauseButton(
                                  isPlaying: playback.isPlaying,
                                  onTap: playback.togglePlayPause,
                                  size: 64,
                                  iconSize: 32,
                                ),

                                // Skip Next
                                IconButton(
                                  icon: const Icon(
                                    Icons.skip_next_rounded,
                                    size: 34,
                                  ),
                                  color: CaviaColors.textIvory,
                                  tooltip: 'Next',
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
                                  tooltip: playback.repeatMode == CaviaRepeatMode.one
                                      ? 'Repeat one'
                                      : playback.repeatMode == CaviaRepeatMode.all
                                          ? 'Repeat all'
                                          : 'Repeat off',
                                  onPressed: playback.cycleRepeatMode,
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Bottom Glass Action Pills (Queue & Lyrics)
                            CaviaGlassSurface(
                              radius: CaviaGlass.radiusPill,
                              blur: CaviaGlass.blurHeavy,
                              surfaceColor: CaviaColors.glassSurface,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 6,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.queue_music_rounded, size: 22),
                                    color: CaviaColors.textIvory,
                                    tooltip: 'Queue',
                                    onPressed: () => _openQueueSheet(context),
                                  ),
                                  const SizedBox(width: 14),
                                  IconButton(
                                    icon: const Icon(Icons.lyrics_rounded, size: 22),
                                    color: CaviaColors.textIvory,
                                    tooltip: 'Lyrics',
                                    onPressed: () => setState(() => _showLyrics = true),
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
            ],
          ),
        );
      },
    );
  }
}
