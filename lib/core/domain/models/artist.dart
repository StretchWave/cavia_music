import 'album.dart';
import 'track.dart';

/// Domain model representing a music artist.
class Artist {
  final String id;
  final String name;
  final String portraitUri;
  String get portraitAsset => portraitUri;
  final String? sourceAttribution;
  final bool isFollowed;
  final List<Track> popularTracks;
  List<Track> get popularSongs => popularTracks;
  final List<Track> singles;
  final List<Album> albums;

  Artist({
    required this.id,
    required this.name,
    String? portraitUri,
    String? portraitAsset,
    this.sourceAttribution,
    this.isFollowed = false,
    List<Track>? popularTracks,
    List<Track>? popularSongs,
    this.singles = const [],
    this.albums = const [],
  }) : portraitUri = portraitUri ?? portraitAsset ?? '',
       popularTracks = popularTracks ?? popularSongs ?? const [];

  Artist copyWith({
    String? id,
    String? name,
    String? portraitUri,
    String? sourceAttribution,
    bool? isFollowed,
    List<Track>? popularTracks,
    List<Track>? singles,
    List<Album>? albums,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      portraitUri: portraitUri ?? this.portraitUri,
      sourceAttribution: sourceAttribution ?? this.sourceAttribution,
      isFollowed: isFollowed ?? this.isFollowed,
      popularTracks: popularTracks ?? this.popularTracks,
      singles: singles ?? this.singles,
      albums: albums ?? this.albums,
    );
  }
}
