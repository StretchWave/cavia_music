import 'dart:async';
import '../domain/result/result.dart';
import '../domain/result/app_error.dart';
import '../domain/models/track.dart';
import '../domain/repositories/track_repository.dart';
import '../playback/playback_source.dart';
import '../playback/playback_failure.dart';
import 'music_provider.dart';

/// Provider for bundled and local device tracks.
class LocalAudioProvider implements MusicProvider {
  final TrackRepository trackRepository;

  LocalAudioProvider({required this.trackRepository});

  @override
  String get id => 'local';

  @override
  String get displayName => 'Local Library';

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
      return const Result.failure(ValidationError('Search operation cancelled'));
    }

    final tracksResult = await trackRepository.getAllTracks();
    if (tracksResult.isFailure) {
      return Result.failure(tracksResult.errorOrNull!);
    }

    final lower = query.trim().toLowerCase();
    final allTracks = tracksResult.dataOrNull ?? [];
    final filtered = allTracks.where((t) {
      if (lower.isEmpty) return true;
      final matchTitle = t.title.toLowerCase().contains(lower);
      final matchArtist = t.artist.toLowerCase().contains(lower);
      final matchAlbum = t.album.toLowerCase().contains(lower);
      return matchTitle || matchArtist || matchAlbum;
    }).toList();

    // Map to normalized SearchResultItem
    final items = filtered.map((t) {
      return SearchResultItem(
        id: t.id,
        title: t.title,
        subtitle: '${t.artist} • ${t.album}',
        artworkUrl: t.artworkAsset,
        category: SearchFilterCategory.songs,
        providerId: id,
        sourceAttribution: 'Local Device',
        duration: t.duration,
        trackData: t,
      );
    }).toList();

    return Result.success(items);
  }

  @override
  Future<Result<Track, AppError>> resolveTrackMetadata(String providerTrackId) async {
    final trackResult = await trackRepository.getTrackById(providerTrackId);
    if (trackResult.isSuccess && trackResult.dataOrNull != null) {
      return Result.success(trackResult.dataOrNull!);
    }
    return Result.failure(NotFoundError("Local track '$providerTrackId' not found"));
  }

  @override
  Future<Result<PlaybackSource, PlaybackFailure>> resolvePlaybackSource(String providerTrackId) async {
    final trackResult = await trackRepository.getTrackById(providerTrackId);
    if (trackResult.isFailure || trackResult.dataOrNull == null) {
      return Result.failure(PlaybackFailure(
        type: PlaybackFailureType.trackUnavailable,
        internalMessage: "Local track '$providerTrackId' not found in database",
        providerId: id,
        trackId: providerTrackId,
      ));
    }

    final track = trackResult.dataOrNull!;
    final path = track.artworkAsset;
    final lower = path.toLowerCase();
    const audioExtensions = ['.mp3', '.m4a', '.wav', '.flac', '.ogg', '.aac', '.opus', '.webm'];
    final isAudioFile = audioExtensions.any((ext) => lower.endsWith(ext));

    if (!isAudioFile) {
      return Result.failure(PlaybackFailure(
        type: PlaybackFailureType.sourceUnavailable,
        internalMessage: "Local track '$providerTrackId' does not have an audio file on disk",
        providerId: id,
        trackId: providerTrackId,
      ));
    }

    if (path.startsWith('assets/')) {
      return Result.success(PlaybackSource.asset(
        trackId: track.id,
        assetPath: path,
        providerId: id,
      ));
    } else {
      return Result.success(PlaybackSource.file(
        trackId: track.id,
        fileUri: Uri.file(path),
        providerId: id,
      ));
    }
  }
}
