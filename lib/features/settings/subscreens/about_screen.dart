import 'package:flutter/material.dart';
import '../../../app/theme/cavia_colors.dart';
import '../../../app/theme/cavia_typography.dart';
import '../../../app/theme/cavia_glass.dart';
import '../../../core/components/glass_container.dart';
import '../../../core/components/japanese_scenery_background.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const JapaneseSceneryBackground(opacity: 0.35),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
                      'About Cavia Music',
                      style: CaviaTypography.display.copyWith(fontSize: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Logo / Wordmark Presentation
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: CaviaColors.glassSurface,
                          border: Border.all(
                            color: CaviaColors.vermilionBright,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CaviaColors.vermilion.withValues(alpha: 0.3),
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.graphic_eq_rounded,
                            color: CaviaColors.vermilionBright,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 8,
                            fontWeight: FontWeight.w700,
                            color: CaviaColors.textIvory,
                          ),
                          children: [
                            TextSpan(text: 'CAVIA '),
                            TextSpan(
                              text: '/',
                              style: TextStyle(color: CaviaColors.vermilionBright),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Version 1.0.0 (Japanese Ink Edition)',
                        style: CaviaTypography.caption,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                GlassContainer(
                  radius: CaviaGlass.radiusCard,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A minimal, provider-agnostic digital music instrument engineered with Flutter. Designed with Japanese sumi-e aesthetic, frosted liquid glassmorphism, and instant offline-first local playback.',
                        style: CaviaTypography.body,
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: CaviaColors.glassBorderSubtle, height: 1),
                      const SizedBox(height: 16),
                      Text('Open-Source License', style: CaviaTypography.sectionLabel),
                      const SizedBox(height: 6),
                      Text(
                        'Distributed under the GNU General Public License v3.0.',
                        style: CaviaTypography.caption.copyWith(color: CaviaColors.textSilver),
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
  }
}

