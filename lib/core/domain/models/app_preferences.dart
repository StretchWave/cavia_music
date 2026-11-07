/// Domain model for persistent application configuration and preferences.
///
/// Every value here represents a real user setting with a runtime effect;
/// there are no fabricated usage/statistics values in this model.
class AppPreferences {
  final String profileId;
  final bool offlineCaching;

  /// User-configured offline cache quota in bytes (independent of the current
  /// occupied size, which is always measured from the filesystem).
  final double cacheQuotaBytes;
  final String audioQuality;
  final bool crossfade;
  final bool gaplessPlayback;
  final bool normalizeVolume;
  final double playbackSpeed;
  final int accentColorValue;
  final bool artworkAtmosphere;
  final String animationIntensity;
  final bool cloudSync;

  const AppPreferences({
    this.profileId = 'guest',
    this.offlineCaching = true,
    this.cacheQuotaBytes = 1288490188.0, // 1.2 GiB default quota
    this.audioQuality = 'Lossless (24-bit / 96 kHz FLAC)',
    this.crossfade = true,
    this.gaplessPlayback = true,
    this.normalizeVolume = false,
    this.playbackSpeed = 1.0,
    this.accentColorValue = 0xFFE53935, // CaviaColors.vermilion
    this.artworkAtmosphere = true,
    this.animationIntensity = 'Smooth',
    this.cloudSync = false,
  });

  AppPreferences copyWith({
    String? profileId,
    bool? offlineCaching,
    double? cacheQuotaBytes,
    String? audioQuality,
    bool? crossfade,
    bool? gaplessPlayback,
    bool? normalizeVolume,
    double? playbackSpeed,
    int? accentColorValue,
    bool? artworkAtmosphere,
    String? animationIntensity,
    bool? cloudSync,
  }) {
    return AppPreferences(
      profileId: profileId ?? this.profileId,
      offlineCaching: offlineCaching ?? this.offlineCaching,
      cacheQuotaBytes: cacheQuotaBytes ?? this.cacheQuotaBytes,
      audioQuality: audioQuality ?? this.audioQuality,
      crossfade: crossfade ?? this.crossfade,
      gaplessPlayback: gaplessPlayback ?? this.gaplessPlayback,
      normalizeVolume: normalizeVolume ?? this.normalizeVolume,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      artworkAtmosphere: artworkAtmosphere ?? this.artworkAtmosphere,
      animationIntensity: animationIntensity ?? this.animationIntensity,
      cloudSync: cloudSync ?? this.cloudSync,
    );
  }

  /// Serializes the whole model for local key/value persistence.
  Map<String, String> toMap() => {
        'profileId': profileId,
        'offlineCaching': offlineCaching.toString(),
        'cacheQuotaBytes': cacheQuotaBytes.toString(),
        'audioQuality': audioQuality,
        'crossfade': crossfade.toString(),
        'gaplessPlayback': gaplessPlayback.toString(),
        'normalizeVolume': normalizeVolume.toString(),
        'playbackSpeed': playbackSpeed.toString(),
        'accentColorValue': accentColorValue.toString(),
        'artworkAtmosphere': artworkAtmosphere.toString(),
        'animationIntensity': animationIntensity,
        'cloudSync': cloudSync.toString(),
      };

  static AppPreferences fromMap(Map<String, String> map) {
    double? parseDouble(String? raw) => raw == null ? null : double.tryParse(raw);
    int? parseInt(String? raw) => raw == null ? null : int.tryParse(raw);
    bool? parseBool(String? raw) =>
        raw == null ? null : (raw == 'true' || raw == '1');
    return AppPreferences(
      profileId: map['profileId'] ?? 'guest',
      offlineCaching: parseBool(map['offlineCaching']) ?? true,
      cacheQuotaBytes: parseDouble(map['cacheQuotaBytes']) ?? 1288490188.0,
      audioQuality: map['audioQuality'] ?? 'Lossless (24-bit / 96 kHz FLAC)',
      crossfade: parseBool(map['crossfade']) ?? true,
      gaplessPlayback: parseBool(map['gaplessPlayback']) ?? true,
      normalizeVolume: parseBool(map['normalizeVolume']) ?? false,
      playbackSpeed: parseDouble(map['playbackSpeed']) ?? 1.0,
      accentColorValue: parseInt(map['accentColorValue']) ?? 0xFFE53935,
      artworkAtmosphere: parseBool(map['artworkAtmosphere']) ?? true,
      animationIntensity: map['animationIntensity'] ?? 'Smooth',
      cloudSync: parseBool(map['cloudSync']) ?? false,
    );
  }
}
