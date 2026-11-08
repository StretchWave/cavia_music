import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_glass.dart';
import '../../app/theme/cavia_typography.dart';
import '../providers/music_provider.dart';

/// Compact, accessible segmented category filter for search and collections.
class CaviaFilterControl extends StatelessWidget {
  final SearchFilterCategory selected;
  final ValueChanged<SearchFilterCategory> onSelected;
  final EdgeInsetsGeometry padding;

  const CaviaFilterControl({
    super.key,
    required this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  });

  String _labelFor(SearchFilterCategory cat) {
    switch (cat) {
      case SearchFilterCategory.all:
        return 'All';
      case SearchFilterCategory.songs:
        return 'Songs';
      case SearchFilterCategory.albums:
        return 'Albums';
      case SearchFilterCategory.artists:
        return 'Artists';
      case SearchFilterCategory.playlists:
        return 'Playlists';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: SearchFilterCategory.values.map((cat) {
          final isSelected = cat == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Semantics(
              button: true,
              selected: isSelected,
              label: '${_labelFor(cat)} filter',
              child: GestureDetector(
                onTap: () => onSelected(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? CaviaColors.vermilion.withValues(alpha: 0.16)
                        : CaviaColors.glassSurface,
                    borderRadius: BorderRadius.circular(CaviaGlass.radiusPill),
                    border: Border.all(
                      color: isSelected
                          ? CaviaColors.vermilionBright
                          : CaviaColors.glassBorder,
                      width: isSelected ? 1.2 : 1.0,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: CaviaColors.vermilion.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 1),
                        ),
                    ],
                  ),
                  child: Text(
                    _labelFor(cat),
                    style: CaviaTypography.labelMedium.copyWith(
                      color: isSelected
                          ? CaviaColors.vermilionBright
                          : CaviaColors.textSilver,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

