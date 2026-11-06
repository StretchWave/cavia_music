import 'package:flutter/material.dart';
import '../../../app/theme/cavia_colors.dart';
import '../../../app/theme/cavia_typography.dart';
import '../../../app/theme/cavia_glass.dart';
import '../../../core/components/glass_container.dart';
import '../../../core/components/japanese_scenery_background.dart';
import '../../../core/state/app_state_scope.dart';

class AppearanceSettingsScreen extends StatelessWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppStateScope.settingsOf(context);

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              const JapaneseSceneryBackground(opacity: 0.35),
              SafeArea(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          color: CaviaColors.textIvory,
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Appearance',
                          style: CaviaTypography.display.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Primary Accent Color Selection
                    Text('ACCENT COLOR', style: CaviaTypography.sectionLabel),
                    const SizedBox(height: 8),
                    GlassContainer(
                      radius: CaviaGlass.radiusCard,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _ColorDot(
                            color: CaviaColors.vermilion,
                            label: 'Vermilion',
                            isSelected: settings.accentColor == CaviaColors.vermilion,
                            onTap: () => settings.setAccentColor(CaviaColors.vermilion),
                          ),
                          _ColorDot(
                            color: const Color(0xFFFF9500),
                            label: 'Amber',
                            isSelected: settings.accentColor == const Color(0xFFFF9500),
                            onTap: () => settings.setAccentColor(const Color(0xFFFF9500)),
                          ),
                          _ColorDot(
                            color: const Color(0xFF34C759),
                            label: 'Bamboo',
                            isSelected: settings.accentColor == const Color(0xFF34C759),
                            onTap: () => settings.setAccentColor(const Color(0xFF34C759)),
                          ),
                          _ColorDot(
                            color: const Color(0xFFAF52DE),
                            label: 'Iris',
                            isSelected: settings.accentColor == const Color(0xFFAF52DE),
                            onTap: () => settings.setAccentColor(const Color(0xFFAF52DE)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Visual Atmosphere Options
                    Text('ATMOSPHERE & EFFECTS', style: CaviaTypography.sectionLabel),
                    const SizedBox(height: 8),
                    GlassContainer(
                      radius: CaviaGlass.radiusCard,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Japanese Ink Backdrops', style: CaviaTypography.body),
                            subtitle: const Text('Display sumi-e atmospheric scenery across pages', style: CaviaTypography.caption),
                            value: settings.artworkAtmosphere,
                            activeThumbColor: CaviaColors.vermilionBright,
                            onChanged: settings.toggleArtworkAtmosphere,
                          ),
                          const Divider(color: CaviaColors.glassBorderSubtle, height: 1),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Liquid Glass Blur', style: CaviaTypography.body),
                            subtitle: const Text('Hardware-accelerated frosted glass surfaces', style: CaviaTypography.caption),
                            trailing: Text(
                              'Enabled',
                              style: CaviaTypography.caption.copyWith(color: CaviaColors.vermilionBright),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorDot({
    required this.color,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.6),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: CaviaTypography.caption.copyWith(
              color: isSelected ? CaviaColors.textIvory : CaviaColors.textSilver,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
