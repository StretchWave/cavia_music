import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_glass.dart';
import '../../app/theme/cavia_typography.dart';

/// Standardized empty state presentation across all collections and screens.
class CaviaEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? customAction;
  final EdgeInsetsGeometry padding;

  const CaviaEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.customAction,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: CaviaColors.glassSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: CaviaColors.glassBorderSubtle,
                  width: 1.0,
                ),
              ),
              child: Icon(
                icon,
                color: CaviaColors.textSilver,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: CaviaTypography.titleMedium.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: CaviaTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (customAction != null) ...[
              const SizedBox(height: 20),
              customAction!,
            ] else if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CaviaColors.vermilion,
                  foregroundColor: CaviaColors.textIvory,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(CaviaGlass.radiusPill),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: CaviaTypography.labelMedium.copyWith(color: CaviaColors.textIvory),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Standardized loading indicator with branded styling.
class CaviaLoadingState extends StatelessWidget {
  final String? message;
  final EdgeInsetsGeometry padding;

  const CaviaLoadingState({
    super.key,
    this.message,
    this.padding = const EdgeInsets.all(40),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: CaviaColors.vermilionBright,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 14),
              Text(
                message!,
                style: CaviaTypography.caption.copyWith(color: CaviaColors.textSilver),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Standardized error feedback with human-readable messaging and retry button.
class CaviaErrorState extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final EdgeInsetsGeometry padding;

  const CaviaErrorState({
    super.key,
    this.title = 'Unable to Load',
    this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.padding = const EdgeInsets.all(32),
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: CaviaColors.vermilion.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: CaviaColors.vermilionBright.withValues(alpha: 0.4),
                  width: 1.0,
                ),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: CaviaColors.vermilionBright,
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: CaviaTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                style: CaviaTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(retryLabel),
                style: OutlinedButton.styleFrom(
                  foregroundColor: CaviaColors.textIvory,
                  side: const BorderSide(color: CaviaColors.glassBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(CaviaGlass.radiusPill),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

