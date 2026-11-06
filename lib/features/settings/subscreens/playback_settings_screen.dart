import 'package:flutter/material.dart';
import '../../../app/theme/cavia_colors.dart';
import '../../../app/theme/cavia_typography.dart';
import '../../../app/theme/cavia_glass.dart';
import '../../../core/components/glass_container.dart';
import '../../../core/components/japanese_scenery_background.dart';
import '../../../core/state/app_state_scope.dart';

class PlaybackSettingsScreen extends StatelessWidget {
  const PlaybackSettingsScreen({super.key});

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
                          'Playback Settings',
                          style: CaviaTypography.display.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Audio Quality Selector
                    Text('AUDIO QUALITY', style: CaviaTypography.sectionLabel),
                    const SizedBox(height: 8),
                    GlassContainer(
                      radius: CaviaGlass.radiusCard,
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          'Lossless (24-bit / 96kHz FLAC)',
                          'High (320 kbps AAC / Opus)',
                          'Standard (160 kbps)',
                        ].map((quality) {
                          final isSelected = settings.audioQuality == quality;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            leading: Icon(
                              isSelected
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: isSelected
                                  ? CaviaColors.vermilionBright
                                  : CaviaColors.textSilver,
                            ),
                            title: Text(
                              quality,
                              style: CaviaTypography.body.copyWith(
                                color: isSelected
                                    ? CaviaColors.textIvory
                                    : CaviaColors.textSilver,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            onTap: () => settings.setAudioQuality(quality),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Playback Toggles
                    Text('AUDIO ENGINE', style: CaviaTypography.sectionLabel),
                    const SizedBox(height: 8),
                    GlassContainer(
                      radius: CaviaGlass.radiusCard,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        children: [
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Crossfade Transitions', style: CaviaTypography.body),
                            subtitle: const Text('Seamless blending between tracks', style: CaviaTypography.caption),
                            value: settings.crossfade,
                            activeThumbColor: CaviaColors.vermilionBright,
                            onChanged: settings.toggleCrossfade,
                          ),
                          const Divider(color: CaviaColors.glassBorderSubtle, height: 1),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Gapless Playback', style: CaviaTypography.body),
                            subtitle: const Text('Zero latency transition for continuous albums', style: CaviaTypography.caption),
                            value: settings.gaplessPlayback,
                            activeThumbColor: CaviaColors.vermilionBright,
                            onChanged: settings.toggleGapless,
                          ),
                          const Divider(color: CaviaColors.glassBorderSubtle, height: 1),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Normalize Volume', style: CaviaTypography.body),
                            subtitle: const Text('Apply consistent audio loudness across tracks', style: CaviaTypography.caption),
                            value: settings.normalizeVolume,
                            activeThumbColor: CaviaColors.vermilionBright,
                            onChanged: settings.toggleNormalizeVolume,
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
