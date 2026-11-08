import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_glass.dart';
import '../../app/theme/cavia_typography.dart';
import '../models/music_models.dart';
import 'cavia_artwork.dart';

/// Card component dedicated to recently played tracks in horizontal carousels.
/// Displays the track's own artwork, title, and artist without requiring
/// an album reference or failing when albums are empty.
class CaviaRecentTrackCard extends StatelessWidget {
  final Song track;
  final VoidCallback onTap;
  final double? width;
  final bool isPlaying;

  const CaviaRecentTrackCard({
    super.key,
    required this.track,
    required this.onTap,
    this.width,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Play ${track.title} by ${track.artist}',
      child: Tooltip(
        message: 'Play "${track.title}"',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CaviaGlass.radiusMedium),
          child: Container(
            width: width ?? 130,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(CaviaGlass.radiusMedium),
              border: Border.all(
                color: isPlaying
                    ? CaviaColors.vermilionBright.withValues(alpha: 0.6)
                    : Colors.transparent,
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CaviaArtwork(
                          imageAsset: track.artworkAsset,
                          radius: CaviaGlass.radiusMedium,
                        ),
                      ),
                      if (isPlaying)
                        Positioned(
                          right: 6,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: CaviaColors.vermilionBright,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 14,
                              color: CaviaColors.textIvory,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  track.title,
                  style: CaviaTypography.titleSmall.copyWith(
                    color: isPlaying ? CaviaColors.vermilionBright : CaviaColors.textIvory,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  track.artist,
                  style: CaviaTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

