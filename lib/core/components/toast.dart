import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import 'glass_container.dart';

class CaviaToast {
  static void show(BuildContext context, String message, {IconData? icon}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 90, left: 24, right: 24),
        duration: const Duration(seconds: 2),
        content: Center(
          child: GlassContainer(
            radius: CaviaGlass.radiusPill,
            blur: CaviaGlass.blurStandard,
            surfaceColor: CaviaColors.overlaySheet,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon ?? Icons.check_circle_rounded,
                  color: CaviaColors.vermilionBright,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    message,
                    style: CaviaTypography.caption.copyWith(
                      color: CaviaColors.textIvory,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

