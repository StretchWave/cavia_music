/// Represents a resolved media playback source.
class PlaybackSource {
  final String sourceId;
  final String trackId;
  final String providerId;
  final Uri uri;
  final bool isLocal;
  final bool isAsset;
  final Map<String, String>? headers;
  final String? mimeType;
  final DateTime? expiresAt;

  /// Whether playback requires an official external player or web view (e.g. YouTube official video).
  final bool requiresOfficialPlayer;
  final Uri? officialPlayerUrl;

  const PlaybackSource({
    required this.sourceId,
    required this.trackId,
    required this.providerId,
    required this.uri,
    this.isLocal = false,
    this.isAsset = false,
    this.headers,
    this.mimeType,
    this.expiresAt,
    this.requiresOfficialPlayer = false,
    this.officialPlayerUrl,
  });

  /// Factory for bundled assets (e.g. built-in sampler tracks).
  factory PlaybackSource.asset({
    required String trackId,
    required String assetPath,
    String providerId = 'local',
  }) {
    return PlaybackSource(
      sourceId: 'asset_${trackId}_${DateTime.now().millisecondsSinceEpoch}',
      trackId: trackId,
      providerId: providerId,
      uri: Uri.parse(assetPath),
      isLocal: true,
      isAsset: true,
    );
  }

  /// Factory for local device audio files.
  factory PlaybackSource.file({
    required String trackId,
    required Uri fileUri,
    String providerId = 'local',
  }) {
    return PlaybackSource(
      sourceId: 'file_${trackId}_${DateTime.now().millisecondsSinceEpoch}',
      trackId: trackId,
      providerId: providerId,
      uri: fileUri,
      isLocal: true,
      isAsset: false,
    );
  }

  /// Factory for direct HTTPS streaming sources.
  factory PlaybackSource.stream({
    required String trackId,
    required String providerId,
    required Uri streamUri,
    Map<String, String>? headers,
    String? mimeType,
    Duration? validFor,
  }) {
    return PlaybackSource(
      sourceId: 'stream_${trackId}_${DateTime.now().millisecondsSinceEpoch}',
      trackId: trackId,
      providerId: providerId,
      uri: streamUri,
      isLocal: false,
      isAsset: false,
      headers: headers,
      mimeType: mimeType,
      expiresAt: validFor != null ? DateTime.now().add(validFor) : null,
    );
  }

  /// Factory for YouTube or official-only sources where direct audio-only playback is unsupported.
  factory PlaybackSource.officialPlayerOnly({
    required String trackId,
    required String providerId,
    required Uri officialUrl,
  }) {
    return PlaybackSource(
      sourceId: 'official_${trackId}_${DateTime.now().millisecondsSinceEpoch}',
      trackId: trackId,
      providerId: providerId,
      uri: officialUrl,
      requiresOfficialPlayer: true,
      officialPlayerUrl: officialUrl,
    );
  }

  /// Check whether this source is a remote HTTPS stream.
  bool get isStream => !isLocal && !isAsset && !requiresOfficialPlayer;

  /// Check whether this temporary stream has expired.
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}
