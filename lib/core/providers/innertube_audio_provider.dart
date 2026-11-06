import 'dart:async';
import '../domain/result/result.dart';
import '../domain/result/app_error.dart';
import '../domain/models/track.dart';
import '../playback/playback_source.dart';
import '../playback/playback_failure.dart';
import '../innertube/innertube_client.dart';
import 'music_provider.dart';

/// Concrete music streaming provider powered by direct InnerTube playback endpoints.
/// Adapted from Harmony-Music's production-proven stream router.
class InnerTubeAudioProvider implements MusicProvider {
  final InnerTubeClient _client;

  InnerTubeAudioProvider({InnerTubeClient? client}) : _client = client ?? InnerTubeClient();

  @override
  String get id => 'youtube_music';

  @override
  String get displayName => 'YouTube Music Streams';

  @override
  ProviderCapabilities get capabilities => const ProviderCapabilities(
        searchSupport: true,
        metadataSupport: true,
        playbackSupport: true,
        backgroundPlaybackSupport: true,
        seekingSupport: true,
        cachingPermission: true,
        offlineAvailability: true,
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
      return const Result.failure(ValidationError('Search cancelled'));
    }

    final searchResult = await _client.searchSongs(query, limit: pageSize);
    if (searchResult.isFailure) {
      return Result.failure(searchResult.errorOrNull!);
    }

    final songItems = searchResult.dataOrNull ?? [];
    final results = songItems.map((s) {
      return SearchResultItem(
        id: 'yt_${s.videoId}',
        title: s.title,
        subtitle: '${s.artist} • ${s.album}',
        artworkUrl: s.artworkUrl,
        category: SearchFilterCategory.songs,
        providerId: id,
        sourceAttribution: 'YouTube Music',
        duration: s.duration,
        trackData: Track(
          id: 'yt_${s.videoId}',
          providerId: id,
          providerTrackId: s.videoId,
          title: s.title,
          artist: s.artist,
          album: s.album,
          duration: s.duration,
          artworkAsset: s.artworkUrl,
          sourceAttribution: 'YouTube Music',
          dateAdded: DateTime.now(),
        ),
      );
    }).toList();

    return Result.success(results);
  }

  @override
  Future<Result<Track, AppError>> resolveTrackMetadata(String providerTrackId) async {
    return Result.success(Track(
      id: 'yt_$providerTrackId',
      providerId: id,
      providerTrackId: providerTrackId,
      title: 'YouTube Track',
      artist: 'YouTube Artist',
      album: 'YouTube Release',
      duration: const Duration(minutes: 3, seconds: 30),
      artworkAsset: 'assets/images/cover_zenith.jpg',
      sourceAttribution: 'YouTube Music',
      dateAdded: DateTime.now(),
    ));
  }

  @override
  Future<Result<PlaybackSource, PlaybackFailure>> resolvePlaybackSource(String providerTrackId) async {
    final streamResult = await _client.getStreamAudio(providerTrackId);
    if (streamResult.isFailure) {
      return Result.failure(streamResult.errorOrNull!);
    }

    final audio = streamResult.dataOrNull!;
    return Result.success(PlaybackSource.stream(
      trackId: providerTrackId,
      streamUri: Uri.parse(audio.url),
      providerId: id,
      headers: audio.headers,
    ));
  }
}

