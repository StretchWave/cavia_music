import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_glass.dart';
import '../../app/theme/cavia_typography.dart';
import 'cavia_glass_surface.dart';

/// Standardized modal bottom sheet with drag handle, title, and actions.
class CaviaBottomSheet {
  CaviaBottomSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    Widget? trailing,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    double initialChildSize = 0.6,
    double minChildSize = 0.3,
    double maxChildSize = 0.95,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: CaviaColors.scrim,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: (ctx) {
        return CaviaGlassSurface(
          radius: CaviaGlass.radiusLarge,
          blur: CaviaGlass.blurHeavy,
          surfaceColor: CaviaColors.overlaySheet,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(top: 10, bottom: 8),
                    decoration: BoxDecoration(
                      color: CaviaColors.glassHighlight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Optional Header
                if (title != null) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: CaviaTypography.titleMedium.copyWith(fontSize: 16),
                        ),
                        if (trailing != null)
                          trailing
                        else
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            color: CaviaColors.textSilver,
                            onPressed: () => Navigator.pop(ctx),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          ),
                      ],
                    ),
                  ),
                  const Divider(color: CaviaColors.cardBorder, height: 1),
                ],

                Flexible(child: child),
              ],
            ),
          ),
        );
      },
    );
  }
}

