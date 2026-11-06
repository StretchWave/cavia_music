import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'audio_engine.dart';
import 'playback_machine_state.dart';
import 'playback_source.dart';
import 'playback_failure.dart';

/// Production audio engine powered by `just_audio` and `audio_session`.
/// Manages hardware audio pipelines, focus loss, calls, and headphone unplugs.
class JustAudioEngine implements AudioEngine {
  final AudioPlayer _player;
  AudioSession? _session;
  StreamSubscription? _interruptionSub;
  StreamSubscription? _noisySub;
  StreamSubscription? _playerStateSub;

  final _stateController = StreamController<PlaybackMachineState>.broadcast();
  PlaybackMachineState _currentState = PlaybackMachineState.idle;
  PlaybackFailure? _lastError;

  JustAudioEngine({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<Duration?> get durationStream => _player.durationStream;

  @override
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

  @override
  Stream<PlaybackMachineState> get stateStream => _stateController.stream;

  @override
  PlaybackMachineState get currentState => _currentState;

  @override
  Duration get currentPosition => _player.position;

  @override
  Duration get totalDuration => _player.duration ?? Duration.zero;

  @override
  double get volume => _player.volume;

  PlaybackFailure? get lastError => _lastError;

  @override
  Future<void> init() async {
    // 1. Configure AudioSession for music playback with automatic audio focus handling
    try {
      _session = await AudioSession.instance;
      await _session?.configure(const AudioSessionConfiguration.music());

      _interruptionSub = _session?.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(0.2);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              _transitionState(PlaybackMachineState.interrupted);
              _player.pause();
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player.setVolume(1.0);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              // Focus returned; wait for explicit user resume or auto-resume if configured
              break;
          }
        }
      });

      // 2. Headphone disconnection ("Becoming Noisy")
      _noisySub = _session?.becomingNoisyEventStream.listen((_) {
        _transitionState(PlaybackMachineState.paused);
        _player.pause();
      });
    } catch (e) {
      debugPrint('AudioSession initialization non-fatal error: $e');
    }

    // 3. Map player state into explicit PlaybackMachineState
    _playerStateSub = _player.playerStateStream.listen((state) {
      if (_currentState == PlaybackMachineState.interrupted && state.playing) {
        _transitionState(PlaybackMachineState.playing);
        return;
      }

      switch (state.processingState) {
        case ProcessingState.idle:
          if (_currentState != PlaybackMachineState.failed) {
            _transitionState(PlaybackMachineState.idle);
          }
          break;
        case ProcessingState.loading:
          _transitionState(PlaybackMachineState.loading);
          break;
        case ProcessingState.buffering:
          _transitionState(PlaybackMachineState.buffering);
          break;
        case ProcessingState.ready:
          _transitionState(state.playing
              ? PlaybackMachineState.playing
              : PlaybackMachineState.paused);
          break;
        case ProcessingState.completed:
          _transitionState(PlaybackMachineState.completed);
          break;
      }
    }, onError: (e) {
      _handlePlayerError(e);
    });
  }

  void _transitionState(PlaybackMachineState newState) {
    if (_currentState == newState) return;
    _currentState = newState;
    _stateController.add(newState);
  }

  void _handlePlayerError(Object error) {
    PlaybackFailure failure;
    if (error is PlayerException) {
      failure = PlaybackFailure(
        type: PlaybackFailureType.invalidMedia,
        internalMessage: error.message ?? 'Playback player exception',
        originalError: error,
      );
    } else {
      failure = PlaybackFailure(
        type: PlaybackFailureType.unknownPlaybackFailure,
        internalMessage: error.toString(),
        originalError: error,
      );
    }
    _lastError = failure;
    _transitionState(PlaybackMachineState.failed);
  }

  @override
  Future<void> load(PlaybackSource source) async {
    _transitionState(PlaybackMachineState.loading);
    _lastError = null;

    try {
      if (source.isAsset) {
        await _player.setAsset(source.uri.path);
      } else if (source.isLocal) {
        await _player.setFilePath(source.uri.toFilePath());
      } else {
        await _player.setUrl(
          source.uri.toString(),
          headers: source.headers,
        );
      }
    } catch (e) {
      _handlePlayerError(e);
      rethrow;
    }
  }

  @override
  Future<void> play() async {
    try {
      await _player.play();
    } catch (e) {
      _handlePlayerError(e);
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (e) {
      _handlePlayerError(e);
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      _handlePlayerError(e);
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  @override
  Future<void> stop() async {
    try {
      await _player.stop();
      _transitionState(PlaybackMachineState.idle);
    } catch (e) {
      _handlePlayerError(e);
    }
  }

  @override
  Future<void> dispose() async {
    await _interruptionSub?.cancel();
    await _noisySub?.cancel();
    await _playerStateSub?.cancel();
    await _player.dispose();
    await _stateController.close();
  }
}

