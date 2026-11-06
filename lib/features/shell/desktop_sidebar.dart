import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';
import '../../app/theme/cavia_glass.dart';
import '../../core/components/glass_container.dart';
import 'nav_state.dart';

class DesktopSidebar extends StatelessWidget {
  final NavController navController;

  const DesktopSidebar({super.key, required this.navController});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: navController,
      builder: (context, _) {
        final current = navController.currentIndex;

        return GlassContainer(
          width: 220,
          radius: 0,
          blur: CaviaGlass.blurHeavy,
          surfaceColor: CaviaColors.overlaySheet,
          borderColor: CaviaColors.glassBorderSubtle,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wordmark
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 28),
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

              // Navigation Items
              _SidebarItem(
                icon: Icons.window_rounded,
                label: 'Library',
                isSelected: current == 0,
                onTap: navController.goToLibrary,
              ),
              const SizedBox(height: 6),
              _SidebarItem(
                icon: Icons.search_rounded,
                label: 'Search',
                isSelected: current == 1,
                onTap: navController.goToSearch,
              ),
              const SizedBox(height: 6),
              _SidebarItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                isSelected: current == 2,
                onTap: navController.goToSettings,
              ),

              const Spacer(),

              // Quick Info
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Cavia Music v1.0\nJapanese Ink Edition',
                  style: CaviaTypography.caption.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? CaviaColors.vermilion.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: CaviaColors.vermilionBright.withValues(alpha: 0.4),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? CaviaColors.vermilionBright
                    : CaviaColors.textSilver,
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: CaviaTypography.body.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? CaviaColors.textIvory
                      : CaviaColors.textSilver,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

