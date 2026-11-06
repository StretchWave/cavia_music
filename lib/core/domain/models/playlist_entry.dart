import 'track.dart';

/// Domain model representing an individual track entry inside a playlist.
/// An entry has its own unique ID independent of the underlying track,
/// allowing the same track to appear multiple times in a playlist at different positions.
class PlaylistEntry {
  final String id;
  final String playlistId;
  final String trackId;
  final int position;
  final DateTime dateAdded;
  final Track? track;

  const PlaylistEntry({
    required this.id,
    required this.playlistId,
    required this.trackId,
    required this.position,
    required this.dateAdded,
    this.track,
  });

  PlaylistEntry copyWith({
    String? id,
    String? playlistId,
    String? trackId,
    int? position,
    DateTime? dateAdded,
    Track? track,
  }) {
    return PlaylistEntry(
      id: id ?? this.id,
      playlistId: playlistId ?? this.playlistId,
      trackId: trackId ?? this.trackId,
      position: position ?? this.position,
      dateAdded: dateAdded ?? this.dateAdded,
      track: track ?? this.track,
    );
  }
}

