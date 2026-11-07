import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import '../domain/models/track.dart';
import '../domain/models/playback_queue.dart';
import '../domain/repositories/queue_repository.dart';
import '../playback/audio_engine.dart';
import '../playback/just_audio_engine.dart';
import '../playback/playback_machine_state.dart';
import '../playback/playback_source.dart';
import '../playback/playback_failure.dart';
import '../playback/track_resolver.dart';
import '../playback/queue_manager.dart';
import '../playback/cavia_audio_handler.dart';
import 'dart:io' show Platform;

export '../domain/models/playback_queue.dart' show CaviaRepeatMode;
export '../playback/playback_machine_state.dart';
export '../playback/playback_failure.dart';

/// Central playback coordinator connecting the UI, [AudioEngine],
/// [QueueManager], the platform media session, and [TrackResolver].
///
/// State starts completely empty: there is no current song and no queue until
/// the user or a restored queue provides one, and a restored queue is always
/// reported as paused (never as "playing" across launches).
class PlaybackController extends ChangeNotifier {
  final AudioEngine audioEngine;
  final TrackResolver? trackResolver;
  final QueueRepository? queueRepository;
  final CaviaAudioHandler? audioHandler;

  final QueueManager _queueManager = QueueManager();

  Song? _currentSong;
  PlaybackMachineState _state = PlaybackMachineState.idle;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String? _lastErrorMessage;
  double _playbackSpeed = 1.0;

  int _requestEpoch = 0;
  bool _isFullPlayerExpanded = false;
  bool _isQueueSheetOpen = false;
  bool _isLyricsOpen = false;
  bool _isDisposed = false;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _stateSub;

  PlaybackController({
    AudioEngine? audioEngine,
    this.trackResolver,
    this.queueRepository,
    this.audioHandler,
  }) : audioEngine = audioEngine ?? _resolveDefaultEngine() {
    _initQueue();
    _bindEngineStreams();
    _bindAudioHandler();
  }

  static AudioEngine _resolveDefaultEngine() {
    // Widget/unit test environments never spin up the real audio pipeline;
    // tests that need playback inject a controllable engine explicitly.
    try {
      if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
        return _NoOpEngine();
      }
    } catch (_) {}
    return JustAudioEngine();
  }

  void _initQueue() async {
    final repo = queueRepository;
    if (repo == null) return;

    final res = await repo.loadQueue();
    if (_isDisposed) return;
    if (res.isSuccess && res.dataOrNull != null) {
      final state = res.dataOrNull!;
      if (state.items.isNotEmpty) {
        final loadedSongs = state.items.map((i) => i.track).whereType<Song>().toList();
        if (loadedSongs.isNotEmpty) {
          _queueManager.setQueue(loadedSongs, startIndex: state.currentIndex);
          _queueManager.setRepeatMode(state.repeatMode);
          if (_queueManager.isShuffle != state.isShuffle) {
            _queueManager.toggleShuffle();
          }

          _currentSong = _queueManager.currentSong ?? loadedSongs.first;
          _currentPosition = state.position;
          _totalDuration = _currentSong?.duration ?? Duration.zero;
          _playbackSpeed = state.speed;
          // Every restored session is honestly paused.
          _state = PlaybackMachineState.paused;
          unawaited(audioEngine.init().then((_) => audioEngine.setSpeed(_playbackSpeed)));
          _updateMediaSessionMetadata();
          notifyListeners();
          _persistQueue();
        }
      }
    }
  }

  void _bindEngineStreams() {
    unawaited(audioEngine.init());

    _posSub = audioEngine.positionStream.listen((pos) {
      if (_isDisposed) return;
      _currentPosition = pos;
      _updateMediaSessionState();
      notifyListeners();
    });

    _durSub = audioEngine.durationStream.listen((dur) {
      if (_isDisposed) return;
      if (dur != null && dur > Duration.zero) {
        _totalDuration = dur;
        notifyListeners();
      }
    });

    _stateSub = audioEngine.stateStream.listen((engineState) {
      if (_isDisposed) return;
      _state = engineState;
      _updateMediaSessionState();

      if (engineState == PlaybackMachineState.completed) {
        _handleTrackCompletion();
      }
      notifyListeners();
    });
  }

  void _bindAudioHandler() {
    final handler = audioHandler;
    if (handler == null) return;

    handler.onPlayCallback = play;
    handler.onPauseCallback = pause;
    handler.onSkipNextCallback = skipNext;
    handler.onSkipPreviousCallback = skipPrevious;
    handler.onSeekCallback = (pos) {
      if (_totalDuration.inMilliseconds > 0) {
        seekTo(pos.inMilliseconds / _totalDuration.inMilliseconds);
      }
    };
    handler.onStopCallback = pause;
  }

  void _updateMediaSessionMetadata() {
    final song = _currentSong;
    if (song == null) return;
    audioHandler?.updateTrackMetadata(
      id: song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: _totalDuration,
      artworkAssetOrUrl: song.artworkAsset,
    );
  }

  void _updateMediaSessionState() {
    AudioProcessingState processing = AudioProcessingState.ready;
    switch (_state) {
      case PlaybackMachineState.idle:
        processing = AudioProcessingState.idle;
        break;
      case PlaybackMachineState.resolving:
      case PlaybackMachineState.loading:
        processing = AudioProcessingState.loading;
        break;
      case PlaybackMachineState.buffering:
        processing = AudioProcessingState.buffering;
        break;
      case PlaybackMachineState.completed:
        processing = AudioProcessingState.completed;
        break;
      default:
        processing = AudioProcessingState.ready;
        break;
    }

    audioHandler?.updateState(
      isPlaying: isPlaying,
      position: _currentPosition,
      totalDuration: _totalDuration,
      processingState: processing,
    );
  }

  // ---------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------

  Song? get currentSong => _currentSong;
  bool get hasCurrentSong => _currentSong != null;
  bool get isPlaying => _state == PlaybackMachineState.playing;
  PlaybackMachineState get playbackState => _state;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  String? get lastErrorMessage => _lastErrorMessage;
  double get playbackSpeed => _playbackSpeed;

  double get progress {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return (_currentPosition.inMilliseconds / _totalDuration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  List<Song> get queue => _queueManager.songs;
  bool get hasQueue => _queueManager.length > 0;
  int get queueLength => _queueManager.length;
  int get currentIndex => _queueManager.currentIndex;
  bool get isShuffle => _queueManager.isShuffle;
  CaviaRepeatMode get repeatMode => _queueManager.repeatMode;

  bool get isFullPlayerExpanded => _isFullPlayerExpanded;
  bool get isQueueSheetOpen => _isQueueSheetOpen;
  bool get isLyricsOpen => _isLyricsOpen;

  // ---------------------------------------------------------------------
  // Basics
  // ---------------------------------------------------------------------

  void play() async {
    if (isPlaying) return;
    if (_currentSong == null) {
      _lastErrorMessage = 'Nothing is queued yet. Pick a song to start.';
      notifyListeners();
      return;
    }
    _lastErrorMessage = null;
    notifyListeners();
    await audioEngine.play();
  }

  void pause() async {
    if (!isPlaying) return;
    await audioEngine.pause();
    notifyListeners();
  }

  void togglePlayPause() {
    if (isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void seekTo(double fraction) async {
    final clamped = fraction.clamp(0.0, 1.0);
    final targetMs = (clamped * _totalDuration.inMilliseconds).round();
    final targetDuration = Duration(milliseconds: targetMs);
    _currentPosition = targetDuration;
    notifyListeners();
    _persistQueue();
    await audioEngine.seek(targetDuration);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    final clamped = speed.clamp(0.25, 4.0);
    _playbackSpeed = clamped;
    await audioEngine.setSpeed(clamped);
    _persistQueue();
    notifyListeners();
  }

  /// Resolves a real playable source for offline-caching requests. Returned
  /// to the storage layer as-is: no source rewriting or synthetic URLs.
  Future<Result<PlaybackSource, PlaybackFailure>> resolveSourceForCaching(
    Track track,
  ) async {
    final resolver = trackResolver;
    if (resolver == null) {
      return Result.failure(PlaybackFailure(
        type: PlaybackFailureType.playbackUnsupported,
        internalMessage: 'No audio resolver is available in this build.',
        trackId: track.id,
      ));
    }
    return resolver.resolve(track);
  }

  /// Plays [song] immediately with request token race-condition protection.
  /// [song] is a full [Track] (typedef [Song]); no provider identity is
  /// fabricated here — whatever the data source built is trusted.
  void playNow(Song song) async {
    final currentEpoch = ++_requestEpoch;
    _currentSong = song;
    _totalDuration = song.duration;
    _currentPosition = Duration.zero;
    _lastErrorMessage = null;

    _queueManager.playNow(song);
    _state = PlaybackMachineState.resolving;
    notifyListeners();

    _updateMediaSessionMetadata();
    _persistQueue();

    final resolver = trackResolver;
    if (resolver == null) {
      _lastErrorMessage = 'No audio resolver is available in this build.';
      _state = PlaybackMachineState.failed;
      notifyListeners();
      return;
    }

    final resolveResult = await resolver.resolve(song);

    // Stale request protection: a newer request won while we resolved.
    if (currentEpoch != _requestEpoch || _isDisposed) {
      return;
    }

    if (resolveResult.isFailure) {
      final failure = resolveResult.errorOrNull!;
      _lastErrorMessage = failure.userMessage;
      _state = PlaybackMachineState.failed;
      notifyListeners();
      return;
    }

    final source = resolveResult.dataOrNull!;
    try {
      _state = PlaybackMachineState.loading;
      notifyListeners();

      await audioEngine.load(source);
      if (currentEpoch != _requestEpoch || _isDisposed) return;
      await audioEngine.setSpeed(_playbackSpeed);
      await audioEngine.play();

      _state = PlaybackMachineState.playing;
      _updateMediaSessionState();
      notifyListeners();
    } catch (e) {
      if (currentEpoch == _requestEpoch && !_isDisposed) {
        _lastErrorMessage = "Couldn't start playback. Try again.";
        _state = PlaybackMachineState.failed;
        notifyListeners();
      }
    }
  }

  void playNext(Song song) {
    _queueManager.playNext(song);
    _persistQueue();
    notifyListeners();
  }

  void addToQueue(Song song) {
    _queueManager.addToQueue(song);
    _persistQueue();
    notifyListeners();
  }

  void skipNext() {
    if (_queueManager.isEmpty) return;
    _lastErrorMessage = null;

    final nextSong = _queueManager.skipNext();
    if (nextSong != null) {
      playNow(nextSong);
    } else {
      audioEngine.stop();
      _state = PlaybackMachineState.completed;
      notifyListeners();
    }
  }

  void skipPrevious() {
    if (_queueManager.isEmpty) return;
    _lastErrorMessage = null;

    final action = _queueManager.determinePreviousAction(_currentPosition);
    if (action == PreviousAction.seekToStart) {
      seekTo(0.0);
      return;
    }

    final prevSong = _queueManager.skipPrevious();
    if (prevSong != null) {
      playNow(prevSong);
    }
  }

  void _handleTrackCompletion() {
    if (_queueManager.repeatMode == CaviaRepeatMode.one) {
      seekTo(0.0);
      play();
    } else {
      skipNext();
    }
  }

  void toggleShuffle() {
    _queueManager.toggleShuffle();
    _persistQueue();
    notifyListeners();
  }

  void cycleRepeatMode() {
    _queueManager.cycleRepeatMode();
    _persistQueue();
    notifyListeners();
  }

  void reorderQueue(int oldIndex, int newIndex) {
    _queueManager.reorder(oldIndex, newIndex);
    _persistQueue();
    notifyListeners();
  }

  void removeFromQueue(int index) {
    _queueManager.removeAt(index);
    if (_queueManager.isEmpty) {
      audioEngine.stop();
      _state = PlaybackMachineState.idle;
    }
    _persistQueue();
    notifyListeners();
  }

  void clearQueue() {
    _queueManager.clearExceptCurrent();
    _persistQueue();
    notifyListeners();
  }

  void _persistQueue() {
    final repo = queueRepository;
    if (repo == null) return;
    final songsList = _queueManager.songs;
    final items = [
      for (int i = 0; i < songsList.length; i++)
        QueueItem(
          id: 'q_${songsList[i].id}_$i',
          trackId: songsList[i].id,
          position: i,
          track: songsList[i],
        ),
    ];

    unawaited(repo.saveQueue(PlaybackQueueState(
      items: items,
      currentIndex: _queueManager.currentIndex,
      repeatMode: _queueManager.repeatMode,
      isShuffle: _queueManager.isShuffle,
      position: _currentPosition,
      isPlaying: isPlaying,
      speed: _playbackSpeed,
    )));
  }

  // ---------------------------------------------------------------------
  // Modals & panels
  // ---------------------------------------------------------------------

  void setFullPlayerExpanded(bool expanded) {
    _isFullPlayerExpanded = expanded;
    notifyListeners();
  }

  void openQueue() {
    _isQueueSheetOpen = true;
    notifyListeners();
  }

  void closeQueue() {
    _isQueueSheetOpen = false;
    notifyListeners();
  }

  void openLyrics() {
    _isLyricsOpen = true;
    notifyListeners();
  }

  void closeLyrics() {
    _isLyricsOpen = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    audioEngine.dispose();
    super.dispose();
  }
}

/// Minimal engine used only inside `FLUTTER_TEST` environments where spinning
/// up real audio hardware would be wrong. It performs no fabricated playback:
/// work is dispatched but produces no sound, mirroring headless CI behavior.
class _NoOpEngine implements AudioEngine {
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();
  final _bufferedController = StreamController<Duration>.broadcast();
  final _stateController =
      StreamController<PlaybackMachineState>.broadcast();

  @override
  Stream<Duration> get positionStream => _positionController.stream;
  @override
  Stream<Duration?> get durationStream => _durationController.stream;
  @override
  Stream<Duration> get bufferedPositionStream => _bufferedController.stream;
  @override
  Stream<PlaybackMachineState> get stateStream => _stateController.stream;

  @override
  PlaybackMachineState get currentState => PlaybackMachineState.idle;
  @override
  Duration get currentPosition => Duration.zero;
  @override
  Duration get totalDuration => Duration.zero;
  @override
  double get volume => 1.0;
  @override
  double get speed => 1.0;

  @override
  Future<void> init() async {}
  @override
  Future<void> load(PlaybackSource source) => Future.value();
  @override
  Future<void> play() async {
    _stateController.add(PlaybackMachineState.playing);
  }

  @override
  Future<void> pause() async {
    _stateController.add(PlaybackMachineState.paused);
  }

  @override
  Future<void> seek(Duration position) => Future.value();
  @override
  Future<void> setVolume(double volume) => Future.value();
  @override
  Future<void> setSpeed(double speed) => Future.value();
  @override
  Future<void> stop() async {
    _stateController.add(PlaybackMachineState.idle);
  }

  @override
  Future<void> dispose() async {
    await _stateController.close();
  }
}
