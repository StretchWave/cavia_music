import 'dart:async';
import '../domain/result/result.dart';
import '../domain/result/app_error.dart';
import '../domain/models/track.dart';
import '../playback/playback_source.dart';
import '../playback/playback_failure.dart';
import 'music_provider.dart';

/// Provider for Spotify metadata search and playlist migration.
class SpotifyMetadataProvider implements MusicProvider {
  @override
  String get id => 'spotify';

  @override
  String get displayName => 'Spotify';

  @override
  ProviderCapabilities get capabilities => const ProviderCapabilities(
        searchSupport: true,
        metadataSupport: true,
        playbackSupport: false,
        backgroundPlaybackSupport: false,
        seekingSupport: false,
        cachingPermission: false,
        offlineAvailability: false,
        authenticationRequired: true,
      );

  @override
  bool get isOperational => true;

  @override
  Future<Result<List<SearchResultItem>, AppError>> search({
    required String query,
    SearchFilterCategory category = SearchFilterCategory.all,
    int page = 1,
    int pageSize = 20,
    CancellationToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled == true) {
      return const Result.failure(ValidationError('Search operation cancelled'));
    }

    if (query.trim().isEmpty) return const Result.success([]);

    return Result.success([
      SearchResultItem(
        id: 'sp_${query.hashCode}',
        title: query,
        subtitle: 'Spotify Metadata • Importable',
        category: SearchFilterCategory.songs,
        providerId: id,
        sourceAttribution: 'Spotify',
        duration: const Duration(minutes: 3, seconds: 20),
        trackData: Track(
          id: 'sp_${query.hashCode}',
          providerId: 'spotify',
          providerTrackId: 'spotify_track_id',
          title: query,
          artist: 'Spotify Artist',
          album: 'Spotify Album',
          duration: const Duration(minutes: 3, seconds: 20),
          artworkAsset: 'assets/images/cover_afterglow.jpg',
          sourceAttribution: 'Spotify',
          dateAdded: DateTime.now(),
        ),
      ),
    ]);
  }

  @override
  Future<Result<Track, AppError>> resolveTrackMetadata(String providerTrackId) async {
    return Result.success(Track(
      id: 'sp_$providerTrackId',
      providerId: 'spotify',
      providerTrackId: providerTrackId,
      title: 'Imported Spotify Track',
      artist: 'Spotify Artist',
      album: 'Spotify Album',
      duration: const Duration(minutes: 3, seconds: 20),
      artworkAsset: 'assets/images/cover_afterglow.jpg',
      sourceAttribution: 'Spotify',
      dateAdded: DateTime.now(),
    ));
  }

  @override
  Future<Result<PlaybackSource, PlaybackFailure>> resolvePlaybackSource(String providerTrackId) async {
    return Result.failure(PlaybackFailure(
      type: PlaybackFailureType.playbackUnsupported,
      internalMessage: 'Spotify does not provide direct audio streaming in Cavia Music',
      providerId: id,
      trackId: providerTrackId,
    ));
  }
}
