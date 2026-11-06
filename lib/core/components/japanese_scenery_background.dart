import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';

/// Atmospheric backdrop that renders Japanese sumi-e artwork with protective gradients.
class JapaneseSceneryBackground extends StatelessWidget {
  final String? imageAsset;
  final Widget? child;
  final double opacity;
  final bool showVignette;

  const JapaneseSceneryBackground({
    super.key,
    this.imageAsset = 'assets/images/bg_library.jpg',
    this.child,
    this.opacity = 0.55,
    this.showVignette = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Solid deep charcoal base
        const ColoredBox(color: CaviaColors.background),

        // Atmospheric Image layer if provided
        if (imageAsset != null)
          Positioned.fill(
            child: Opacity(
              opacity: opacity,
              child: Image.asset(
                imageAsset!,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

        // Japanese Ink & Mist Gradient: ensures high contrast for typography
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CaviaColors.background.withValues(alpha: 0.35),
                  CaviaColors.background.withValues(alpha: 0.65),
                  CaviaColors.background.withValues(alpha: 0.95),
                  CaviaColors.background,
                ],
                stops: const [0.0, 0.35, 0.75, 1.0],
              ),
            ),
          ),
        ),

        // Subtle Vermilion Ambient Warmth in bottom reflections
        Positioned(
          bottom: -80,
          left: 0,
          right: 0,
          height: 220,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.bottomCenter,
                radius: 1.2,
                colors: [
                  CaviaColors.vermilion.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Optional Vignette around borders
        if (showVignette)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.0,
                  colors: [
                    Colors.transparent,
                    CaviaColors.background.withValues(alpha: 0.4),
                    CaviaColors.background.withValues(alpha: 0.8),
                  ],
                  stops: const [0.5, 0.85, 1.0],
                ),
              ),
            ),
          ),

        // Content
        ?child,
      ],
    );
  }
}
