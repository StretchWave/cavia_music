import 'track.dart';

enum CaviaRepeatMode { off, all, one }

class QueueItem {
  final String id;
  final String trackId;
  final int position;
  final Track? track;

  const QueueItem({
    required this.id,
    required this.trackId,
    required this.position,
    this.track,
  });

  QueueItem copyWith({
    String? id,
    String? trackId,
    int? position,
    Track? track,
  }) {
    return QueueItem(
      id: id ?? this.id,
      trackId: trackId ?? this.trackId,
      position: position ?? this.position,
      track: track ?? this.track,
    );
  }
}

/// Persisted playback queue state.
class PlaybackQueueState {
  final List<QueueItem> items;
  final int currentIndex;
  final CaviaRepeatMode repeatMode;
  final bool isShuffle;
  final Duration position;
  final bool isPlaying;
  final double speed;

  const PlaybackQueueState({
    this.items = const [],
    this.currentIndex = 0,
    this.repeatMode = CaviaRepeatMode.off,
    this.isShuffle = false,
    this.position = Duration.zero,
    this.isPlaying = false,
    this.speed = 1.0,
  });

  Track? get currentTrack {
    if (currentIndex >= 0 && currentIndex < items.length) {
      return items[currentIndex].track;
    }
    return null;
  }

  PlaybackQueueState copyWith({
    List<QueueItem>? items,
    int? currentIndex,
    CaviaRepeatMode? repeatMode,
    bool? isShuffle,
    Duration? position,
    bool? isPlaying,
    double? speed,
  }) {
    return PlaybackQueueState(
      items: items ?? this.items,
      currentIndex: currentIndex ?? this.currentIndex,
      repeatMode: repeatMode ?? this.repeatMode,
      isShuffle: isShuffle ?? this.isShuffle,
      position: position ?? this.position,
      isPlaying: isPlaying ?? this.isPlaying,
      speed: speed ?? this.speed,
    );
  }

  static PlaybackQueueState initial() => const PlaybackQueueState(
        items: [],
        currentIndex: -1,
        repeatMode: CaviaRepeatMode.off,
        isShuffle: false,
        position: Duration.zero,
        isPlaying: false,
        speed: 1.0,
      );
}
