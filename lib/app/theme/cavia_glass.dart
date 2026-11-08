import 'package:flutter/material.dart';
import 'cavia_colors.dart';

/// Glassmorphism design tokens and styling configurations.
/// Standardizes blur levels, corner radii, borders, and shadows.
class CaviaGlass {
  CaviaGlass._();

  // Blur values
  static const double blurLight = 10.0;
  static const double blurStandard = 18.0;
  static const double blurHeavy = 28.0;

  // Corner Radii (8-pt & 4-pt grid based)
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 14.0;
  static const double radiusCard = 18.0;
  static const double radiusLarge = 24.0;
  static const double radiusPill = 999.0;

  // Glass Container Decoration (Harmonized with GlassContainer widget)
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
            (glow ? CaviaColors.vermilionBright.withValues(alpha: 0.6) : CaviaColors.glassBorder),
        width: glow ? 1.5 : 1.0,
      ),
      boxShadow: [
        if (glow)
          BoxShadow(
            color: CaviaColors.vermilion.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  // Specular Border Gradient for liquid glass sheen
  static Gradient specularBorder({bool glow = false}) {
    if (glow) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          CaviaColors.vermilion,
          CaviaColors.vermilion.withValues(alpha: 0.2),
          CaviaColors.vermilion.withValues(alpha: 0.1),
          CaviaColors.vermilion.withValues(alpha: 0.4),
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
