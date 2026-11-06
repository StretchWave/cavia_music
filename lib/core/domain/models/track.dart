enum TrackAvailability {
  available,
  unavailable,
  restricted,
}

class LyricLine {
  final Duration timestamp;
  final String text;

  const LyricLine({
    required this.timestamp,
    required this.text,
  });

  Map<String, dynamic> toJson() => {
        'timestampMs': timestamp.inMilliseconds,
        'text': text,
      };

  factory LyricLine.fromJson(Map<String, dynamic> json) => LyricLine(
        timestamp: Duration(milliseconds: json['timestampMs'] as int? ?? 0),
        text: json['text'] as String? ?? '',
      );
}

/// Rich domain model for a playable audio track.
/// Represents a normalized recording with stable internal identity,
/// independent of temporary stream URLs or provider representations.
class Track {
  final String id;
  final String providerId; // 'local', 'youtube', 'spotify_ref', 'custom'
  final String providerTrackId;
  final String title;
  final String artist;
  final List<String> artists;
  final String album;
  final Duration duration;
  final String artworkUri;
  String get artworkAsset => artworkUri;
  final String? isrc;
  final bool explicit;
  final TrackAvailability availabilityState;
  final String? sourceAttribution;
  final DateTime dateAdded;
  final bool isLiked;
  final bool isCached;
  final String? localCachePath;
  final List<LyricLine> lyrics;

  bool get isLocal => providerId == 'local';

  Track({
    required this.id,
    this.providerId = 'local',
    this.providerTrackId = '',
    required this.title,
    required this.artist,
    this.artists = const [],
    required this.album,
    required this.duration,
    String? artworkUri,
    String? artworkAsset,
    this.isrc,
    this.explicit = false,
    this.availabilityState = TrackAvailability.available,
    this.sourceAttribution,
    DateTime? dateAdded,
    this.isLiked = false,
    this.isCached = false,
    this.localCachePath,
    this.lyrics = const [],
  })  : artworkUri = artworkUri ?? artworkAsset ?? '',
        dateAdded = dateAdded ?? DateTime.fromMillisecondsSinceEpoch(0);

  Track copyWith({
    String? id,
    String? providerId,
    String? providerTrackId,
    String? title,
    String? artist,
    List<String>? artists,
    String? album,
    Duration? duration,
    String? artworkUri,
    String? isrc,
    bool? explicit,
    TrackAvailability? availabilityState,
    String? sourceAttribution,
    DateTime? dateAdded,
    bool? isLiked,
    bool? isCached,
    String? localCachePath,
    List<LyricLine>? lyrics,
  }) {
    return Track(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerTrackId: providerTrackId ?? this.providerTrackId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artists: artists ?? this.artists,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      artworkUri: artworkUri ?? this.artworkUri,
      isrc: isrc ?? this.isrc,
      explicit: explicit ?? this.explicit,
      availabilityState: availabilityState ?? this.availabilityState,
      sourceAttribution: sourceAttribution ?? this.sourceAttribution,
      dateAdded: dateAdded ?? this.dateAdded,
      isLiked: isLiked ?? this.isLiked,
      isCached: isCached ?? this.isCached,
      localCachePath: localCachePath ?? this.localCachePath,
      lyrics: lyrics ?? this.lyrics,
    );
  }
}

typedef Song = Track;
