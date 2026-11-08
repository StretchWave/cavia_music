import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import '../../core/components/cavia_glass_surface.dart';
import '../../core/components/cavia_artwork.dart';
import '../../core/components/animated_play_pause.dart';
import '../../core/state/app_state_scope.dart';

/// Floating & docked mini-player.
/// Serves as the persistent entry point to the Full Player with real playback feedback.
class MiniPlayer extends StatelessWidget {
  final VoidCallback onTap;

  const MiniPlayer({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final playback = AppStateScope.playbackOf(context);

    return ListenableBuilder(
      listenable: playback,
      builder: (context, _) {
        final song = playback.currentSong;
        if (song == null) return const SizedBox.shrink();

        return Semantics(
          button: true,
          label: 'Mini player: Now playing ${song.title} by ${song.artist}. Tap to open full player.',
          child: CaviaGlassSurface(
            radius: CaviaGlass.radiusMedium,
            blur: CaviaGlass.blurHeavy,
            surfaceColor: CaviaColors.overlaySheet,
            padding: EdgeInsets.zero,
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(CaviaGlass.radiusMedium),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        // Small Artwork
                        CaviaArtwork(
                          imageAsset: song.artworkAsset,
                          width: 44,
                          height: 44,
                          radius: 10,
                        ),
                        const SizedBox(width: 12),

                        // Title & Artist
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: CaviaTypography.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                song.artist,
                                style: CaviaTypography.bodySmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Skip Next Button (secondary quick action)
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            size: 24,
                            color: CaviaColors.textSilver,
                          ),
                          onPressed: playback.skipNext,
                          tooltip: 'Next track',
                          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        ),

                        // Play / Pause Action
                        AnimatedPlayPauseButton(
                          isPlaying: playback.isPlaying,
                          onTap: playback.togglePlayPause,
                          size: 38,
                          iconSize: 20,
                        ),
                      ],
                    ),
                  ),

                  // Subtle Vermilion Progress Line along bottom edge
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 2.0,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: playback.progress.clamp(0.0, 1.0),
                      child: Container(
                        color: CaviaColors.vermilionBright,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
