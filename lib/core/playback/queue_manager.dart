import 'dart:math';
import '../models/music_models.dart';

/// Actions to execute when previous button is tapped.
enum PreviousAction {
  seekToStart,
  previousTrack,
}

/// A unique entry within the playback queue.
class QueueEntry {
  final String id;
  final Song track;

  const QueueEntry({required this.id, required this.track});
}

/// Manages the queue state, shuffle projections, repeat cycles, and edge cases.
class QueueManager {
  List<QueueEntry> _originalQueue = [];
  List<QueueEntry> _activeQueue = [];
  int _currentIndex = -1;
  bool _isShuffle = false;
  CaviaRepeatMode _repeatMode = CaviaRepeatMode.off;
  final Random _random = Random();

  QueueManager({
    List<Song>? initialSongs,
    int initialIndex = 0,
    bool isShuffle = false,
    CaviaRepeatMode repeatMode = CaviaRepeatMode.off,
  }) {
    if (initialSongs != null && initialSongs.isNotEmpty) {
      setQueue(initialSongs, startIndex: initialIndex);
    }
    _isShuffle = isShuffle;
    _repeatMode = repeatMode;
  }

  // Getters
  List<Song> get songs => _activeQueue.map((e) => e.track).toList();
  List<QueueEntry> get entries => List.unmodifiable(_activeQueue);
  int get currentIndex => _currentIndex;
  bool get isShuffle => _isShuffle;
  CaviaRepeatMode get repeatMode => _repeatMode;
  bool get isEmpty => _activeQueue.isEmpty;
  int get length => _activeQueue.length;

  Song? get currentSong {
    if (_currentIndex < 0 || _currentIndex >= _activeQueue.length) return null;
    return _activeQueue[_currentIndex].track;
  }

  QueueEntry? get currentEntry {
    if (_currentIndex < 0 || _currentIndex >= _activeQueue.length) return null;
    return _activeQueue[_currentIndex];
  }

  /// Replace entire queue with [newSongs] and point to [startIndex].
  void setQueue(List<Song> newSongs, {int startIndex = 0}) {
    if (newSongs.isEmpty) {
      _originalQueue = [];
      _activeQueue = [];
      _currentIndex = -1;
      return;
    }

    _originalQueue = [
      for (int i = 0; i < newSongs.length; i++)
        QueueEntry(id: 'qe_${newSongs[i].id}_${DateTime.now().microsecondsSinceEpoch}_$i', track: newSongs[i]),
    ];

    if (_isShuffle) {
      _applyShuffle(startIndex: startIndex);
    } else {
      _activeQueue = List.from(_originalQueue);
      _currentIndex = startIndex.clamp(0, _activeQueue.length - 1);
    }
  }

  /// Inserts a song immediately following the current track.
  void playNext(Song song) {
    final newEntry = QueueEntry(
      id: 'qe_${song.id}_${DateTime.now().microsecondsSinceEpoch}',
      track: song,
    );

    if (_activeQueue.isEmpty) {
      _originalQueue = [newEntry];
      _activeQueue = [newEntry];
      _currentIndex = 0;
      return;
    }

    final insertIdx = (_currentIndex + 1).clamp(0, _activeQueue.length);
    _activeQueue.insert(insertIdx, newEntry);
    _originalQueue.insert(insertIdx, newEntry);
  }

  /// Appends a song to the end of the queue.
  void addToQueue(Song song) {
    final newEntry = QueueEntry(
      id: 'qe_${song.id}_${DateTime.now().microsecondsSinceEpoch}',
      track: song,
    );

    if (_activeQueue.isEmpty) {
      _originalQueue = [newEntry];
      _activeQueue = [newEntry];
      _currentIndex = 0;
      return;
    }

    _activeQueue.add(newEntry);
    _originalQueue.add(newEntry);
  }

  /// Play a song immediately: if already in queue, jump to it; otherwise insert at head.
  void playNow(Song song) {
    final existingIdx = _activeQueue.indexWhere((e) => e.track.id == song.id);
    if (existingIdx != -1) {
      _currentIndex = existingIdx;
    } else {
      final newEntry = QueueEntry(
        id: 'qe_${song.id}_${DateTime.now().microsecondsSinceEpoch}',
        track: song,
      );
      _activeQueue.insert(0, newEntry);
      _originalQueue.insert(0, newEntry);
      _currentIndex = 0;
    }
  }

  /// Handles Skip Next, honoring repeat modes and queue boundaries.
  /// Returns the next Song, or null if queue has finished and repeat is off.
  Song? skipNext() {
    if (_activeQueue.isEmpty) return null;

    if (_repeatMode == CaviaRepeatMode.one) {
      return currentSong;
    }

    if (_currentIndex + 1 < _activeQueue.length) {
      _currentIndex++;
      return _activeQueue[_currentIndex].track;
    } else if (_repeatMode == CaviaRepeatMode.all) {
      _currentIndex = 0;
      return _activeQueue[0].track;
    } else {
      // Reached end of queue without repeat
      return null;
    }
  }

  /// Handles Skip Previous with the 3-second threshold rule:
  /// - If current playback position > 3 seconds, seek back to 0:00.
  /// - If <= 3 seconds, navigate to previous track in queue.
  PreviousAction determinePreviousAction(Duration currentPosition) {
    if (currentPosition.inSeconds > 3) {
      return PreviousAction.seekToStart;
    }
    return PreviousAction.previousTrack;
  }

  /// Moves to the previous song if index > 0.
  Song? skipPrevious() {
    if (_activeQueue.isEmpty) return null;

    if (_currentIndex > 0) {
      _currentIndex--;
      return _activeQueue[_currentIndex].track;
    } else if (_repeatMode == CaviaRepeatMode.all) {
      _currentIndex = _activeQueue.length - 1;
      return _activeQueue[_currentIndex].track;
    }
    return currentSong;
  }

  /// Reorders queue entries safely.
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _activeQueue.length) return;
    if (oldIndex < newIndex) newIndex -= 1;
    newIndex = newIndex.clamp(0, _activeQueue.length - 1);

    final currentEntryId = currentEntry?.id;
    final item = _activeQueue.removeAt(oldIndex);
    _activeQueue.insert(newIndex, item);

    // Update currentIndex to follow the moving active entry
    if (currentEntryId != null) {
      _currentIndex = _activeQueue.indexWhere((e) => e.id == currentEntryId);
    }
  }

  /// Removes entry at [index] safely.
  void removeAt(int index) {
    if (index < 0 || index >= _activeQueue.length) return;

    final wasCurrent = index == _currentIndex;
    final removed = _activeQueue.removeAt(index);
    _originalQueue.removeWhere((e) => e.id == removed.id);

    if (_activeQueue.isEmpty) {
      _currentIndex = -1;
    } else if (wasCurrent) {
      if (_currentIndex >= _activeQueue.length) {
        _currentIndex = _activeQueue.length - 1;
      }
    } else if (index < _currentIndex) {
      _currentIndex--;
    }
  }

  /// Clears entire queue except for the currently playing track.
  void clearExceptCurrent() {
    if (currentEntry == null) {
      _activeQueue.clear();
      _originalQueue.clear();
      _currentIndex = -1;
      return;
    }

    final current = currentEntry!;
    _activeQueue = [current];
    _originalQueue = [current];
    _currentIndex = 0;
  }

  /// Toggle shuffle mode while preserving the current playing song at its spot.
  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    if (_activeQueue.isEmpty) return;

    final current = currentEntry;
    if (_isShuffle) {
      _applyShuffle(currentEntryId: current?.id);
    } else {
      // Restore original queue order
      _activeQueue = List.from(_originalQueue);
      if (current != null) {
        _currentIndex = _activeQueue.indexWhere((e) => e.id == current.id);
        if (_currentIndex == -1) _currentIndex = 0;
      }
    }
  }

  void _applyShuffle({int startIndex = 0, String? currentEntryId}) {
    if (_originalQueue.isEmpty) return;

    final list = List<QueueEntry>.from(_originalQueue);
    QueueEntry? current;

    if (currentEntryId != null) {
      final idx = list.indexWhere((e) => e.id == currentEntryId);
      if (idx != -1) current = list.removeAt(idx);
    } else if (startIndex >= 0 && startIndex < list.length) {
      current = list.removeAt(startIndex);
    }

    // Fisher-Yates shuffle remaining items
    for (int i = list.length - 1; i > 0; i--) {
      final n = _random.nextInt(i + 1);
      final temp = list[i];
      list[i] = list[n];
      list[n] = temp;
    }

    if (current != null) {
      list.insert(0, current);
      _currentIndex = 0;
    } else {
      _currentIndex = 0;
    }

    _activeQueue = list;
  }

  /// Cycle repeat mode: off -> all -> one -> off.
  void cycleRepeatMode() {
    _repeatMode = switch (_repeatMode) {
      CaviaRepeatMode.off => CaviaRepeatMode.all,
      CaviaRepeatMode.all => CaviaRepeatMode.one,
      CaviaRepeatMode.one => CaviaRepeatMode.off,
    };
  }

  void setRepeatMode(CaviaRepeatMode mode) {
    _repeatMode = mode;
  }
}
