import 'package:flutter/material.dart';

/// Centralized responsive breakpoints and viewport classification for Cavia Music.
/// Targets verified against mobile (360, 390, 430), tablet (768, 1024), and desktop (1280, 1440+).
class CaviaBreakpoints {
  CaviaBreakpoints._();

  static const double mobileMax = 767.0;
  static const double tabletMin = 768.0;
  static const double tabletMax = 1023.0;
  static const double desktopMin = 1024.0;
  static const double maxContentWidth = 1280.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < tabletMin;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= tabletMin && width <= tabletMax;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopMin;

  static bool isTabletOrDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletMin;

  /// Returns responsive value based on current breakpoint.
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktopMin && desktop != null) return desktop;
    if (width >= tabletMin && tablet != null) return tablet;
    return mobile;
  }
}

/// Adaptive builder that switches layouts cleanly based on CaviaBreakpoints.
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context)? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= CaviaBreakpoints.desktopMin && desktop != null) {
          return desktop!(context);
        }
        if (constraints.maxWidth >= CaviaBreakpoints.tabletMin && tablet != null) {
          return tablet!(context);
        }
        return mobile(context);
      },
    );
  }
}

/// Constrains maximum content width on wide screens and centers content with margins.
class ResponsiveContentWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveContentWrapper({
    super.key,
    required this.child,
    this.maxWidth = CaviaBreakpoints.maxContentWidth,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

