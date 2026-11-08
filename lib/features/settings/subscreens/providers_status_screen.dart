import 'package:flutter/material.dart';
import '../../../app/theme/cavia_colors.dart';
import '../../../app/theme/cavia_typography.dart';
import '../../../app/theme/cavia_glass.dart';
import '../../../core/components/cavia_glass_surface.dart';
import '../../../core/components/cavia_page_header.dart';
import '../../../core/components/cavia_feedback_states.dart';
import '../../../core/providers/music_provider.dart';
import '../../../core/state/app_state_scope.dart';

/// Real provider status screen: lists the providers the engine actually
/// registered with their live operational state and declared capabilities.
class ProviderStatusScreen extends StatelessWidget {
  const ProviderStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppStateScope.settingsOf(context);

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final providers = settings.registeredProviders;

        return Scaffold(
          backgroundColor: CaviaColors.background,
          body: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              children: [
                const CaviaPageHeader(
                  title: 'Source Providers',
                  subtitle: 'OBSERVED AUDIO STREAM ENGINE INTEGRATIONS',
                  showBackButton: true,
                  padding: EdgeInsets.only(bottom: 16),
                ),
                if (providers.isEmpty)
                  const CaviaEmptyState(
                    icon: Icons.layers_outlined,
                    title: 'No Providers Registered',
                    subtitle: 'No audio source providers are registered in this build.',
                  )
                else
                  ...providers.map((p) => _ProviderTile(provider: p)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProviderTile extends StatelessWidget {
  final MusicProvider provider;

  const _ProviderTile({required this.provider});

  @override
  Widget build(BuildContext context) {
    final capabilities = provider.capabilities;

    final features = <String>[
      if (capabilities.searchSupport) 'Search',
      if (capabilities.metadataSupport) 'Metadata',
      if (capabilities.playbackSupport) 'Playback',
      if (capabilities.backgroundPlaybackSupport) 'Background',
      if (capabilities.offlineAvailability) 'Offline',
      if (capabilities.cachingPermission) 'Caching OK',
      if (capabilities.authenticationRequired) 'Sign-in required',
    ];

    return CaviaGlassSurface(
      radius: CaviaGlass.radiusCard,
      blur: CaviaGlass.blurStandard,
      surfaceColor: CaviaColors.surfaceCard,
      borderColor: CaviaColors.glassBorderSubtle,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  provider.displayName,
                  style: CaviaTypography.songTitle,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: provider.isOperational
                      ? CaviaColors.vermilion.withValues(alpha: 0.15)
                      : CaviaColors.textSilver.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      provider.isOperational
                          ? Icons.check_circle_outline_rounded
                          : Icons.remove_circle_outline_rounded,
                      size: 14,
                      color: provider.isOperational
                          ? CaviaColors.vermilionBright
                          : CaviaColors.textSilver,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      provider.isOperational ? 'Operational' : 'Not operational',
                      style: CaviaTypography.caption.copyWith(
                        color: provider.isOperational
                            ? CaviaColors.vermilionBright
                            : CaviaColors.textSilver,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: features.map((feat) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: CaviaColors.glassSurface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: CaviaColors.glassBorderSubtle),
                ),
                child: Text(
                  feat,
                  style: CaviaTypography.caption.copyWith(
                    color: CaviaColors.textSilver,
                    fontSize: 11,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
