import '../models/playback_queue.dart';
import '../result/result.dart';
import '../result/app_error.dart';

abstract class QueueRepository {
  Future<Result<PlaybackQueueState, AppError>> loadQueue({String? profileId});
  Future<Result<void, AppError>> saveQueue(PlaybackQueueState state, {String? profileId});
  Stream<PlaybackQueueState> watchQueue({String? profileId});
  Future<Result<void, AppError>> clearQueue({String? profileId});
}

