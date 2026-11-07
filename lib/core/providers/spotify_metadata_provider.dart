import '../config/cavia_config.dart';
import '../domain/result/result.dart';
import '../domain/result/app_error.dart';
import '../domain/models/track.dart';
import '../playback/playback_source.dart';
import '../playback/playback_failure.dart';
import 'music_provider.dart';

/// Provider for Spotify catalog metadata. Spotify only exposes this surface
/// through authenticated developer credentials, so without a configured
/// client id the provider honestly reports itself as not operational and its
/// search/metadata calls fail with an explanation — no placeholder data.
class SpotifyMetadataProvider implements MusicProvider {
  static const String _notConfiguredMessage =
      'Spotify metadata search is not configured on this build. '
      'Provide CAVIA_SPOTIFY_CLIENT_ID to enable it.';

  @override
  String get id => 'spotify';

  @override
  String get displayName => 'Spotify (metadata only)';

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
  bool get isOperational => CaviaConfig.spotifyConfigured;

  @override
  Future<Result<List<SearchResultItem>, AppError>> search({
    required String query,
    SearchFilterCategory category = SearchFilterCategory.all,
    int page = 1,
    int pageSize = 20,
    CancellationToken? cancelToken,
  }) async {
    if (cancelToken?.isCancelled == true) {
      return const Result.failure(ValidationError('Search cancelled'));
    }

    return const Result.failure(ValidationError(_notConfiguredMessage));
  }

  @override
  Future<Result<Track, AppError>> resolveTrackMetadata(String providerTrackId) async {
    return const Result.failure(NotFoundError(_notConfiguredMessage));
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
