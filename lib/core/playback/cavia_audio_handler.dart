import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

/// Background audio handler integrating Cavia Music with platform media sessions
/// (Android Notification & Lock Screen, Windows SMTC, and Linux MPRIS).
class CaviaAudioHandler extends BaseAudioHandler with SeekHandler {
  VoidCallback? onPlayCallback;
  VoidCallback? onPauseCallback;
  VoidCallback? onSkipNextCallback;
  VoidCallback? onSkipPreviousCallback;
  void Function(Duration)? onSeekCallback;
  VoidCallback? onStopCallback;

  CaviaAudioHandler() {
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: AudioProcessingState.idle,
      playing: false,
    ));
  }

  void updateTrackMetadata({
    required String id,
    required String title,
    required String artist,
    required String album,
    required Duration duration,
    String? artworkAssetOrUrl,
  }) {
    mediaItem.add(MediaItem(
      id: id,
      album: album,
      title: title,
      artist: artist,
      duration: duration,
      artUri: artworkAssetOrUrl != null
          ? (artworkAssetOrUrl.startsWith('http')
              ? Uri.parse(artworkAssetOrUrl)
              : Uri.file(artworkAssetOrUrl))
          : null,
    ));
  }

  void updateState({
    required bool isPlaying,
    required Duration position,
    required Duration totalDuration,
    required AudioProcessingState processingState,
  }) {
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        isPlaying ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
      },
      androidCompactActionIndices: const [0, 1, 2],
      processingState: processingState,
      playing: isPlaying,
      updatePosition: position,
      bufferedPosition: position,
      speed: 1.0,
    ));
  }

  @override
  Future<void> play() async {
    onPlayCallback?.call();
  }

  @override
  Future<void> pause() async {
    onPauseCallback?.call();
  }

  @override
  Future<void> stop() async {
    onStopCallback?.call();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    onSeekCallback?.call(position);
  }

  @override
  Future<void> skipToNext() async {
    onSkipNextCallback?.call();
  }

  @override
  Future<void> skipToPrevious() async {
    onSkipPreviousCallback?.call();
  }
}

