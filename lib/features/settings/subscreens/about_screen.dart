import 'package:flutter/material.dart';
import '../../../app/theme/cavia_colors.dart';
import '../../../app/theme/cavia_typography.dart';
import '../../../app/theme/cavia_glass.dart';
import '../../../core/components/cavia_glass_surface.dart';
import '../../../core/components/cavia_page_header.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CaviaColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
          children: [
            const CaviaPageHeader(
              title: 'About Cavia Music',
              subtitle: 'MINIMALIST DIGITAL AUDIO INSTRUMENT',
              showBackButton: true,
              padding: EdgeInsets.only(bottom: 24),
            ),

            // Logo & Wordmark
            Center(
              child: Column(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CaviaColors.surfaceCard,
                      border: Border.all(
                        color: CaviaColors.vermilionBright,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CaviaColors.vermilion.withValues(alpha: 0.25),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.graphic_eq_rounded,
                        color: CaviaColors.vermilionBright,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 20,
                        letterSpacing: 6,
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
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0 • Japanese Editorial Edition',
                    style: CaviaTypography.caption.copyWith(
                      color: CaviaColors.textSilver,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            CaviaGlassSurface(
              radius: CaviaGlass.radiusCard,
              blur: CaviaGlass.blurStandard,
              surfaceColor: CaviaColors.surfaceCard,
              borderColor: CaviaColors.glassBorderSubtle,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A provider-agnostic digital music instrument engineered with Flutter. '
                    'Featuring Japanese editorial typography, restrained liquid glass surfaces, '
                    'and an instant offline-first local playback architecture.',
                    style: CaviaTypography.body.copyWith(height: 1.5),
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
    );
  }
}
