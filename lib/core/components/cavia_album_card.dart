import 'package:flutter/material.dart';
import '../../app/theme/cavia_glass.dart';
import '../../app/theme/cavia_typography.dart';
import '../domain/models/album.dart';
import 'artwork_view.dart';

/// Editorial album card for grids and carousels.
class CaviaAlbumCard extends StatelessWidget {
  final Album album;
  final VoidCallback onTap;
  final double? width;

  const CaviaAlbumCard({
    super.key,
    required this.album,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${album.title} by ${album.artist}, released ${album.year}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1.0,
                child: CaviaArtwork(
                  imageAsset: album.artworkAsset,
                  radius: CaviaGlass.radiusMedium,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                album.title,
                style: CaviaTypography.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${album.artist} • ${album.year}',
                style: CaviaTypography.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
