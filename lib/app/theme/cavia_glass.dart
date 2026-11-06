import 'package:flutter/material.dart';
import 'cavia_colors.dart';

/// Glassmorphism design tokens and styling configurations.
class CaviaGlass {
  CaviaGlass._();

  // Blur values
  static const double blurLight = 10.0;
  static const double blurStandard = 18.0;
  static const double blurHeavy = 28.0;

  // Corner Radii
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 18.0;
  static const double radiusLarge = 24.0;
  static const double radiusCard = 22.0;
  static const double radiusPill = 999.0;

  // Glass Container Decoration
  static BoxDecoration box({
    double radius = radiusMedium,
    bool glow = false,
    Color? surfaceColor,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: surfaceColor ?? CaviaColors.glassSurface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ??
            (glow ? CaviaColors.vermilion.withValues(alpha: 0.5) : CaviaColors.glassBorder),
        width: glow ? 1.4 : 1.0,
      ),
      boxShadow: [
        if (glow)
          BoxShadow(
            color: CaviaColors.vermilion.withValues(alpha: 0.25),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  // Specular Border Gradient for liquid glass sheen
  static Gradient specularBorder({bool glow = false}) {
    if (glow) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE53935),
          Color(0x33E53935),
          Color(0x1AE53935),
          Color(0x66E53935),
        ],
      );
    }
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0x40FFFFFF),
        Color(0x10FFFFFF),
        Color(0x05FFFFFF),
        Color(0x20FFFFFF),
      ],
      stops: [0.0, 0.4, 0.7, 1.0],
    );
  }
}

