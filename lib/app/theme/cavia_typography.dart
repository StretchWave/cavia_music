import 'package:flutter/material.dart';
import 'cavia_colors.dart';

/// Distinctive editorial typography system for Cavia Music:
/// Japanese Editorial × Restrained Liquid Glass.
///
/// Follows an 8-pt / 4-pt grid rhythm with strict contrast standards (WCAG AA).
class CaviaTypography {
  CaviaTypography._();

  // --- Display & Hero Titles ---
  static const TextStyle displayLarge = TextStyle(
    color: CaviaColors.textIvory,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    color: CaviaColors.textIvory,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    color: CaviaColors.textIvory,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.25,
  );

  // --- Titles ---
  static const TextStyle titleLarge = TextStyle(
    color: CaviaColors.textIvory,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static const TextStyle titleMedium = TextStyle(
    color: CaviaColors.textIvory,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static const TextStyle titleSmall = TextStyle(
    color: CaviaColors.textIvory,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.0,
  );

  // --- Body ---
  static const TextStyle bodyMedium = TextStyle(
    color: CaviaColors.textIvoryMuted,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static const TextStyle bodySmall = TextStyle(
    color: CaviaColors.textSilver,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  );

  // --- Labels & Overlines ---
  static const TextStyle labelLarge = TextStyle(
    color: CaviaColors.textIvory,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle labelMedium = TextStyle(
    color: CaviaColors.textSilver,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle labelSmall = TextStyle(
    color: CaviaColors.textDim,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  static const TextStyle overline = TextStyle(
    color: CaviaColors.vermilion,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.5,
  );

  // --- Brand Elements ---
  static const TextStyle wordmark = TextStyle(
    color: CaviaColors.textIvory,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 6.0,
  );

  static const TextStyle kanjiHeader = TextStyle(
    color: CaviaColors.textIvory,
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 1.1,
  );

  // --- Lyrics ---
  static const TextStyle lyricActive = TextStyle(
    color: CaviaColors.textIvory,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.4,
  );

  static const TextStyle lyricInactive = TextStyle(
    color: CaviaColors.textDim,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    height: 1.4,
  );

  // ==========================================
  // Backward-Compatible Aliases
  // ==========================================
  static const TextStyle display = displayMedium;
  static const TextStyle songTitleLarge = displayMedium;
  static const TextStyle songTitle = titleMedium;
  static const TextStyle artistSubtitle = bodySmall;
  static const TextStyle caption = labelSmall;
  static const TextStyle body = bodyMedium;
  static const TextStyle sectionLabel = overline;
}
