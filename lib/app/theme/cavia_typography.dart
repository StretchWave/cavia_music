import 'package:flutter/material.dart';
import 'cavia_colors.dart';

/// Distinctive editorial typography system for Cavia_Music.
/// Features Japanese Kanji displays, spaced wordmarks, and high-readability body text.
class CaviaTypography {
  CaviaTypography._();

  // Wordmark: S O N A R A /
  static const TextStyle wordmark = TextStyle(
    color: CaviaColors.textIvory,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 6.0,
  );

  // Large Japanese Kanji Headings (e.g. 藏, 探, 設定)
  static const TextStyle kanjiHeader = TextStyle(
    color: CaviaColors.textIvory,
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 1.1,
  );

  // Section Sub-labels in Vermilion (e.g. L I B R A R Y, S E A R C H, S E T T I N G S)
  static const TextStyle sectionLabel = TextStyle(
    color: CaviaColors.vermilion,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 3.5,
  );

  // Screen Title (Large Display)
  static const TextStyle display = TextStyle(
    color: CaviaColors.textIvory,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  // Now Playing Track Title
  static const TextStyle songTitleLarge = TextStyle(
    color: CaviaColors.textIvory,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
  );

  // Standard Track Title in Lists
  static const TextStyle songTitle = TextStyle(
    color: CaviaColors.textIvory,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  // Artist & Secondary Text
  static const TextStyle artistSubtitle = TextStyle(
    color: CaviaColors.textSilver,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
  );

  // Small Timestamps & Metadata
  static const TextStyle caption = TextStyle(
    color: CaviaColors.textDim,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  // Body Text for descriptions / settings
  static const TextStyle body = TextStyle(
    color: CaviaColors.textIvoryMuted,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  // Active / Highlighted Lyrics
  static const TextStyle lyricActive = TextStyle(
    color: CaviaColors.textIvory,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.4,
  );

  // Inactive Lyrics Line
  static const TextStyle lyricInactive = TextStyle(
    color: CaviaColors.textDim,
    fontSize: 19,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
    height: 1.4,
  );
}

