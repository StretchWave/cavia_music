import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/result/result.dart';
import '../domain/result/app_error.dart';
import 'spotify_models.dart';
import 'spotify_oauth_service.dart';

/// Official Spotify Web API Client for retrieving playlist metadata and items.
///
/// SPECIFICATION RULES:
/// - Use current `/playlists/{id}/items` endpoint.
/// - Never scrape HTML or use undocumented endpoints.
/// - Handle rate limiting (429 Retry-After).
/// - Safe pagination for large playlists.
/// - Filter out null tracks, local files, and podcast episodes.
class SpotifyPlaylistClient {
  final SpotifyOAuthService oAuthService;
  final http.Client httpClient;

  SpotifyPlaylistClient({
    required this.oAuthService,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  /// Retrieve playlist metadata.
  Future<Result<SpotifyPlaylistMetadata, AppError>> getPlaylistMetadata({
    required String playlistId,
  }) async {
    final session = await oAuthService.getSession();
    final token = session?.accessToken;

    final uri = Uri.https(
      'api.spotify.com',
      '/v1/playlists/$playlistId',
      {'fields': 'id,name,description,images,owner,tracks.total,collaborative,public'},
    );

    final headers = {
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await httpClient.get(uri, headers: headers);

      if (response.statusCode == 429) {
        final retrySec = int.tryParse(response.headers['retry-after'] ?? '5') ?? 5;
        return Result.failure(StorageError(
          userMessage: 'Rate limited by Spotify. Please retry in $retrySec seconds.',
          details: 'HTTP 429 Retry-After: $retrySec',
        ));
      }

      if (response.statusCode == 401) {
        return const Result.failure(ValidationError('Reconnect Spotify to continue.'));
      }

      if (response.statusCode == 403 || response.statusCode == 404) {
        return const Result.failure(NotFoundError(
          "Spotify didn't provide track details for this playlist.",
          details: 'Playlist may be private, deleted, or restricted in your region',
        ));
      }

      if (response.statusCode != 200) {
        return Result.failure(DatabaseError(
          userMessage: "Couldn't load Spotify playlist information.",
          details: 'HTTP ${response.statusCode}: ${response.body}',
        ));
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final metadata = SpotifyPlaylistMetadata.fromJson(json);
      return Result.success(metadata);
    } catch (e, st) {
      return Result.failure(StorageError(
        userMessage: 'Connection lost.',
        details: e.toString(),
        cause: st,
      ));
    }
  }

  /// Retrieve all playlist items using the official `/v1/playlists/{id}/items` endpoint with pagination.
  Future<Result<List<SpotifyTrackItem>, AppError>> getPlaylistItems({
    required String playlistId,
    int maxTracks = 500,
    void Function(int fetched, int total)? onProgress,
  }) async {
    final session = await oAuthService.getSession();
    final token = session?.accessToken;

    final List<SpotifyTrackItem> allTracks = [];
    int offset = 0;
    const int limit = 100;
    int total = -1;

    final headers = {
      if (token != null) 'Authorization': 'Bearer $token',
    };

    while (total == -1 || offset < total) {
      final uri = Uri.https(
        'api.spotify.com',
        '/v1/playlists/$playlistId/items',
        {
          'limit': limit.toString(),
          'offset': offset.toString(),
          'fields': 'items(track(id,name,artists(name),album(name,images),duration_ms,external_ids,is_playable,is_local,explicit)),total,next',
        },
      );

      try {
        final response = await httpClient.get(uri, headers: headers);

        if (response.statusCode == 429) {
          final retrySec = int.tryParse(response.headers['retry-after'] ?? '3') ?? 3;
          await Future.delayed(Duration(seconds: retrySec));
          continue; // retry page
        }

        if (response.statusCode == 401) {
          return const Result.failure(ValidationError('Reconnect Spotify to continue.'));
        }

        if (response.statusCode == 403 || response.statusCode == 404) {
          return const Result.failure(NotFoundError(
            "Spotify didn't provide track details for this playlist.",
            details: 'Access forbidden or playlist not found',
          ));
        }

        if (response.statusCode != 200) {
          return Result.failure(DatabaseError(
            userMessage: "Couldn't load tracks from Spotify.",
            details: 'HTTP ${response.statusCode}',
          ));
        }

        final json = jsonDecode(response.body) as Map<String, dynamic>;
        total = json['total'] as int? ?? 0;
        final rawItems = json['items'] as List? ?? [];

        for (final item in rawItems) {
          if (item is Map<String, dynamic>) {
            final trackObj = item['track'] as Map<String, dynamic>?;
            if (trackObj == null) {
              // Deleted / empty item
              continue;
            }

            final track = SpotifyTrackItem.fromJson(trackObj);
            // Filter out empty IDs or non-playable podcasts/shows
            if (track.name.isNotEmpty) {
              allTracks.add(track);
            }
          }
        }

        onProgress?.call(allTracks.length, total);

        if (allTracks.length >= maxTracks || json['next'] == null) {
          break;
        }

        offset += limit;
      } catch (e, st) {
        return Result.failure(StorageError(
          userMessage: 'Connection lost.',
          details: e.toString(),
          cause: st,
        ));
      }
    }

    return Result.success(allTracks);
  }
}

