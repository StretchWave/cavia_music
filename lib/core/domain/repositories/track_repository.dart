import '../models/track.dart';
import '../result/result.dart';
import '../result/app_error.dart';

abstract class TrackRepository {
  Future<Result<List<Track>, AppError>> getAllTracks({String? profileId});
  Stream<List<Track>> watchTracks({String? profileId});
  Stream<List<Track>> watchLikedTracks({String? profileId});
  Future<Result<Track, AppError>> getTrackById(String id, {String? profileId});
  Future<Result<bool, AppError>> isTrackLiked(String trackId, {String? profileId});
  Future<Result<bool, AppError>> toggleLike(String trackId, {String? profileId});
  Future<Result<void, AppError>> updatePlayStats(String trackId, Duration position, {String? profileId});
  Future<Result<void, AppError>> insertTrack(Track track, {String? profileId});
}

