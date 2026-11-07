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
  final String providerId; // 'local', 'youtube_music', 'spotify_ref', ...
  final String providerTrackId;
  final String title;
  final String artist; // primary/"display" artist
  final List<String> artists; // full artist list (joined with ", " mirrors [artist])
  final String album;
  final String? albumArtist;
  final Duration duration;
  final String artworkUri;
  String get artworkAsset => artworkUri;
  final String? isrc;
  final bool explicit;
  final int? trackNumber;
  final int? discNumber;
  final int? releaseYear;
  final String? genre;
  /// Absolute path on disk (or platform URI such as `file:///…`,
  /// `content://…`) for locally available audio. Null for metadata-only
  /// tracks that exist purely as remote references.
  final String? filePath;
  final String? fileFormat;
  final int? fileSizeBytes;
  final TrackAvailability availabilityState;
  final String? sourceAttribution;
  final DateTime dateAdded;
  final bool isLiked;
  final bool isCached;
  final String? localCachePath;
  final List<LyricLine> lyrics;
  final int playCount;
  final DateTime? lastPlayedAt;

  bool get isLocal => providerId == 'local';

  /// Joining helper used by the UI: "Artist A, Artist B".
  String get artistsText => artists.isEmpty ? artist : artists.join(', ');

  Track({
    required this.id,
    this.providerId = 'local',
    this.providerTrackId = '',
    required this.title,
    required this.artist,
    this.artists = const [],
    this.album = '',
    this.albumArtist,
    required this.duration,
    String? artworkUri,
    String? artworkAsset,
    this.isrc,
    this.explicit = false,
    this.trackNumber,
    this.discNumber,
    this.releaseYear,
    this.genre,
    this.filePath,
    this.fileFormat,
    this.fileSizeBytes,
    this.availabilityState = TrackAvailability.available,
    this.sourceAttribution,
    DateTime? dateAdded,
    this.isLiked = false,
    this.isCached = false,
    this.localCachePath,
    this.lyrics = const [],
    this.playCount = 0,
    this.lastPlayedAt,
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
    Object? albumArtist = _sentinel,
    Duration? duration,
    String? artworkUri,
    String? isrc,
    bool? explicit,
    Object? trackNumber = _sentinel,
    Object? discNumber = _sentinel,
    Object? releaseYear = _sentinel,
    Object? genre = _sentinel,
    Object? filePath = _sentinel,
    Object? fileFormat = _sentinel,
    Object? fileSizeBytes = _sentinel,
    TrackAvailability? availabilityState,
    String? sourceAttribution,
    DateTime? dateAdded,
    bool? isLiked,
    bool? isCached,
    String? localCachePath,
    List<LyricLine>? lyrics,
    int? playCount,
    Object? lastPlayedAt = _sentinel,
  }) {
    return Track(
      id: id ?? this.id,
      providerId: providerId ?? this.providerId,
      providerTrackId: providerTrackId ?? this.providerTrackId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artists: artists ?? this.artists,
      album: album ?? this.album,
      albumArtist: albumArtist == _sentinel ? this.albumArtist : albumArtist as String?,
      duration: duration ?? this.duration,
      artworkUri: artworkUri ?? this.artworkUri,
      isrc: isrc ?? this.isrc,
      explicit: explicit ?? this.explicit,
      trackNumber: trackNumber == _sentinel ? this.trackNumber : trackNumber as int?,
      discNumber: discNumber == _sentinel ? this.discNumber : discNumber as int?,
      releaseYear: releaseYear == _sentinel ? this.releaseYear : releaseYear as int?,
      genre: genre == _sentinel ? this.genre : genre as String?,
      filePath: filePath == _sentinel ? this.filePath : filePath as String?,
      fileFormat: fileFormat == _sentinel ? this.fileFormat : fileFormat as String?,
      fileSizeBytes:
          fileSizeBytes == _sentinel ? this.fileSizeBytes : fileSizeBytes as int?,
      availabilityState: availabilityState ?? this.availabilityState,
      sourceAttribution: sourceAttribution ?? this.sourceAttribution,
      dateAdded: dateAdded ?? this.dateAdded,
      isLiked: isLiked ?? this.isLiked,
      isCached: isCached ?? this.isCached,
      localCachePath: localCachePath ?? this.localCachePath,
      lyrics: lyrics ?? this.lyrics,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt == _sentinel ? this.lastPlayedAt : lastPlayedAt as DateTime?,
    );
  }

  static const Object _sentinel = Object();
}

typedef Song = Track;
