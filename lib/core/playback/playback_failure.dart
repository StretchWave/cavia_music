/// Typed classifications for playback errors across all providers and audio engines.
enum PlaybackFailureType {
  networkUnavailable,
  requestTimeout,
  sourceUnavailable,
  trackUnavailable,
  authenticationExpired,
  regionRestricted,
  rateLimited,
  playbackUnsupported,
  invalidMedia,
  permissionDenied,
  notCachedForOffline,
  unknownPlaybackFailure,
}

/// A structured, typed playback failure with exact user-facing UI messages.
class PlaybackFailure {
  final PlaybackFailureType type;
  final String internalMessage;
  final String? providerId;
  final String? trackId;
  final Object? originalError;
  final StackTrace? stackTrace;
  final String? overrideUserMessage;

  const PlaybackFailure({
    required this.type,
    required this.internalMessage,
    this.providerId,
    this.trackId,
    this.originalError,
    this.stackTrace,
    this.overrideUserMessage,
  });

  /// The exact user-facing message required by Cavia Music specification.
  /// Raw provider stack traces are NEVER exposed to users.
  String get userMessage {
    if (overrideUserMessage != null && overrideUserMessage!.isNotEmpty) {
      return overrideUserMessage!;
    }
    switch (type) {
      case PlaybackFailureType.networkUnavailable:
        return 'Connection lost.';
      case PlaybackFailureType.notCachedForOffline:
        return "This track isn't cached for offline playback.";
      case PlaybackFailureType.trackUnavailable:
        return "This track isn't available.";
      case PlaybackFailureType.playbackUnsupported:
      case PlaybackFailureType.permissionDenied:
        return "Playback isn't supported for this source.";
      case PlaybackFailureType.authenticationExpired:
        return 'Reconnect this music source to continue.';
      case PlaybackFailureType.regionRestricted:
        return "This track isn't available in your region.";
      case PlaybackFailureType.sourceUnavailable:
        return 'No playable source was found.';
      case PlaybackFailureType.requestTimeout:
      case PlaybackFailureType.rateLimited:
      case PlaybackFailureType.invalidMedia:
      case PlaybackFailureType.unknownPlaybackFailure:
        return "Couldn't start playback. Try again.";
    }
  }

  @override
  String toString() => 'PlaybackFailure($type: $internalMessage, trackId: $trackId)';
}
