import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_glass.dart';

/// Single source of truth for frosted liquid glass surfaces in Cavia Music.
/// Combines controlled blur, specular sheen, and optional vermilion glow.
class CaviaGlassSurface extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double blur;
  final bool glow;
  final bool enableBlur;
  final Color? surfaceColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final Clip clipBehavior;

  const CaviaGlassSurface({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.radius = CaviaGlass.radiusMedium,
    this.blur = CaviaGlass.blurStandard,
    this.glow = false,
    this.enableBlur = true,
    this.surfaceColor,
    this.borderColor,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSurface = surfaceColor ??
        (glow
            ? CaviaColors.vermilion.withValues(alpha: 0.12)
            : CaviaColors.glassSurface);

    final effectiveBorder = borderColor ??
        (glow
            ? CaviaColors.vermilionBright.withValues(alpha: 0.8)
            : CaviaColors.glassBorder);

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveSurface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: effectiveBorder,
          width: glow ? 1.4 : 1.0,
        ),
        boxShadow: [
          if (glow) ...[
            BoxShadow(
              color: CaviaColors.vermilion.withValues(alpha: 0.35),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: CaviaColors.vermilionBright.withValues(alpha: 0.15),
              blurRadius: 40,
              spreadRadius: 2,
            ),
          ],
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );

    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          splashColor: CaviaColors.vermilion.withValues(alpha: 0.15),
          highlightColor: CaviaColors.glassSurfaceHover,
          child: content,
        ),
      );
    }

    Widget result;
    if (enableBlur && blur > 0) {
      result = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      );
    } else {
      result = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: clipBehavior,
        child: content,
      );
    }

    if (margin != null) {
      return Padding(
        padding: margin!,
        child: result,
      );
    }

    return result;
  }
}
