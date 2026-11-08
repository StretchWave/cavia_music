import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../domain/models/artist.dart';
import 'artwork_view.dart';

/// Circular artist portrait presentation for grids and carousels.
class CaviaArtistCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback onTap;
  final double? width;

  const CaviaArtistCard({
    super.key,
    required this.artist,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${artist.name}, artist',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: artist.isFollowed
                          ? CaviaColors.vermilionBright
                          : CaviaColors.glassBorderSubtle,
                      width: 1.5,
                    ),
                    boxShadow: [
                      if (artist.isFollowed)
                        BoxShadow(
                          color: CaviaColors.vermilion.withValues(alpha: 0.25),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                  child: ClipOval(
                    child: CaviaArtwork(
                      imageAsset: artist.portraitAsset,
                      radius: 999,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                artist.name,
                style: CaviaTypography.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                'Artist',
                style: CaviaTypography.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontal artist row for lists and directory views.
class CaviaArtistRow extends StatelessWidget {
  final Artist artist;
  final VoidCallback onTap;
  final VoidCallback? onFollowToggle;

  const CaviaArtistRow({
    super.key,
    required this.artist,
    required this.onTap,
    this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${artist.name}, artist',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: artist.isFollowed
                          ? CaviaColors.vermilionBright
                          : CaviaColors.glassBorderSubtle,
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: CaviaArtwork(
                      imageAsset: artist.portraitAsset,
                      radius: 999,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        artist.name,
                        style: CaviaTypography.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${artist.albums.length} albums • ${artist.popularSongs.length} tracks',
                        style: CaviaTypography.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (onFollowToggle != null)
                  TextButton(
                    onPressed: onFollowToggle,
                    style: TextButton.styleFrom(
                      foregroundColor: artist.isFollowed
                          ? CaviaColors.vermilionBright
                          : CaviaColors.textSilver,
                      backgroundColor: artist.isFollowed
                          ? CaviaColors.vermilionSubtle
                          : CaviaColors.glassSurface,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: artist.isFollowed
                              ? CaviaColors.vermilionBright
                              : CaviaColors.glassBorder,
                        ),
                      ),
                    ),
                    child: Text(
                      artist.isFollowed ? 'Following' : 'Follow',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

