import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../domain/models/track.dart';
import 'artwork_view.dart';
import 'context_menus.dart';

/// Unified, accessible track row used across all screens:
/// Library, Playlists, Albums, Artists, Search, and Queue.
class CaviaTrackRow extends StatelessWidget {
  final Track track;
  final int? index;
  final bool isCurrent;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback? onMorePressed;
  final Widget? trailing;
  final bool showArtwork;
  final bool showIndex;
  final EdgeInsetsGeometry contentPadding;

  const CaviaTrackRow({
    super.key,
    required this.track,
    required this.onTap,
    this.index,
    this.isCurrent = false,
    this.isPlaying = false,
    this.onMorePressed,
    this.trailing,
    this.showArtwork = true,
    this.showIndex = false,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
  });

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isCurrent,
      label: '${track.title} by ${track.artist}',
      child: Material(
        color: isCurrent
            ? CaviaColors.vermilion.withValues(alpha: 0.08)
            : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: () {
            if (onMorePressed != null) {
              onMorePressed!();
            } else {
              TrackContextMenu.show(context, track);
            }
          },
          child: Padding(
            padding: contentPadding,
            child: Row(
              children: [
                // Track Index or Equalizer
                if (showIndex) ...[
                  SizedBox(
                    width: 28,
                    child: isCurrent && isPlaying
                        ? const Icon(
                            Icons.equalizer_rounded,
                            size: 18,
                            color: CaviaColors.vermilionBright,
                          )
                        : Text(
                            index != null ? '${index! + 1}' : '',
                            style: CaviaTypography.caption.copyWith(
                              color: isCurrent
                                  ? CaviaColors.vermilionBright
                                  : CaviaColors.textSilver,
                              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Artwork Thumbnail
                if (showArtwork) ...[
                  CaviaArtwork(
                    imageAsset: track.artworkAsset,
                    width: 44,
                    height: 44,
                    radius: 8,
                  ),
                  const SizedBox(width: 14),
                ],

                // Title & Artist
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        track.title,
                        style: CaviaTypography.titleMedium.copyWith(
                          color: isCurrent
                              ? CaviaColors.vermilionBright
                              : CaviaColors.textIvory,
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        track.artist,
                        style: CaviaTypography.bodySmall.copyWith(
                          color: isCurrent
                              ? CaviaColors.textIvoryMuted
                              : CaviaColors.textSilver,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Duration or Custom Trailing
                if (trailing != null)
                  trailing!
                else ...[
                  if (track.duration > Duration.zero)
                    Text(
                      _formatDuration(track.duration),
                      style: CaviaTypography.caption,
                    ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      size: 18,
                      color: CaviaColors.textSilver,
                    ),
                    onPressed: onMorePressed ?? () => TrackContextMenu.show(context, track),
                    tooltip: 'Track options',
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

