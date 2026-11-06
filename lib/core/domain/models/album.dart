import 'track.dart';

/// Domain model representing an album release.
class Album {
  final String id;
  final String title;
  final String artist;
  final int year;
  final String artworkUri;
  String get artworkAsset => artworkUri;
  final String? sourceAttribution;
  final bool isSaved;
  final List<Track> tracks;
  List<Track> get songs => tracks;

  Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.year,
    String? artworkUri,
    String? artworkAsset,
    this.sourceAttribution,
    this.isSaved = false,
    List<Track>? tracks,
    List<Track>? songs,
  })  : artworkUri = artworkUri ?? artworkAsset ?? '',
        tracks = tracks ?? songs ?? const [];

  Album copyWith({
    String? id,
    String? title,
    String? artist,
    int? year,
    String? artworkUri,
    String? sourceAttribution,
    bool? isSaved,
    List<Track>? tracks,
  }) {
    return Album(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      year: year ?? this.year,
      artworkUri: artworkUri ?? this.artworkUri,
      sourceAttribution: sourceAttribution ?? this.sourceAttribution,
      isSaved: isSaved ?? this.isSaved,
      tracks: tracks ?? this.tracks,
    );
  }
}
