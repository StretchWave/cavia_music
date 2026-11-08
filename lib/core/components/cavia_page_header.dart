import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';

/// Standardized page header across Cavia Music screens.
/// Replaces repetitive double Kanji+English headings with a crisp editorial banner
/// where Japanese characters serve as subtle artistic accents.
class CaviaPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? kanji;
  final String? sectionLabel;
  final Widget? trailing;
  final bool showBackButton;
  final VoidCallback? onBack;
  final EdgeInsetsGeometry padding;

  const CaviaPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.kanji,
    this.sectionLabel,
    this.trailing,
    this.showBackButton = false,
    this.onBack,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 12),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (showBackButton) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  color: CaviaColors.textIvory,
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  onPressed: onBack ?? () => Navigator.maybePop(context),
                  tooltip: 'Back',
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: CaviaTypography.wordmark,
                    children: [
                      TextSpan(text: 'CAVIA '),
                      TextSpan(
                        text: '/',
                        style: TextStyle(color: CaviaColors.vermilionBright),
                      ),
                    ],
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: CaviaTypography.displayMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (kanji != null) ...[
                const SizedBox(width: 10),
                Text(
                  kanji!,
                  style: CaviaTypography.kanjiHeader.copyWith(
                    fontSize: 20,
                    color: CaviaColors.textSilver.withValues(alpha: 0.35),
                  ),
                ),
              ],
            ],
          ),
          if (sectionLabel != null) ...[
            const SizedBox(height: 2),
            Text(
              sectionLabel!,
              style: CaviaTypography.sectionLabel,
            ),
          ] else if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              style: CaviaTypography.artistSubtitle,
            ),
          ],
        ],
      ),
    );
  }
}
