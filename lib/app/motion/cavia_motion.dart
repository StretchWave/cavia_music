import 'package:flutter/animation.dart';

/// Centralized motion timing, curves, and duration specifications.
class CaviaMotion {
  CaviaMotion._();

  // Durations
  static const Duration durationInstant = Duration(milliseconds: 100);
  static const Duration durationButton = Duration(milliseconds: 140);
  static const Duration durationIcon = Duration(milliseconds: 180);
  static const Duration durationFast = Duration(milliseconds: 220);
  static const Duration durationStandard = Duration(milliseconds: 300);
  static const Duration durationSheet = Duration(milliseconds: 350);
  static const Duration durationPage = Duration(milliseconds: 320);
  static const Duration durationExpansion = Duration(milliseconds: 460);
  static const Duration durationArtwork = Duration(milliseconds: 400);

  // Curves
  static const Curve curveEnter = Curves.easeOutCubic;
  static const Curve curveExit = Curves.easeInCubic;
  static const Curve curveFluid = Curves.fastOutSlowIn;
  static const Curve curveSpring = Curves.easeOutBack;
  static const Curve curveDecelerate = Curves.decelerate;
}

