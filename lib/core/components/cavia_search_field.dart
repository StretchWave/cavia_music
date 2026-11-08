import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_glass.dart';
import '../../app/theme/cavia_typography.dart';

/// Clean, focused search input field for Cavia Music.
class CaviaSearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final FocusNode? focusNode;
  final String hintText;
  final bool autofocus;

  const CaviaSearchField({
    super.key,
    required this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.focusNode,
    this.hintText = 'Search tracks, artists, albums...',
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: CaviaColors.glassSurface,
        borderRadius: BorderRadius.circular(CaviaGlass.radiusPill),
        border: Border.all(
          color: CaviaColors.glassBorder,
          width: 1.0,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: CaviaColors.textSilver,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: autofocus,
              style: CaviaTypography.titleSmall.copyWith(
                color: CaviaColors.textIvory,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: CaviaColors.vermilionBright,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: CaviaTypography.bodyMedium.copyWith(
                  color: CaviaColors.textDim,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: onChanged,
              onSubmitted: onSubmitted,
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  color: CaviaColors.textSilver,
                  size: 18,
                ),
                tooltip: 'Clear search',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: () {
                  controller.clear();
                  if (onClear != null) onClear!();
                  if (onChanged != null) onChanged!('');
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

