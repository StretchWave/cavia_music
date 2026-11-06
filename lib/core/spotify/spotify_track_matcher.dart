import '../domain/models/track.dart';
import 'spotify_models.dart';

/// Dedicated Track Matching Service for pairing Spotify metadata items with
/// authorized playable sources in Cavia Music's catalog.
///
/// MATCHING HIERARCHY:
/// 1. Exact ISRC match when available.
/// 2. Exact normalized title and primary artist.
/// 3. Duration comparison.
/// 4. Album and version information.
/// 5. Manual selection for ambiguous matches.
///
/// NOTE: Meaningful version terms (Live, Remix, Acoustic, Instrumental, Remastered, Extended)
/// must NEVER be stripped to prevent false-positive matches to standard studio originals.
class SpotifyTrackMatcher {
  static const List<String> _versionKeywords = [
    'live',
    'remix',
    'acoustic',
    'instrumental',
    'remaster',
    'remastered',
    'extended',
    'radio edit',
    'cover',
    'orchestral',
    'deluxe',
  ];

  /// Match a single [spotifyTrack] against candidate [availableTracks].
  TrackMatchResult matchTrack({
    required SpotifyTrackItem spotifyTrack,
    required List<Track> availableTracks,
  }) {
    if (!spotifyTrack.isPlayable) {
      return TrackMatchResult(
        spotifyTrack: spotifyTrack,
        confidence: MatchConfidence.unavailable,
        matchReason: 'Track is marked unavailable or region-restricted by Spotify',
      );
    }

    if (spotifyTrack.isLocal) {
      return TrackMatchResult(
        spotifyTrack: spotifyTrack,
        confidence: MatchConfidence.unavailable,
        matchReason: 'Local file on user machine cannot be resolved remotely',
      );
    }

    // 1. Exact ISRC Match
    if (spotifyTrack.isrc != null && spotifyTrack.isrc!.isNotEmpty) {
      final isrcMatch = availableTracks.firstWhere(
        (t) => t.isrc != null && t.isrc!.toUpperCase() == spotifyTrack.isrc!.toUpperCase(),
        orElse: () => _emptyTrack(),
      );

      if (isrcMatch.id.isNotEmpty) {
        return TrackMatchResult(
          spotifyTrack: spotifyTrack,
          matchedTrackId: isrcMatch.id,
          matchedTitle: isrcMatch.title,
          matchedArtist: isrcMatch.artist,
          confidence: MatchConfidence.highConfidence,
          matchReason: 'Exact ISRC match (${spotifyTrack.isrc})',
        );
      }
    }

    final spotifyTitleNorm = _normalize(spotifyTrack.name);
    final spotifyArtistNorm = _normalize(spotifyTrack.artist);
    final spotifyVersionTag = _extractVersionTag(spotifyTrack.name);

    final List<TrackMatchResult> candidates = [];

    // 2. Scan available tracks for title and artist matches
    for (final candidate in availableTracks) {
      final candTitleNorm = _normalize(candidate.title);
      final candArtistNorm = _normalize(candidate.artist);
      final candVersionTag = _extractVersionTag(candidate.title);

      // Check if primary artist matches
      final artistMatches = candArtistNorm == spotifyArtistNorm ||
          candidate.artists.any((a) => _normalize(a) == spotifyArtistNorm);

      if (!artistMatches) continue;

      // Version safety check: do not pair Live / Remix / Acoustic with original
      if (spotifyVersionTag != candVersionTag) {
        // Mismatched versions: e.g. Spotify is "Song (Live)" but candidate is standard "Song"
        continue;
      }

      // Title match
      final titleMatches = candTitleNorm == spotifyTitleNorm;

      if (titleMatches) {
        final durationDiff = (candidate.duration - spotifyTrack.duration).abs();

        if (durationDiff.inSeconds <= 5) {
          candidates.add(TrackMatchResult(
            spotifyTrack: spotifyTrack,
            matchedTrackId: candidate.id,
            matchedTitle: candidate.title,
            matchedArtist: candidate.artist,
            confidence: MatchConfidence.highConfidence,
            matchReason: 'Exact title, artist, and duration match (delta ${durationDiff.inSeconds}s)',
          ));
        } else if (durationDiff.inSeconds <= 15) {
          candidates.add(TrackMatchResult(
            spotifyTrack: spotifyTrack,
            matchedTrackId: candidate.id,
            matchedTitle: candidate.title,
            matchedArtist: candidate.artist,
            confidence: MatchConfidence.possibleMatch,
            matchReason: 'Title and artist match with minor duration discrepancy (delta ${durationDiff.inSeconds}s)',
          ));
        } else {
          // Duration discrepancy > 15s indicates an unlabelled edit or different recording
          candidates.add(TrackMatchResult(
            spotifyTrack: spotifyTrack,
            matchedTrackId: candidate.id,
            matchedTitle: candidate.title,
            matchedArtist: candidate.artist,
            confidence: MatchConfidence.ambiguous,
            matchReason: 'Significant duration discrepancy (${durationDiff.inSeconds}s)',
          ));
        }
      }
    }

    if (candidates.isEmpty) {
      return TrackMatchResult(
        spotifyTrack: spotifyTrack,
        confidence: MatchConfidence.unmatched,
        matchReason: 'No matching track found in available sources',
      );
    }

    if (candidates.length == 1) {
      return candidates.first;
    }

    // Multiple candidates: check album match to disambiguate
    final albumMatch = candidates.firstWhere(
      (c) => _normalize(c.spotifyTrack.album) == _normalize(availableTracks.firstWhere((t) => t.id == c.matchedTrackId).album),
      orElse: () => candidates.first,
    );

    return TrackMatchResult(
      spotifyTrack: spotifyTrack,
      matchedTrackId: albumMatch.matchedTrackId,
      matchedTitle: albumMatch.matchedTitle,
      matchedArtist: albumMatch.matchedArtist,
      confidence: MatchConfidence.ambiguous,
      matchReason: 'Multiple matching candidates found',
    );
  }

  /// Match a batch of Spotify tracks against available sources.
  List<TrackMatchResult> matchBatch({
    required List<SpotifyTrackItem> spotifyTracks,
    required List<Track> availableTracks,
  }) {
    return spotifyTracks.map((st) => matchTrack(spotifyTrack: st, availableTracks: availableTracks)).toList();
  }

  static String _normalize(String s) {
    return s
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static String? _extractVersionTag(String title) {
    final lower = title.toLowerCase();
    for (final kw in _versionKeywords) {
      if (lower.contains(kw)) {
        return kw;
      }
    }
    return null;
  }

  static Track _emptyTrack() => Track(
        id: '',
        providerId: '',
        providerTrackId: '',
        title: '',
        artist: '',
        album: '',
        duration: Duration.zero,
        artworkAsset: '',
        dateAdded: DateTime.fromMillisecondsSinceEpoch(0),
      );
}

