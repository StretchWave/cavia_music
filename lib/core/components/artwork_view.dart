import 'dart:io';
import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_glass.dart';

/// Album artwork presentation with liquid glass arc refraction overlay and optional Hero transition.
/// Unified component for all artwork displays across Cavia Music.
class CaviaArtwork extends StatelessWidget {
  final String imageAsset;
  final double? width;
  final double? height;
  final double radius;
  final String? heroTag;
  final bool showGlassArc;
  final VoidCallback? onTap;

  const CaviaArtwork({
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
            _buildImage(),

            // Liquid Glass curved reflection
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
                    stops: const [0.0, 0.5, 1.0],
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
        child: artwork,
      );
    }

    return artwork;
  }

  Widget _buildImage() {
    final trimmed = imageAsset.trim();
    if (trimmed.isEmpty) {
      return _buildFallback();
    }

    final targetCacheWidth = width != null ? (width! * 2).round() : null;
    final targetCacheHeight = height != null ? (height! * 2).round() : null;

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return Image.network(
        trimmed,
        fit: BoxFit.cover,
        cacheWidth: targetCacheWidth,
        cacheHeight: targetCacheHeight,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      );
    }

    if (trimmed.startsWith('file://') || File(trimmed).isAbsolute) {
      final filePath = trimmed.startsWith('file://')
          ? trimmed.replaceFirst('file://', '')
          : trimmed;
      final file = File(filePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          cacheWidth: targetCacheWidth,
          cacheHeight: targetCacheHeight,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        );
      }
    }

    return Image.asset(
      trimmed,
      fit: BoxFit.cover,
      cacheWidth: targetCacheWidth,
      cacheHeight: targetCacheHeight,
      errorBuilder: (context, error, stackTrace) => _buildFallback(),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: CaviaColors.surfaceDark,
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          color: CaviaColors.textSilver.withValues(alpha: 0.6),
          size: (width != null && width! < 60) ? 20 : 32,
        ),
      ),
    );
  }
}

/// Backward compatibility alias for ArtworkView.
typedef ArtworkView = CaviaArtwork;

/// Renders a liquid glass arc light refraction across the upper half of artwork.
class _LiquidGlassArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Diagonal specular sweep
    final sweepPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.22),
          Colors.white.withValues(alpha: 0.08),
          Colors.white.withValues(alpha: 0.0),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.70, 1.0],
      ).createShader(rect);

    final sweepPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.75, 0)
      ..lineTo(0, size.height * 0.75)
      ..close();

    canvas.drawPath(sweepPath, sweepPaint);

    // Curved lens arc highlight across top
    final arcPath = Path()
      ..moveTo(0, size.height * 0.35)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.55,
        size.width,
        size.height * 0.20,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    final arcPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.14),
          Colors.white.withValues(alpha: 0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(rect);

    canvas.drawPath(arcPath, arcPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
