import 'package:flutter/material.dart';
import '../../../app/theme/cavia_colors.dart';
import '../../../app/theme/cavia_typography.dart';
import '../../../app/theme/cavia_glass.dart';
import '../../../core/components/glass_container.dart';
import '../../../core/components/japanese_scenery_background.dart';
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
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              const JapaneseSceneryBackground(opacity: 0.35),
              SafeArea(
                child: Column(
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
                          'Source Providers',
                          style: CaviaTypography.display.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        providers.isEmpty
                            ? 'No providers are registered in this build.'
                            : 'Status observed from the running audio engine.',
                        style: CaviaTypography.caption
                            .copyWith(color: CaviaColors.textSilver),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: providers.isEmpty
                          ? Center(
                              child: Text(
                                'Nothing to show',
                                style: CaviaTypography.body,
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: providers.length,
                              itemBuilder: (context, index) {
                                final provider = providers[index];
                                return _ProviderTile(provider: provider);
                              },
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

    return GlassContainer(
      radius: CaviaGlass.radiusCard,
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
                      ? CaviaColors.vermilionBright.withValues(alpha: 0.15)
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
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'id: ${provider.id}',
            style: CaviaTypography.caption.copyWith(
              color: CaviaColors.textDim,
            ),
          ),
          const SizedBox(height: 10),
          if (features.isEmpty)
            Text(
              'No capabilities declared',
              style: CaviaTypography.caption.copyWith(
                color: CaviaColors.textDim,
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: features
                  .map((f) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: CaviaColors.glassSurface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          f,
                          style: CaviaTypography.caption.copyWith(fontSize: 10),
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}
