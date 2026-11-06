import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import '../domain/result/result.dart';
import '../domain/result/app_error.dart';
import '../domain/models/track.dart';
import '../domain/models/playback_queue.dart';
import '../domain/repositories/queue_repository.dart';
import '../domain/repositories/track_repository.dart';
import '../mock_data/mock_library.dart';
import '../playback/audio_engine.dart';
import '../playback/just_audio_engine.dart';
import '../playback/mock_audio_engine.dart';
import '../playback/playback_machine_state.dart';
import '../playback/track_resolver.dart';
import '../playback/queue_manager.dart';
import '../playback/cavia_audio_handler.dart';
import '../providers/provider_registry.dart';
import '../providers/local_audio_provider.dart';

export '../domain/models/playback_queue.dart' show CaviaRepeatMode;
export '../playback/playback_machine_state.dart';
export '../playback/playback_failure.dart';

/// Central Playback Coordinator connecting UI, AudioEngine, QueueManager,
/// Media Sessions, and Track Resolvers.
class PlaybackController extends ChangeNotifier {
  final AudioEngine audioEngine;
  final TrackResolver trackResolver;
  final QueueRepository? queueRepository;
  final TrackRepository? trackRepository;
  final CaviaAudioHandler? audioHandler;

  final QueueManager _queueManager = QueueManager();

  Song _currentSong = MockLibrary.allSongs[0];
  PlaybackMachineState _state = PlaybackMachineState.playing;
  Duration _currentPosition = const Duration(minutes: 2, seconds: 18);
  Duration _totalDuration = MockLibrary.allSongs[0].duration;
  String? _lastErrorMessage;

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
    TrackResolver? trackResolver,
    this.queueRepository,
    this.trackRepository,
    this.audioHandler,
  })  : audioEngine = audioEngine ?? _resolveDefaultEngine(),
        trackResolver = trackResolver ??
            TrackResolver(
              providerRegistry: ProviderRegistry(initialProviders: [
                if (trackRepository != null)
                  LocalAudioProvider(trackRepository: trackRepository),
              ]),
              trackRepository: trackRepository ?? _FallbackTrackRepo(),
            ) {
    _initQueue();
    _bindEngineStreams();
    _bindAudioHandler();
  }

  static AudioEngine _resolveDefaultEngine() {
    try {
      if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
        return MockAudioEngine();
      }
    } catch (_) {}
    return JustAudioEngine();
  }

  void _initQueue() async {
    _queueManager.setQueue(List.from(MockLibrary.allSongs), startIndex: 0);
    _currentSong = _queueManager.currentSong ?? MockLibrary.allSongs[0];
    _totalDuration = _currentSong.duration;

    if (queueRepository != null) {
      final res = await queueRepository!.loadQueue();
      if (_isDisposed) return;
      if (res.isSuccess && res.dataOrNull != null) {
        final state = res.dataOrNull!;
        if (state.items.isNotEmpty) {
          final loadedSongs = state.items
              .map((i) => i.track ?? MockLibrary.allSongs[0])
              .toList();
          _queueManager.setQueue(loadedSongs, startIndex: state.currentIndex);
          _queueManager.setRepeatMode(state.repeatMode);
          if (state.isShuffle) _queueManager.toggleShuffle();

          _currentSong = _queueManager.currentSong ?? loadedSongs.first;
          _currentPosition = state.position;
          _totalDuration = _currentSong.duration;
          _state = state.isPlaying
              ? PlaybackMachineState.playing
              : PlaybackMachineState.paused;
          notifyListeners();
        }
      }
    }
  }

  void _bindEngineStreams() {
    audioEngine.init();

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
    audioHandler?.updateTrackMetadata(
      id: _currentSong.id,
      title: _currentSong.title,
      artist: _currentSong.artist,
      album: _currentSong.album,
      duration: _totalDuration,
      artworkAssetOrUrl: _currentSong.artworkAsset,
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

  // Getters
  Song get currentSong => _currentSong;
  bool get isPlaying => _state == PlaybackMachineState.playing;
  PlaybackMachineState get playbackState => _state;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  String? get lastErrorMessage => _lastErrorMessage;

  double get progress {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return (_currentPosition.inMilliseconds / _totalDuration.inMilliseconds).clamp(0.0, 1.0);
  }

  List<Song> get queue => _queueManager.songs;
  int get currentIndex => _queueManager.currentIndex;
  bool get isShuffle => _queueManager.isShuffle;
  CaviaRepeatMode get repeatMode => _queueManager.repeatMode;

  bool get isFullPlayerExpanded => _isFullPlayerExpanded;
  bool get isQueueSheetOpen => _isQueueSheetOpen;
  bool get isLyricsOpen => _isLyricsOpen;

  // Interactions
  void play() async {
    if (isPlaying) return;
    _lastErrorMessage = null;
    _state = PlaybackMachineState.playing;
    notifyListeners();
    _persistQueue();
    await audioEngine.play();
  }

  void pause() async {
    if (!isPlaying) return;
    _state = PlaybackMachineState.paused;
    notifyListeners();
    _persistQueue();
    await audioEngine.pause();
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

  /// Plays [song] immediately with request token race-condition protection.
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

    final domainTrack = Track(
      id: song.id,
      providerId: song.id.startsWith('yt_') ? 'youtube_music' : 'local',
      providerTrackId: song.id.startsWith('yt_') ? song.id.replaceFirst('yt_', '') : song.id,
      title: song.title,
      artist: song.artist,
      album: song.album,
      duration: song.duration,
      artworkAsset: song.artworkAsset,
      sourceAttribution: song.id.startsWith('yt_') ? 'YouTube Music' : 'Cavia Music',
      dateAdded: DateTime.now(),
    );

    final resolveResult = await trackResolver.resolve(domainTrack);

    // Stale request protection: if a newer request was dispatched while resolving, discard this
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
      await audioEngine.play();

      _state = PlaybackMachineState.playing;
      trackRepository?.updatePlayStats(song.id, Duration.zero);
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

    repo.saveQueue(PlaybackQueueState(
      items: items,
      currentIndex: _queueManager.currentIndex,
      repeatMode: _queueManager.repeatMode,
      isShuffle: _queueManager.isShuffle,
      position: _currentPosition,
      isPlaying: isPlaying,
    ));
  }

  // Modals & Panels
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

/// Simple fallback track repository for non-database standalone runs
class _FallbackTrackRepo implements TrackRepository {
  @override
  Future<Result<List<Track>, AppError>> getAllTracks({String? profileId}) async =>
      const Result.success([]);

  @override
  Stream<List<Track>> watchTracks({String? profileId}) => const Stream.empty();

  @override
  Stream<List<Track>> watchLikedTracks({String? profileId}) => const Stream.empty();

  @override
  Future<Result<Track, AppError>> getTrackById(String id, {String? profileId}) async =>
      const Result.failure(NotFoundError('Fallback'));

  @override
  Future<Result<bool, AppError>> isTrackLiked(String trackId, {String? profileId}) async =>
      const Result.success(false);

  @override
  Future<Result<bool, AppError>> toggleLike(String trackId, {String? profileId}) async =>
      const Result.success(false);

  @override
  Future<Result<void, AppError>> updatePlayStats(String trackId, Duration position, {String? profileId}) async =>
      const Result.success(null);

  @override
  Future<Result<void, AppError>> insertTrack(Track track, {String? profileId}) async =>
      const Result.success(null);
}
