import '../models/album.dart';
import '../models/artist.dart';
import '../models/track.dart';
import '../result/result.dart';
import '../result/app_error.dart';

abstract class TrackRepository {
  // ---- Track queries -------------------------------------------------------
  Future<Result<List<Track>, AppError>> getAllTracks({String? profileId});
  Stream<List<Track>> watchTracks({String? profileId});
  Stream<List<Track>> watchLikedTracks({String? profileId});
  Future<Result<Track, AppError>> getTrackById(String id, {String? profileId});
  Future<Result<List<Track>, AppError>> getRecentlyPlayed({
    int limit = 12,
    String? profileId,
  });
  Future<Result<List<Track>, AppError>> searchTracks(String query, {String? profileId});

  // ---- Likes ---------------------------------------------------------------
  Future<Result<bool, AppError>> isTrackLiked(String trackId, {String? profileId});
  Future<Result<bool, AppError>> toggleLike(String trackId, {String? profileId});

  // ---- Play stats ----------------------------------------------------------
  Future<Result<void, AppError>> updatePlayStats(String trackId, Duration position, {String? profileId});

  // ---- Write paths ---------------------------------------------------------
  /// Inserts or updates a track row keyed by [Track.id]. Identities should be
  /// generated deterministically by the caller (import service).
  Future<Result<void, AppError>> insertTrack(Track track, {String? profileId});

  /// Persists fetched lyrics for a track so later sessions read them from the
  /// database instead of re-fetching the provider.
  Future<Result<void, AppError>> saveLyrics(String trackId, List<LyricLine> lines);

  /// Edits user-adjustable metadata for a locally available track.
  /// Only the local database row is changed; the tag on the audio file itself
  /// is left untouched.
  Future<Result<Track, AppError>> updateTrackMetadata(
    String trackId, {
    required String title,
    required String artist,
    String? album,
    String? genre,
    int? releaseYear,
    int? trackNumber,
    int? discNumber,
  });

  /// Removes a track from the library database. The original audio file is
  /// never touched on disk.
  Future<Result<void, AppError>> removeTrack(String trackId, {String? profileId});

  /// True when a track with [id] already exists in the library.
  Future<Result<bool, AppError>> trackExists(String trackId);

  /// Looks for an existing track whose (title, artist, duration) signature
  /// matches — used to avoid duplicate library rows when re-importing.
  Future<Result<Track?, AppError>> findDuplicate(Track candidate, {String? profileId});

  // ---- Albums (derived from real track records) ----------------------------
  Future<Result<List<Album>, AppError>> getAlbums({String? profileId, bool savedOnly = false});
  Future<Result<Album, AppError>> getAlbum(String albumId, {String? profileId});
  Future<Result<bool, AppError>> toggleSaveAlbum(String albumId, {String? profileId});

  // ---- Artists (derived from real track records) ---------------------------
  Future<Result<List<Artist>, AppError>> getArtists({String? profileId, bool followedOnly = false});
  Future<Result<Artist, AppError>> getArtist(String artistId, {String? profileId});
  Future<Result<bool, AppError>> toggleFollowArtist(String artistId, {String? profileId});
}
