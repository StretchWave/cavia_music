import '../models/sync_operation.dart';
import '../models/sync_state.dart';
import '../result/result.dart';
import '../result/app_error.dart';

abstract class SyncRepository {
  /// Stream of synchronization status and diagnostics.
  Stream<SyncState> watchSyncState({String? profileId});

  /// Current sync state.
  SyncState get currentSyncState;

  /// Staged mutations in SQLite outbox.
  Future<Result<void, AppError>> enqueueOperation(SyncOperation operation);

  /// Retrieves pending operations in deterministic chronological order.
  Future<Result<List<SyncOperation>, AppError>> getPendingOperations({String? profileId});

  /// Marks an operation as confirmed by the server and removes it from outbox.
  Future<Result<void, AppError>> markOperationCompleted(String operationId);

  /// Records a retry attempt and failure message for an operation.
  Future<Result<void, AppError>> recordOperationFailed(String operationId, String error);

  /// Flushes pending outbox operations to Supabase in deterministic order.
  Future<Result<void, AppError>> processOutbox({String? profileId});

  /// Pulls remote cloud changes (playlists, entries, liked songs, preferences)
  /// and applies them to the local SQLite tables with conflict resolution.
  Future<Result<void, AppError>> pullRemoteChanges({String? profileId});

  /// Explicitly merges guest library into the authenticated account library.
  /// Automatically creates a safety backup of local state before merging.
  Future<Result<void, AppError>> mergeGuestLibraryWithAccount(String accountProfileId);

  /// Purges tombstones older than the retention duration safely.
  Future<Result<void, AppError>> purgeTombstones({Duration retention = const Duration(days: 30)});
}

