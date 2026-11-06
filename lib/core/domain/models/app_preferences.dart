/// Domain model for persistent application configuration and preferences.
class AppPreferences {
  final String profileId;
  final bool offlineCaching;
  final double cacheLimitBytes;
  final String audioQuality;
  final bool crossfade;
  final bool gaplessPlayback;
  final bool normalizeVolume;
  final int accentColorValue;
  final bool artworkAtmosphere;
  final String animationIntensity;
  final bool cloudSync;
  final String lastSyncTime;
  final double currentCacheSizeBytes;

  const AppPreferences({
    this.profileId = 'guest',
    this.offlineCaching = true,
    this.cacheLimitBytes = 2.0 * 1024 * 1024 * 1024, // 2 GB limit default
    this.audioQuality = 'Lossless (24-bit / 96kHz FLAC)',
    this.crossfade = true,
    this.gaplessPlayback = true,
    this.normalizeVolume = false,
    this.accentColorValue = 0xFFE53935, // CaviaColors.vermilion
    this.artworkAtmosphere = true,
    this.animationIntensity = 'Smooth',
    this.cloudSync = false,
    this.lastSyncTime = 'Never',
    this.currentCacheSizeBytes = 1.2 * 1024 * 1024 * 1024, // 1.2 GB seed
  });

  String get cacheSizeFormatted {
    if (currentCacheSizeBytes <= 0) return '0 MB';
    final mb = currentCacheSizeBytes / (1024 * 1024);
    if (mb >= 1024) {
      return '${(mb / 1024).toStringAsFixed(1)} GB';
    }
    return '${mb.toStringAsFixed(0)} MB';
  }

  AppPreferences copyWith({
    String? profileId,
    bool? offlineCaching,
    double? cacheLimitBytes,
    String? audioQuality,
    bool? crossfade,
    bool? gaplessPlayback,
    bool? normalizeVolume,
    int? accentColorValue,
    bool? artworkAtmosphere,
    String? animationIntensity,
    bool? cloudSync,
    String? lastSyncTime,
    double? currentCacheSizeBytes,
  }) {
    return AppPreferences(
      profileId: profileId ?? this.profileId,
      offlineCaching: offlineCaching ?? this.offlineCaching,
      cacheLimitBytes: cacheLimitBytes ?? this.cacheLimitBytes,
      audioQuality: audioQuality ?? this.audioQuality,
      crossfade: crossfade ?? this.crossfade,
      gaplessPlayback: gaplessPlayback ?? this.gaplessPlayback,
      normalizeVolume: normalizeVolume ?? this.normalizeVolume,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      artworkAtmosphere: artworkAtmosphere ?? this.artworkAtmosphere,
      animationIntensity: animationIntensity ?? this.animationIntensity,
      cloudSync: cloudSync ?? this.cloudSync,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      currentCacheSizeBytes: currentCacheSizeBytes ?? this.currentCacheSizeBytes,
    );
  }
}

