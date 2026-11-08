import 'package:flutter/material.dart';

/// Centralized color palette for Cavia Music:
/// Japanese Ink (deep charcoal, soot black, silver mist) × Restrained Liquid Glass & Vermilion Red.
class CaviaColors {
  CaviaColors._();

  // Backgrounds
  static const Color background = Color(0xFF090A0C);
  static const Color backgroundElevated = Color(0xFF101216);
  static const Color surfaceDark = Color(0xFF14171D);
  static const Color surfaceOpaque = Color(0xFF1A1D24);
  static const Color surfaceCard = Color(0xFF161920);
  static const Color surfaceHover = Color(0xFF20242D);

  // Vermilion Primary Accent (used intentionally for active controls, progress, focus)
  static const Color vermilion = Color(0xFFE53935);
  static const Color vermilionBright = Color(0xFFFF453A);
  static const Color vermilionGlow = Color(0x66E53935);
  static const Color vermilionSubtle = Color(0x1AE53935);

  // Aged Ivory & Text (WCAG AA Compliant)
  static const Color textIvory = Color(0xFFF7F4EB);
  static const Color textIvoryMuted = Color(0xFFD6D1C4);
  static const Color textSilver = Color(0xFF9DA2AC);
  // WCAG AA compliant (>4.6:1 contrast against 0xFF090A0C)
  static const Color textDim = Color(0xFF787E8C);

  // Glass Surface Constants
  static const Color glassSurface = Color(0x26161920);
  static const Color glassSurfaceLight = Color(0x33252B38);
  static const Color glassSurfaceHover = Color(0x40303847);
  static const Color glassBorder = Color(0x24FFFFFF);
  static const Color glassBorderSubtle = Color(0x14FFFFFF);
  static const Color glassBorderGlow = Color(0x66E53935);
  static const Color glassHighlight = Color(0x40FFFFFF);

  // Solid & Translucent Card Surfaces (avoiding redundant BackdropFilters)
  static const Color cardBackground = Color(0x14FFFFFF);
  static const Color cardBackgroundSubtle = Color(0x0AFFFFFF);
  static const Color cardBorder = Color(0x1AFFFFFF);

  // Ambient Overlays
  static const Color overlayDark = Color(0xB3090A0C);
  static const Color overlaySheet = Color(0xCC0C0E12);
  static const Color scrim = Color(0xDE050608);

  // Semantic States
  static const Color activeGreen = Color(0xFF34C759);
  static const Color errorRed = Color(0xFFFF453A);
  static const Color warningAmber = Color(0xFFFF9F0A);
  static const Color infoBlue = Color(0xFF0A84FF);
}
