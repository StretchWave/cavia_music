import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import '../../core/components/glass_container.dart';
import '../../core/components/artwork_view.dart';
import '../../core/components/animated_play_pause.dart';
import '../../core/state/app_state_scope.dart';

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

        return GlassContainer(
          radius: CaviaGlass.radiusMedium,
          blur: CaviaGlass.blurHeavy,
          surfaceColor: CaviaColors.overlaySheet,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          onTap: onTap,
          child: Row(
            children: [
              // Artwork
              ArtworkView(
                imageAsset: song.artworkAsset,
                width: 46,
                height: 46,
                radius: 10,
                heroTag: 'player_artwork',
              ),
              const SizedBox(width: 14),

              // Title & Artist
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      style: CaviaTypography.songTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      song.artist,
                      style: CaviaTypography.artistSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
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
        );
      },
    );
  }
}
