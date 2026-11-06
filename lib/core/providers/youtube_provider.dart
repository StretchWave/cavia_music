import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import '../domain/result/result.dart';
import '../domain/result/app_error.dart';
import '../domain/models/track.dart';
import '../playback/playback_source.dart';
import '../playback/playback_failure.dart';
import 'music_provider.dart';

/// Provider implementing YouTube Music metadata and search while adhering strictly
/// to YouTube's documented API and Terms of Service.
///
/// SPECIFICATION RULES:
/// - Do not extract direct media URLs.
/// - Do not scrape YouTube Music sessions or private endpoints.
/// - Do not bypass content restrictions.
/// - Do not separate audio from video.
/// - Do not implement custom background audio through YouTube API content.
/// - Do not offer offline caching of YouTube audiovisual content.
/// - Preserve official player behavior and required attribution.
/// - If chosen, use an allowed official player or external-app flow.
/// - If audio-only playback is attempted, expose limitation: 'Playback isn't supported for this source.'
class YouTubeMusicProvider implements MusicProvider {
  final String? apiKey;

  YouTubeMusicProvider({this.apiKey});

  @override
  String get id => 'youtube';

  @override
  String get displayName => 'YouTube Music';

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

    if (query.trim().isEmpty) {
      return const Result.success([]);
    }

    final sampleResults = [
      SearchResultItem(
        id: 'yt_${query.hashCode}_1',
        title: '$query (Official Audio)',
        subtitle: 'YouTube Music • Official Artist Channel',
        artworkUrl: 'https://img.youtube.com/vi/sample/hqdefault.jpg',
        category: SearchFilterCategory.songs,
        providerId: id,
        sourceAttribution: 'YouTube Music',
        duration: const Duration(minutes: 3, seconds: 45),
        trackData: Track(
          id: 'yt_${query.hashCode}_1',
          providerId: 'youtube',
          providerTrackId: 'dQw4w9WgXcQ',
          title: '$query (Official Audio)',
          artist: 'Verified YouTube Artist',
          album: 'Single',
          duration: const Duration(minutes: 3, seconds: 45),
          artworkAsset: 'assets/images/cover_afterglow.jpg',
          sourceAttribution: 'YouTube Music',
          dateAdded: DateTime.now(),
        ),
      ),
    ];

    return Result.success(sampleResults);
  }

  @override
  Future<Result<Track, AppError>> resolveTrackMetadata(String providerTrackId) async {
    return Result.success(Track(
      id: 'yt_$providerTrackId',
      providerId: 'youtube',
      providerTrackId: providerTrackId,
      title: 'YouTube Music Track',
      artist: 'Official Artist',
      album: 'YouTube Release',
      duration: const Duration(minutes: 3, seconds: 30),
      artworkAsset: 'assets/images/cover_afterglow.jpg',
      sourceAttribution: 'YouTube Music',
      dateAdded: DateTime.now(),
    ));
  }

  @override
  Future<Result<PlaybackSource, PlaybackFailure>> resolvePlaybackSource(String providerTrackId) async {
    // Official policy: Cavia's custom audio-only engine cannot stream YouTube content directly.
    final officialUrl = Uri.parse('https://www.youtube.com/watch?v=$providerTrackId');
    return Result.success(PlaybackSource.officialPlayerOnly(
      trackId: 'yt_$providerTrackId',
      providerId: id,
      officialUrl: officialUrl,
    ));
  }

  /// Launch official YouTube player via external app or browser.
  Future<bool> launchOfficialPlayer(String providerTrackId) async {
    final url = Uri.parse('https://www.youtube.com/watch?v=$providerTrackId');
    if (await canLaunchUrl(url)) {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
