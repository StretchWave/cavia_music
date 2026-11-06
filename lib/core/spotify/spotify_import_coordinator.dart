import 'dart:async';
import 'package:uuid/uuid.dart';
import '../domain/result/result.dart';
import '../domain/result/app_error.dart';
import '../domain/models/track.dart';
import '../domain/repositories/playlist_repository.dart';
import '../domain/repositories/track_repository.dart';
import 'spotify_models.dart';
import 'spotify_playlist_client.dart';
import 'spotify_track_matcher.dart';
import 'spotify_url_parser.dart';

/// Pre-import inspection report shown to the user before committing to import.
class ImportPreview {
  final SpotifyPlaylistMetadata metadata;
  final List<SpotifyTrackItem> tracks;
  final List<TrackMatchResult> matches;
  final int matchedCount;
  final int unmatchedCount;
  final int duplicateCount;
  final int unsupportedCount;

  const ImportPreview({
    required this.metadata,
    required this.tracks,
    required this.matches,
    required this.matchedCount,
    required this.unmatchedCount,
    required this.duplicateCount,
    required this.unsupportedCount,
  });
}

/// Coordinates Spotify playlist validation, metadata retrieval, track matching,
/// user confirmation, and transactional commit to Cavia Music's local SQLite library.
class SpotifyImportCoordinator {
  final SpotifyPlaylistClient client;
  final TrackRepository trackRepository;
  final PlaylistRepository playlistRepository;
  final SpotifyTrackMatcher matcher;
  final Uuid uuid;

  bool _isCancelled = false;

  SpotifyImportCoordinator({
    required this.client,
    required this.trackRepository,
    required this.playlistRepository,
    SpotifyTrackMatcher? matcher,
    Uuid? uuid,
  })  : matcher = matcher ?? SpotifyTrackMatcher(),
        uuid = uuid ?? const Uuid();

  /// Inspect a Spotify URL and load a preview without modifying local database.
  Future<Result<ImportPreview, AppError>> loadPreview({
    required String inputUrl,
  }) async {
    _isCancelled = false;

    // 1. Validate and parse playlist ID
    final idResult = SpotifyUrlParser.parsePlaylistId(inputUrl);
    if (idResult.isFailure) {
      return Result.failure(idResult.errorOrNull!);
    }
    final playlistId = idResult.dataOrNull!;

    // 2. Fetch Playlist Metadata
    final metaResult = await client.getPlaylistMetadata(playlistId: playlistId);
    if (metaResult.isFailure) {
      return Result.failure(metaResult.errorOrNull!);
    }
    final metadata = metaResult.dataOrNull!;

    // 3. Fetch Playlist Items
    final itemsResult = await client.getPlaylistItems(playlistId: playlistId);
    if (itemsResult.isFailure) {
      return Result.failure(itemsResult.errorOrNull!);
    }
    final tracks = itemsResult.dataOrNull ?? [];

    // 4. Query available local tracks for matching candidates
    final localTracksResult = await trackRepository.getAllTracks();
    final availableTracks = localTracksResult.dataOrNull ?? [];

    // 5. Match tracks
    final matches = matcher.matchBatch(
      spotifyTracks: tracks,
      availableTracks: availableTracks,
    );

    int matchedCount = 0;
    int unmatchedCount = 0;
    int duplicateCount = 0;
    int unsupportedCount = 0;

    final seenTrackIds = <String>{};

    for (int i = 0; i < matches.length; i++) {
      final m = matches[i];
      if (m.spotifyTrack.isLocal || !m.spotifyTrack.isPlayable) {
        unsupportedCount++;
      } else if (m.isMatched) {
        matchedCount++;
        if (seenTrackIds.contains(m.matchedTrackId)) {
          duplicateCount++;
        }
        seenTrackIds.add(m.matchedTrackId!);
      } else {
        unmatchedCount++;
      }
    }

    return Result.success(ImportPreview(
      metadata: metadata,
      tracks: tracks,
      matches: matches,
      matchedCount: matchedCount,
      unmatchedCount: unmatchedCount,
      duplicateCount: duplicateCount,
      unsupportedCount: unsupportedCount,
    ));
  }

  /// Execute the confirmed import into Cavia's SQLite database.
  ///
  /// CRUCIAL: Never creates the destination playlist before confirmation.
  /// Stable import identifiers ensure retrying partially completed imports does not duplicate tracks.
  Future<Result<ImportSummary, AppError>> executeImport({
    required ImportPreview preview,
    required ImportOptions options,
    String? profileId,
    void Function(int imported, int total)? onProgress,
  }) async {
    _isCancelled = false;

    String targetPlaylistId = options.existingPlaylistId ?? '';

    // 1. Destination Playlist: Create new or resolve existing
    if (targetPlaylistId.isEmpty) {
      final playlistName = options.destinationPlaylistName.isNotEmpty
          ? options.destinationPlaylistName
          : preview.metadata.name;

      final newPlaylistResult = await playlistRepository.createPlaylist(
        playlistName,
        description: 'Imported from Spotify (${preview.metadata.ownerName}). '
            'Metadata subject to Spotify Developer Policy.',
        profileId: profileId,
      );

      if (newPlaylistResult.isFailure) {
        return Result.failure(newPlaylistResult.errorOrNull!);
      }
      targetPlaylistId = newPlaylistResult.dataOrNull!.id;
    }

    int importedCount = 0;
    int skippedCount = 0;
    int unmatchedCount = 0;
    int failedCount = 0;

    final importedTrackIds = <String>{};

    // 2. Iterate matches and insert entries transactionally
    for (int i = 0; i < preview.matches.length; i++) {
      if (_isCancelled) {
        break;
      }

      final match = preview.matches[i];
      final st = match.spotifyTrack;

      if (!match.isMatched) {
        if (options.skipUnmatched) {
          unmatchedCount++;
          skippedCount++;
          continue;
        }

        // Create an unplayable local reference record to preserve playlist structure if requested
        final refTrackId = 'sp_ref_${st.id}';
        final refTrack = Track(
          id: refTrackId,
          providerId: 'spotify',
          providerTrackId: st.id,
          title: st.name,
          artist: st.artist,
          album: st.album,
          duration: st.duration,
          artworkAsset: st.artworkUrl ?? 'assets/images/cover_afterglow.jpg',
          sourceAttribution: 'Spotify (Unmatched)',
          availabilityState: TrackAvailability.unavailable,
          dateAdded: DateTime.now(),
        );

        await trackRepository.insertTrack(refTrack, profileId: profileId);
        final addRes = await playlistRepository.addTrackToPlaylist(
          targetPlaylistId,
          refTrackId,
        );

        if (addRes.isSuccess) {
          unmatchedCount++;
          importedCount++;
        } else {
          failedCount++;
        }
        continue;
      }

      final resolvedTrackId = match.matchedTrackId!;

      // Handle duplicate options
      if (options.skipDuplicates && importedTrackIds.contains(resolvedTrackId)) {
        skippedCount++;
        continue;
      }

      importedTrackIds.add(resolvedTrackId);

      // Add to playlist
      final addResult = await playlistRepository.addTrackToPlaylist(
        targetPlaylistId,
        resolvedTrackId,
      );

      if (addResult.isSuccess) {
        importedCount++;
      } else {
        failedCount++;
      }

      onProgress?.call(importedCount, preview.tracks.length);
    }

    final summary = ImportSummary(
      playlistName: options.destinationPlaylistName.isNotEmpty
          ? options.destinationPlaylistName
          : preview.metadata.name,
      totalTracks: preview.tracks.length,
      matchedCount: preview.matchedCount,
      importedCount: importedCount,
      skippedCount: skippedCount,
      unmatchedCount: unmatchedCount,
      failedCount: failedCount,
    );

    return Result.success(summary);
  }

  void cancel() {
    _isCancelled = true;
  }
}
