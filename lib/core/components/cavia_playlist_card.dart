import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_glass.dart';
import '../../app/theme/cavia_typography.dart';
import '../domain/models/playlist.dart';
import 'artwork_view.dart';

/// Clean editorial playlist card for grids and collections.
/// Uses clean solid surface styling with hairline border to avoid expensive BackdropFilters.
class CaviaPlaylistCard extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;
  final VoidCallback? onMorePressed;

  const CaviaPlaylistCard({
    super.key,
    required this.playlist,
    required this.onTap,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${playlist.name}, playlist, ${playlist.trackCount} tracks',
      child: Material(
        color: CaviaColors.cardBackground,
        borderRadius: BorderRadius.circular(CaviaGlass.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CaviaGlass.radiusCard),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(CaviaGlass.radiusCard),
              border: Border.all(
                color: CaviaColors.cardBorder,
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: CaviaArtwork(
                      imageAsset: playlist.artworkAsset,
                      radius: CaviaGlass.radiusMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  playlist.name,
                  style: CaviaTypography.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${playlist.trackCount} tracks',
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

