import '../domain/result/result.dart';
import '../domain/result/app_error.dart';
import '../domain/models/track.dart';
import '../playback/playback_source.dart';
import '../playback/playback_failure.dart';
import 'music_provider.dart';

/// Provider that models YouTube Music's *official* catalog surface, which
/// Cavia cannot legally search without an API key. Search therefore reports
/// honest unavailability instead of placeholder results; playback routes to
/// the official YouTube player (never a scraped audio stream).
class YouTubeMusicProvider implements MusicProvider {
  final String? apiKey;

  YouTubeMusicProvider({this.apiKey});

  @override
  String get id => 'youtube';

  @override
  String get displayName => 'YouTube Music (official player)';

  @override
  ProviderCapabilities get capabilities => const ProviderCapabilities(
        searchSupport: true,
        metadataSupport: true,
        playbackSupport: false, // Direct audio-only playback is unsupported by policy
        backgroundPlaybackSupport: false, // Custom background audio is forbidden by YouTube TOS
        seekingSupport: true, // Official player supports seeking
        cachingPermission: false, // Strictly forbidden to cache YouTube streams
        offlineAvailability: false,
        authenticationRequired: false,
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

    return const Result.failure(ValidationError(
      'YouTube Music catalog search is unavailable in this build. '
      'Streams are resolved through the YouTube Music client instead.',
    ));
  }

  @override
  Future<Result<Track, AppError>> resolveTrackMetadata(String providerTrackId) async {
    return const Result.failure(NotFoundError(
      'YouTube Music metadata lookup is unavailable in this build without '
      'an official API key.',
    ));
  }

  @override
  Future<Result<PlaybackSource, PlaybackFailure>> resolvePlaybackSource(String providerTrackId) async {
    // Official policy: Cavia's custom audio-only engine cannot stream YouTube
    // content directly; playback hands off to the official player.
    final officialUrl = Uri.parse('https://www.youtube.com/watch?v=$providerTrackId');
    return Result.success(PlaybackSource.officialPlayerOnly(
      trackId: providerTrackId,
      providerId: id,
      officialUrl: officialUrl,
    ));
  }
}
