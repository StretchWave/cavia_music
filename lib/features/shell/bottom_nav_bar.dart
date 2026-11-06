import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_glass.dart';
import '../../app/motion/cavia_motion.dart';
import '../../core/components/glass_container.dart';
import 'nav_state.dart';

class CaviaBottomNavBar extends StatelessWidget {
  final NavController navController;

  const CaviaBottomNavBar({super.key, required this.navController});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: navController,
      builder: (context, _) {
        final current = navController.currentIndex;

        return GlassContainer(
          radius: CaviaGlass.radiusPill,
          blur: CaviaGlass.blurHeavy,
          surfaceColor: CaviaColors.overlaySheet,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavTabItem(
                icon: Icons.window_rounded,
                label: 'Library',
                isSelected: current == 0,
                onTap: navController.goToLibrary,
              ),
              _NavTabItem(
                icon: Icons.search_rounded,
                label: 'Search',
                isSelected: current == 1,
                onTap: navController.goToSearch,
              ),
              _NavTabItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                isSelected: current == 2,
                onTap: navController.goToSettings,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavTabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavTabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: CaviaMotion.durationFast,
        curve: CaviaMotion.curveFluid,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? CaviaColors.vermilionBright
                  : CaviaColors.textSilver,
            ),
            const SizedBox(height: 4),
            // Glowing vermilion underline dot/pill indicator
            AnimatedContainer(
              duration: CaviaMotion.durationFast,
              width: isSelected ? 16 : 0,
              height: 2.5,
              decoration: BoxDecoration(
                color: isSelected
                    ? CaviaColors.vermilionBright
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: CaviaColors.vermilion.withValues(alpha: 0.8),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

