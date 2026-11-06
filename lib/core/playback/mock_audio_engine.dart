import 'dart:async';
import 'audio_engine.dart';
import 'playback_machine_state.dart';
import 'playback_source.dart';

/// In-memory controllable audio engine for unit, widget, and platform-mock tests.
class MockAudioEngine implements AudioEngine {
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();
  final _bufferedController = StreamController<Duration>.broadcast();
  final _stateController = StreamController<PlaybackMachineState>.broadcast();

  PlaybackMachineState _currentState = PlaybackMachineState.idle;
  Duration _currentPosition = Duration.zero;
  final Duration _totalDuration = const Duration(minutes: 3, seconds: 30);
  double _volume = 1.0;
  PlaybackSource? _currentSource;
  Timer? _ticker;

  bool shouldFailLoad = false;
  String? failLoadMessage;

  @override
  Stream<Duration> get positionStream => _positionController.stream;

  @override
  Stream<Duration?> get durationStream => _durationController.stream;

  @override
  Stream<Duration> get bufferedPositionStream => _bufferedController.stream;

  @override
  Stream<PlaybackMachineState> get stateStream => _stateController.stream;

  @override
  PlaybackMachineState get currentState => _currentState;

  @override
  Duration get currentPosition => _currentPosition;

  @override
  Duration get totalDuration => _totalDuration;

  @override
  double get volume => _volume;

  PlaybackSource? get currentSource => _currentSource;

  @override
  Future<void> init() async {
    _transition(PlaybackMachineState.idle);
  }

  void _transition(PlaybackMachineState state) {
    _currentState = state;
    _stateController.add(state);
  }

  @override
  Future<void> load(PlaybackSource source) async {
    _transition(PlaybackMachineState.loading);
    _currentSource = source;

    if (shouldFailLoad) {
      _transition(PlaybackMachineState.failed);
      throw Exception(failLoadMessage ?? 'Mock load failed');
    }

    _transition(PlaybackMachineState.buffering);
    await Future.delayed(const Duration(milliseconds: 10));

    _currentPosition = Duration.zero;
    _positionController.add(_currentPosition);
    _durationController.add(_totalDuration);
    _bufferedController.add(_totalDuration);
    _transition(PlaybackMachineState.paused);
  }

  @override
  Future<void> play() async {
    if (_currentState == PlaybackMachineState.playing) return;
    _transition(PlaybackMachineState.playing);
    _startTicker();
  }

  @override
  Future<void> pause() async {
    _ticker?.cancel();
    _transition(PlaybackMachineState.paused);
  }

  @override
  Future<void> seek(Duration position) async {
    if (position < Duration.zero) {
      _currentPosition = Duration.zero;
    } else if (position > _totalDuration) {
      _currentPosition = _totalDuration;
    } else {
      _currentPosition = position;
    }
    _positionController.add(_currentPosition);
  }

  @override
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
  }

  @override
  Future<void> stop() async {
    _ticker?.cancel();
    _currentPosition = Duration.zero;
    _positionController.add(_currentPosition);
    _transition(PlaybackMachineState.idle);
  }

  /// Simulate an external interruption (e.g. phone call).
  void simulateInterruption() {
    _ticker?.cancel();
    _transition(PlaybackMachineState.interrupted);
  }

  /// Simulate track reaching its end duration.
  void simulateCompletion() {
    _ticker?.cancel();
    _currentPosition = _totalDuration;
    _positionController.add(_currentPosition);
    _transition(PlaybackMachineState.completed);
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_currentState != PlaybackMachineState.playing) return;
      _currentPosition += const Duration(milliseconds: 100);
      _positionController.add(_currentPosition);

      if (_currentPosition >= _totalDuration) {
        simulateCompletion();
      }
    });
  }

  @override
  Future<void> dispose() async {
    _ticker?.cancel();
    await _positionController.close();
    await _durationController.close();
    await _bufferedController.close();
    await _stateController.close();
  }
}
