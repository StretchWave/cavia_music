import 'music_provider.dart';

/// Registry holding all configured music and metadata providers.
class ProviderRegistry {
  final Map<String, MusicProvider> _providers = {};

  ProviderRegistry({List<MusicProvider>? initialProviders}) {
    if (initialProviders != null) {
      for (final p in initialProviders) {
        register(p);
      }
    }
  }

  void register(MusicProvider provider) {
    _providers[provider.id] = provider;
  }

  void unregister(String providerId) {
    _providers.remove(providerId);
  }

  MusicProvider? getProvider(String providerId) => _providers[providerId];

  List<MusicProvider> get allProviders => _providers.values.toList();

  List<MusicProvider> get operationalProviders =>
      _providers.values.where((p) => p.isOperational).toList();

  List<MusicProvider> get searchProviders => _providers.values
      .where((p) => p.isOperational && p.capabilities.searchSupport)
      .toList();

  List<MusicProvider> get playbackProviders => _providers.values
      .where((p) => p.isOperational && p.capabilities.playbackSupport)
      .toList();
}

