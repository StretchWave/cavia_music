import '../models/playlist.dart';
import '../models/playlist_entry.dart';
import '../result/result.dart';
import '../result/app_error.dart';

abstract class PlaylistRepository {
  Stream<List<Playlist>> watchPlaylists({String? profileId});
  Future<Result<List<Playlist>, AppError>> getAllPlaylists({String? profileId});
  Future<Result<Playlist, AppError>> getPlaylistById(String id, {String? profileId});
  Stream<List<PlaylistEntry>> watchPlaylistEntries(String playlistId, {String? profileId});
  Future<Result<List<PlaylistEntry>, AppError>> getPlaylistEntries(String playlistId, {String? profileId});
  Future<Result<Playlist, AppError>> createPlaylist(
    String name, {
    String description = '',
    List<String>? initialTrackIds,
    String? profileId,
    String? sourceProvider,
    String? sourcePlaylistId,
  });
  Future<Result<void, AppError>> editPlaylist(
    String playlistId, {
    String? name,
    String? description,
    String? artworkUri,
  });
  Future<Result<void, AppError>> deletePlaylist(String playlistId);
  Future<Result<PlaylistEntry, AppError>> addTrackToPlaylist(
    String playlistId,
    String trackId, {
    bool allowDuplicates = true,
  });
  Future<Result<void, AppError>> removeTrackFromPlaylist(
    String playlistId,
    String entryId, {
    bool removeByTrackId = false,
  });
  Future<Result<void, AppError>> reorderPlaylistEntries(
    String playlistId,
    int oldPosition,
    int newPosition,
  );
}
