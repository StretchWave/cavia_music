import 'package:flutter/material.dart';
import '../../../app/theme/cavia_colors.dart';
import '../../../app/theme/cavia_typography.dart';
import '../../../app/theme/cavia_glass.dart';
import '../../../core/components/cavia_glass_surface.dart';
import '../../../core/components/cavia_page_header.dart';
import '../../../core/components/cavia_section_header.dart';
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
          backgroundColor: CaviaColors.background,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              children: [
                const CaviaPageHeader(
                  title: 'Appearance',
                  subtitle: 'VISUAL ATMOSPHERE & DESIGN SYSTEM',
                  showBackButton: true,
                  padding: EdgeInsets.only(bottom: 16),
                ),

                // 1. Design Language
                const CaviaSectionHeader(title: 'Theme & Identity'),
                CaviaGlassSurface(
                  radius: CaviaGlass.radiusCard,
                  blur: CaviaGlass.blurStandard,
                  surfaceColor: CaviaColors.surfaceCard,
                  borderColor: CaviaColors.glassBorderSubtle,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: CaviaColors.vermilionBright,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Japanese Editorial × Restrained Liquid Glass',
                            style: CaviaTypography.songTitle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'A deliberate palette of near-black charcoal, aged ivory, and vermilion red accents, paired with hardware-accelerated frosted glass surfaces.',
                        style: CaviaTypography.caption.copyWith(
                          color: CaviaColors.textSilver,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Atmospheric Effects
                const CaviaSectionHeader(title: 'Atmospheric Effects'),
                CaviaGlassSurface(
                  radius: CaviaGlass.radiusCard,
                  blur: CaviaGlass.blurStandard,
                  surfaceColor: CaviaColors.surfaceCard,
                  borderColor: CaviaColors.glassBorderSubtle,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Japanese Ink Backdrops',
                        style: CaviaTypography.body),
                    subtitle: const Text(
                      'Display atmospheric scenery in Library header and player hero areas',
                      style: CaviaTypography.caption,
                    ),
                    value: settings.artworkAtmosphere,
                    activeThumbColor: CaviaColors.vermilionBright,
                    activeTrackColor:
                        CaviaColors.vermilion.withValues(alpha: 0.4),
                    inactiveThumbColor: CaviaColors.textSilver,
                    inactiveTrackColor: CaviaColors.glassSurface,
                    onChanged: settings.toggleArtworkAtmosphere,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
