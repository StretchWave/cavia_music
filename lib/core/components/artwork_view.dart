import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_glass.dart';

/// Album artwork presentation with liquid glass arc refraction overlay and Hero transition.
class ArtworkView extends StatelessWidget {
  final String imageAsset;
  final double? width;
  final double? height;
  final double radius;
  final String? heroTag;
  final bool showGlassArc;
  final VoidCallback? onTap;

  const ArtworkView({
    super.key,
    required this.imageAsset,
    this.width,
    this.height,
    this.radius = CaviaGlass.radiusCard,
    this.heroTag,
    this.showGlassArc = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget artwork = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: CaviaColors.glassBorderSubtle,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: CaviaColors.vermilion.withValues(alpha: 0.1),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Artwork Image
            imageAsset.startsWith('http://') || imageAsset.startsWith('https://')
                ? Image.network(
                    imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: CaviaColors.surfaceDark,
                        child: const Center(
                          child: Icon(
                            Icons.music_note_rounded,
                            color: CaviaColors.textSilver,
                            size: 32,
                          ),
                        ),
                      );
                    },
                  )
                : Image.asset(
                    imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: CaviaColors.surfaceDark,
                        child: const Center(
                          child: Icon(
                            Icons.music_note_rounded,
                            color: CaviaColors.textSilver,
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),

            // Liquid Glass curved reflection (seen on Now Playing screen)
            if (showGlassArc)
              Positioned.fill(
                child: CustomPaint(
                  painter: _LiquidGlassArcPainter(),
                ),
              ),

            // Subtle top-edge light highlight
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 1.5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.6),
                      Colors.white.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (heroTag != null) {
      artwork = Hero(
        tag: heroTag!,
        child: artwork,
      );
    }

    if (onTap != null) {
      artwork = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: artwork,
      );
    }

    return artwork;
  }
}

/// Draws the elegant liquid glass arc light refraction across the artwork.
class _LiquidGlassArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    // Sweeping glass lens reflection arc from top-left curving down toward right
    path.moveTo(0, size.height * 0.45);
    path.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.15,
      size.width * 0.85,
      0,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.35);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.55,
      0,
      size.height * 0.85,
    );
    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.22),
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);

    // Fine specular curved edge ring
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final arcLine = Path();
    arcLine.moveTo(0, size.height * 0.45);
    arcLine.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.15,
      size.width * 0.85,
      0,
    );
    canvas.drawPath(arcLine, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

