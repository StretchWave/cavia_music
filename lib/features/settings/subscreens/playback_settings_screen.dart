import 'package:flutter/material.dart';
import '../../../app/theme/cavia_colors.dart';
import '../../../app/theme/cavia_typography.dart';
import '../../../app/theme/cavia_glass.dart';
import '../../../core/components/cavia_glass_surface.dart';
import '../../../core/components/cavia_page_header.dart';
import '../../../core/components/cavia_section_header.dart';
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
          backgroundColor: CaviaColors.background,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              children: [
                const CaviaPageHeader(
                  title: 'Playback',
                  subtitle: 'STREAMING QUALITY & AUDIO BEHAVIOR',
                  showBackButton: true,
                  padding: EdgeInsets.only(bottom: 16),
                ),

                // 1. Audio Quality
                const CaviaSectionHeader(title: 'Audio Quality'),
                CaviaGlassSurface(
                  radius: CaviaGlass.radiusCard,
                  blur: CaviaGlass.blurStandard,
                  surfaceColor: CaviaColors.surfaceCard,
                  borderColor: CaviaColors.glassBorderSubtle,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: [
                      'Lossless (24-bit / 96kHz FLAC)',
                      'High (320 kbps AAC / Opus)',
                      'Standard (160 kbps)',
                    ].map((quality) {
                      final isSelected = settings.audioQuality == quality;
                      return ListTile(
                        leading: Icon(
                          isSelected
                              ? Icons.radio_button_checked_rounded
                              : Icons.radio_button_off_rounded,
                          color: isSelected
                              ? CaviaColors.vermilionBright
                              : CaviaColors.textSilver,
                          size: 20,
                        ),
                        title: Text(
                          quality,
                          style: CaviaTypography.body.copyWith(
                            color: isSelected
                                ? CaviaColors.textIvory
                                : CaviaColors.textSilver,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        trailing: isSelected
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: CaviaColors.vermilion
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'ACTIVE',
                                  style: CaviaTypography.caption.copyWith(
                                    color: CaviaColors.vermilionBright,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            : null,
                        onTap: () => settings.setAudioQuality(quality),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Playback Speed
                const CaviaSectionHeader(title: 'Playback Speed'),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tempo', style: CaviaTypography.body),
                          Text(
                            '${settings.playbackSpeed.toStringAsFixed(2)}×',
                            style: CaviaTypography.body.copyWith(
                              color: CaviaColors.vermilionBright,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: CaviaColors.vermilionBright,
                          inactiveTrackColor: CaviaColors.glassSurface,
                          thumbColor: CaviaColors.textIvory,
                          overlayColor:
                              CaviaColors.vermilion.withValues(alpha: 0.15),
                          trackHeight: 3,
                        ),
                        child: Slider(
                          value: settings.playbackSpeed.clamp(0.25, 4.0),
                          min: 0.25,
                          max: 4.0,
                          divisions: 75,
                          onChanged: (v) => settings.setPlaybackSpeed(v),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [0.75, 1.0, 1.25, 1.5, 2.0].map((s) {
                          final selected =
                              (settings.playbackSpeed - s).abs() < 0.001;
                          return ActionChip(
                            label: Text(
                              '${s.toStringAsFixed(2)}×',
                              style: CaviaTypography.caption.copyWith(
                                color: selected
                                    ? CaviaColors.vermilionBright
                                    : CaviaColors.textSilver,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                            backgroundColor: selected
                                ? CaviaColors.vermilion.withValues(alpha: 0.15)
                                : CaviaColors.glassSurface,
                            side: BorderSide(
                              color: selected
                                  ? CaviaColors.vermilionBright
                                  : CaviaColors.glassBorderSubtle,
                            ),
                            onPressed: () => settings.setPlaybackSpeed(s),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. Audio Engine
                const CaviaSectionHeader(title: 'Audio Engine & Transitions'),
                CaviaGlassSurface(
                  radius: CaviaGlass.radiusCard,
                  blur: CaviaGlass.blurStandard,
                  surfaceColor: CaviaColors.surfaceCard,
                  borderColor: CaviaColors.glassBorderSubtle,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Gapless Playback',
                            style: CaviaTypography.body),
                        subtitle: const Text(
                          'Zero-latency transition between consecutive album tracks',
                          style: CaviaTypography.caption,
                        ),
                        value: settings.gaplessPlayback,
                        activeThumbColor: CaviaColors.vermilionBright,
                        activeTrackColor:
                            CaviaColors.vermilion.withValues(alpha: 0.4),
                        inactiveThumbColor: CaviaColors.textSilver,
                        inactiveTrackColor: CaviaColors.glassSurface,
                        onChanged: settings.toggleGapless,
                      ),
                      const Divider(
                          color: CaviaColors.glassBorderSubtle, height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Crossfade Transitions',
                            style: CaviaTypography.body),
                        subtitle: const Text(
                          'Multi-track mixing engine is planned for an upcoming release',
                          style: CaviaTypography.caption,
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: CaviaColors.glassSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: CaviaColors.glassBorderSubtle),
                          ),
                          child: Text(
                            'PLANNED',
                            style: CaviaTypography.caption.copyWith(
                              color: CaviaColors.textSilver,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const Divider(
                          color: CaviaColors.glassBorderSubtle, height: 1),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Volume Normalization',
                            style: CaviaTypography.body),
                        subtitle: const Text(
                          'ReplayGain dynamic target loudness processing',
                          style: CaviaTypography.caption,
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: CaviaColors.glassSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: CaviaColors.glassBorderSubtle),
                          ),
                          child: Text(
                            'PLANNED',
                            style: CaviaTypography.caption.copyWith(
                              color: CaviaColors.textSilver,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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
