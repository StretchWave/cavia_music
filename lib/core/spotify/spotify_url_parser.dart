import '../domain/result/result.dart';
import '../domain/result/app_error.dart';

/// Validates, parses, and extracts clean identifiers from Spotify playlist inputs.
class SpotifyUrlParser {
  // Regex pattern matching base62 Spotify identifiers (22 alphanumeric chars)
  static final RegExp _idPattern = RegExp(r'^[A-Za-z0-9]{22}$');

  /// Parse and validate user input, extracting the clean Spotify Playlist ID.
  /// Rejects albums, artists, tracks, and podcasts with explicit, friendly messages.
  static Result<String, ValidationError> parsePlaylistId(String input) {
    final trimmed = input.trim();

    if (trimmed.isEmpty) {
      return const Result.failure(ValidationError('Please enter a Spotify playlist link or URI'));
    }

    // 1. Check for Spotify URI format: spotify:playlist:xxxx or spotify:album:xxxx
    if (trimmed.startsWith('spotify:')) {
      final parts = trimmed.split(':');
      if (parts.length < 3) {
        return const Result.failure(ValidationError('Invalid Spotify URI format'));
      }

      final type = parts[1].toLowerCase();
      final id = parts[2];

      if (type == 'playlist') {
        if (_idPattern.hasMatch(id)) {
          return Result.success(id);
        }
        return const Result.failure(ValidationError('Invalid Spotify playlist identifier'));
      } else if (type == 'album') {
        return const Result.failure(ValidationError(
          'This is an album link. Cavia playlist import only supports playlists.',
        ));
      } else if (type == 'artist') {
        return const Result.failure(ValidationError(
          'This is an artist link. Cavia playlist import only supports playlists.',
        ));
      } else if (type == 'track') {
        return const Result.failure(ValidationError(
          'This is a track link. Cavia playlist import only supports playlists.',
        ));
      } else if (type == 'episode' || type == 'show') {
        return const Result.failure(ValidationError('Podcasts are not supported.'));
      } else {
        return Result.failure(ValidationError('Unsupported Spotify content type: $type'));
      }
    }

    // 2. Parse HTTP / HTTPS URLs
    Uri? uri;
    try {
      uri = Uri.parse(trimmed);
    } catch (_) {
      return const Result.failure(ValidationError('Malformed URL. Please check the link.'));
    }

    if (uri.host.isEmpty || (!uri.host.contains('spotify.com') && !uri.host.contains('spotify.link'))) {
      return const Result.failure(ValidationError('Not a valid Spotify link.'));
    }

    // Normalize path segments (handles intl prefixes like /intl-ja/playlist/{id})
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();

    int playlistIdx = -1;
    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i].toLowerCase();
      if (seg == 'playlist') {
        playlistIdx = i;
        break;
      } else if (seg == 'album') {
        return const Result.failure(ValidationError(
          'This is an album link. Cavia playlist import only supports playlists.',
        ));
      } else if (seg == 'artist') {
        return const Result.failure(ValidationError(
          'This is an artist link. Cavia playlist import only supports playlists.',
        ));
      } else if (seg == 'track') {
        return const Result.failure(ValidationError(
          'This is a track link. Cavia playlist import only supports playlists.',
        ));
      } else if (seg == 'episode' || seg == 'show') {
        return const Result.failure(ValidationError('Podcasts are not supported.'));
      }
    }

    if (playlistIdx != -1 && playlistIdx + 1 < segments.length) {
      final rawId = segments[playlistIdx + 1];
      // Strip any lingering trailing query punctuation
      final cleanId = rawId.split('?').first.split('&').first;
      if (_idPattern.hasMatch(cleanId)) {
        return Result.success(cleanId);
      }
      return const Result.failure(ValidationError('Invalid Spotify playlist identifier'));
    }

    return const Result.failure(ValidationError(
      'Could not find a playlist in this link. Please provide a playlist link.',
    ));
  }
}

