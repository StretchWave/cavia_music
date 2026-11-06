import 'track.dart';

/// Domain model representing a playlist collection.
class Playlist {
  final String id;
  final String profileId;
  final String name;
  final String description;
  final String artworkUri;
  String get artworkAsset => artworkUri;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSystem;
  bool get isCustom => !isSystem;
  final bool isDeleted;
  final int trackCount;
  final List<Song> songs;

  Playlist({
    required this.id,
    this.profileId = 'guest',
    required this.name,
    this.description = '',
    String? artworkUri,
    String? artworkAsset,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isSystem = false,
    this.isDeleted = false,
    this.trackCount = 0,
    this.songs = const [],
  })  : artworkUri = artworkUri ?? artworkAsset ?? '',
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Playlist copyWith({
    String? id,
    String? profileId,
    String? name,
    String? description,
    String? artworkUri,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSystem,
    bool? isDeleted,
    int? trackCount,
    List<Song>? songs,
  }) {
    return Playlist(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      description: description ?? this.description,
      artworkUri: artworkUri ?? this.artworkUri,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSystem: isSystem ?? this.isSystem,
      isDeleted: isDeleted ?? this.isDeleted,
      trackCount: trackCount ?? this.trackCount,
      songs: songs ?? this.songs,
    );
  }
}
