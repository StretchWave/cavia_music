import 'dart:async';
import 'playback_machine_state.dart';
import 'playback_source.dart';

/// Abstract contract for low-level audio output engines across platforms.
abstract class AudioEngine {
  /// Stream of current playback position ticks.
  Stream<Duration> get positionStream;

  /// Stream of media duration updates.
  Stream<Duration?> get durationStream;

  /// Stream of network buffering progress.
  Stream<Duration> get bufferedPositionStream;

  /// Stream of state machine transitions.
  Stream<PlaybackMachineState> get stateStream;

  /// Instantaneous engine state.
  PlaybackMachineState get currentState;

  /// Current position.
  Duration get currentPosition;

  /// Total duration.
  Duration get totalDuration;

  /// Current volume [0.0 - 1.0].
  double get volume;

  /// Initialize engine and audio session handlers.
  Future<void> init();

  /// Load a resolved playback source into the hardware audio pipeline.
  Future<void> load(PlaybackSource source);

  /// Start or resume sound output.
  Future<void> play();

  /// Pause sound output.
  Future<void> pause();

  /// Seek to [position].
  Future<void> seek(Duration position);

  /// Change volume [0.0 - 1.0].
  Future<void> setVolume(double volume);

  /// Stop audio and release pipeline buffers.
  Future<void> stop();

  /// Terminate engine and close streams.
  Future<void> dispose();
}

