/// Explicit playback states for Cavia Music's audio engine and coordinator.
enum PlaybackMachineState {
  /// No track is loaded, queue is empty or has been stopped.
  idle,

  /// Querying provider, resolving metadata, or verifying stream rights.
  resolving,

  /// Preparing audio engine with the resolved media source.
  loading,

  /// Audio engine is actively buffering network packets.
  buffering,

  /// Audio engine is actively outputting sound to audio hardware.
  playing,

  /// Playback has been paused by the user or an external trigger.
  paused,

  /// Current track reached its end duration.
  completed,

  /// Audio focus was lost (incoming phone call, other media player, headphones unplugged).
  interrupted,

  /// Bounded exponential backoff retry in progress for a transient error.
  retrying,

  /// Terminal failure for the current track source.
  failed,

  /// Track or stream is unavailable (e.g. deleted or region restricted).
  unavailable,

  /// Source requires user re-authentication or expired token refresh.
  authenticationRequired,
}

/// Reasons for state transitions within the playback state machine.
enum PlaybackTransitionReason {
  userPlay,
  userPause,
  userResume,
  userSeek,
  userSkipNext,
  userSkipPrevious,
  trackSelected,
  trackCompleted,
  bufferStarved,
  bufferReady,
  audioFocusLoss,
  audioFocusGained,
  becomingNoisy, // Headphone unplugged
  sourceError,
  retryAttempt,
  authExpired,
  stopRequested,
}

