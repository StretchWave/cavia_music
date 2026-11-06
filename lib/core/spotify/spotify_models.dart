/// Domain models for Spotify catalog metadata and import operations.
library;

/// Image reference from Spotify API.
class SpotifyImage {
  final String url;
  final int? height;
  final int? width;

  const SpotifyImage({required this.url, this.height, this.width});

  factory SpotifyImage.fromJson(Map<String, dynamic> json) {
    return SpotifyImage(
      url: json['url'] as String? ?? '',
      height: json['height'] as int?,
      width: json['width'] as int?,
    );
  }
}

/// Metadata for a public or user-authorized Spotify playlist.
class SpotifyPlaylistMetadata {
  final String id;
  final String name;
  final String description;
  final String ownerName;
  final String? artworkUrl;
  final int totalTracks;
  final bool isCollaborative;
  final bool isPublic;

  const SpotifyPlaylistMetadata({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerName,
    this.artworkUrl,
    required this.totalTracks,
    this.isCollaborative = false,
    this.isPublic = true,
  });

  factory SpotifyPlaylistMetadata.fromJson(Map<String, dynamic> json) {
    final images = (json['images'] as List?)
            ?.map((i) => SpotifyImage.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [];
    final owner = json['owner'] as Map<String, dynamic>?;

    return SpotifyPlaylistMetadata(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled Playlist',
      description: json['description'] as String? ?? '',
      ownerName: owner?['display_name'] as String? ?? owner?['id'] as String? ?? 'Spotify User',
      artworkUrl: images.isNotEmpty ? images.first.url : null,
      totalTracks: (json['tracks']?['total'] as int?) ?? (json['items']?['total'] as int?) ?? 0,
      isCollaborative: json['collaborative'] as bool? ?? false,
      isPublic: json['public'] as bool? ?? true,
    );
  }
}

/// A track retrieved from a Spotify playlist item.
class SpotifyTrackItem {
  final String id;
  final String name;
  final String artist;
  final List<String> artists;
  final String album;
  final Duration duration;
  final String? isrc;
  final String? artworkUrl;
  final bool isPlayable;
  final bool isLocal;
  final bool isExplicit;

  const SpotifyTrackItem({
    required this.id,
    required this.name,
    required this.artist,
    this.artists = const [],
    required this.album,
    required this.duration,
    this.isrc,
    this.artworkUrl,
    this.isPlayable = true,
    this.isLocal = false,
    this.isExplicit = false,
  });

  factory SpotifyTrackItem.fromJson(Map<String, dynamic> json) {
    final artistsList = (json['artists'] as List?)
            ?.map((a) => (a as Map<String, dynamic>)['name'] as String? ?? '')
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];
    final primaryArtist = artistsList.isNotEmpty ? artistsList.first : 'Unknown Artist';

    final albumObj = json['album'] as Map<String, dynamic>?;
    final albumName = albumObj?['name'] as String? ?? 'Unknown Album';
    final albumImages = (albumObj?['images'] as List?)
            ?.map((i) => SpotifyImage.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [];

    final externalIds = json['external_ids'] as Map<String, dynamic>?;
    final isrc = externalIds?['isrc'] as String?;

    return SpotifyTrackItem(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      artist: primaryArtist,
      artists: artistsList,
      album: albumName,
      duration: Duration(milliseconds: json['duration_ms'] as int? ?? 0),
      isrc: isrc,
      artworkUrl: albumImages.isNotEmpty ? albumImages.first.url : null,
      isPlayable: json['is_playable'] as bool? ?? true,
      isLocal: json['is_local'] as bool? ?? false,
      isExplicit: json['explicit'] as bool? ?? false,
    );
  }
}

/// Confidence classification for track matching candidates.
enum MatchConfidence {
  /// Exact ISRC or exact normalized title + artist with matching duration.
  highConfidence,

  /// Title and artist match with minor duration difference.
  possibleMatch,

  /// Multiple candidates or version discrepancies (live, remix, acoustic).
  ambiguous,

  /// No suitable candidate found in available catalogs.
  unmatched,

  /// Source is explicitly marked unavailable or region-restricted.
  unavailable,
}

/// Match candidate result pairing a Spotify track with an authorized internal track.
class TrackMatchResult {
  final SpotifyTrackItem spotifyTrack;
  final String? matchedTrackId;
  final String? matchedTitle;
  final String? matchedArtist;
  final MatchConfidence confidence;
  final String matchReason;

  const TrackMatchResult({
    required this.spotifyTrack,
    this.matchedTrackId,
    this.matchedTitle,
    this.matchedArtist,
    required this.confidence,
    required this.matchReason,
  });

  bool get isMatched =>
      (confidence == MatchConfidence.highConfidence ||
          confidence == MatchConfidence.possibleMatch) &&
      matchedTrackId != null;
}

/// Options configured by the user before committing an import.
class ImportOptions {
  final String destinationPlaylistName;
  final String? existingPlaylistId;
  final bool skipDuplicates;
  final bool skipUnmatched;
  final bool allowExplicitDuplicates;

  const ImportOptions({
    required this.destinationPlaylistName,
    this.existingPlaylistId,
    this.skipDuplicates = true,
    this.skipUnmatched = false,
    this.allowExplicitDuplicates = false,
  });
}

/// Final summary report of an executed import operation.
class ImportSummary {
  final String playlistName;
  final int totalTracks;
  final int matchedCount;
  final int importedCount;
  final int skippedCount;
  final int unmatchedCount;
  final int failedCount;

  const ImportSummary({
    required this.playlistName,
    required this.totalTracks,
    required this.matchedCount,
    required this.importedCount,
    required this.skippedCount,
    required this.unmatchedCount,
    required this.failedCount,
  });

  String get userMessage => 'Imported $importedCount of $totalTracks tracks';
  String? get unmatchedMessage =>
      unmatchedCount > 0 ? '$unmatchedCount tracks couldn\'t be matched.' : null;
}
