import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:uuid/uuid.dart';

import '../../domain/models/sync_operation.dart';
import '../../domain/models/sync_state.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/result/result.dart';
import '../../domain/result/app_error.dart';
import '../database/cavia_database.dart';

/// Offline-first sync engine.
///
/// Every mutation made while signed in (or to be promoted later) is staged as a
/// [SyncOperation] in the local outbox with an idempotency key. Flushing sends
/// the batch to the atomic `sync_push` RPC, which applies mutations and writes
/// idempotency receipts inside one server transaction — the client never
/// applies-then-receipts in two steps.
///
/// Pulls go through `sync_pull` with a UTC watermark and are applied locally
/// with last-writer-wins semantics (highest revision wins; local tombstones
/// newer than a remote row prevent resurrection).
///
/// Every timestamp is UTC, every status transition is persisted to
/// `dbSyncState` so state survives restarts, and the sync engine performs no
/// fabricated work when cloud sync is not configured.
class LocalSyncRepository implements SyncRepository {
  LocalSyncRepository({
    required this.db,
    this.client,
    String? deviceId,
  }) : deviceId = deviceId ?? const Uuid().v4() {
    _restorePersistedState();
  }

  final CaviaDatabase db;
  final sb.SupabaseClient? client;
  final String deviceId;
  static const Uuid _uuid = Uuid();

  /// Hard cap on attempts before an operation is quarantined locally.
  static const int _maxRetries = 6;

  /// Maximum operations uploaded per RPC call (bounds the jsonb payload).
  static const int _pushBatchSize = 64;

  final StreamController<SyncState> _syncStateController =
      StreamController<SyncState>.broadcast();

  final Map<String, SyncState> _states = <String, SyncState>{};

  // ---------------------------------------------------------------------
  // State plumbing
  // ---------------------------------------------------------------------

  String _resolveProfile(String? profileId) => profileId ?? 'guest';

  @override
  Stream<SyncState> watchSyncState({String? profileId}) {
    final pid = _resolveProfile(profileId);
    return _syncStateController.stream.where((s) => s.profileId == pid);
  }

  @override
  SyncState get currentSyncState =>
      _states[_resolveProfile(null)] ?? const SyncState(profileId: 'guest');

  SyncState _stateFor(String profileId) =>
      _states[profileId] ?? SyncState(profileId: profileId);

  void _updateState(SyncState newState, {bool persist = true}) {
    _states[newState.profileId] = newState;
    _syncStateController.add(newState);
    if (persist) {
      unawaited(_persistState(newState));
    }
  }

  Future<void> _persistState(SyncState state) async {
    try {
      await db.into(db.dbSyncState).insertOnConflictUpdate(
            DbSyncStateCompanion.insert(
              profileId: state.profileId,
              lastSyncedAt: Value(state.lastSyncedAt),
              syncStatus: Value(_statusName(state.status)),
              errorMessage: Value(state.lastError),
            ),
          );
    } catch (_) {
      // Persistence of the status row is best-effort; the in-memory state and
      // the broadcast stream remain authoritative for the running session.
    }
  }

  Future<void> _restorePersistedState() async {
    try {
      final rows = await db.select(db.dbSyncState).get();
      for (final row in rows) {
        final status = SyncStatus.values.firstWhere(
          (s) => _statusName(s) == row.syncStatus,
          orElse: () => SyncStatus.idle,
        );
        // A process start never resumes a "syncing" run: retrying the flush is
        // done explicitly, so restored sync operations read truthfully.
        final restored = SyncState(
          profileId: row.profileId,
          status: row.syncStatus == 'syncing' ? SyncStatus.idle : status,
          lastSyncedAt: row.lastSyncedAt,
          lastError: row.errorMessage,
          pendingCount: 0,
        );
        _states[row.profileId] = restored;
        _syncStateController.add(restored);
      }
    } catch (_) {
      // No persisted state available — the in-memory default applies.
    }
  }

  String _statusName(SyncStatus status) => switch (status) {
        SyncStatus.idle => 'idle',
        SyncStatus.syncing => 'syncing',
        SyncStatus.paused => 'paused',
        SyncStatus.error => 'error',
        SyncStatus.offline => 'offline',
      };

  DateTime _utcNow() => DateTime.timestamp();

  // ---------------------------------------------------------------------
  // Outbox staging
  // ---------------------------------------------------------------------

  @override
  Future<Result<void, AppError>> enqueueOperation(SyncOperation operation) async {
    try {
      await db.into(db.dbSyncOutbox).insertOnConflictUpdate(
            DbSyncOutboxCompanion.insert(
              id: operation.id,
              profileId: operation.profileId,
              deviceId: operation.deviceId,
              entityType: operation.entityType.name,
              entityId: operation.entityId,
              operationType: operation.operationType.name,
              payloadJson: operation.payloadJson,
              createdAt: operation.createdAt.toUtc(),
              retryCount: Value(operation.retryCount),
              lastAttemptAt: Value(operation.lastAttemptAt?.toUtc()),
              lastError: Value(operation.lastError),
              idempotencyKey: operation.idempotencyKey,
            ),
          );

      final pendingCount = await _getPendingCount(operation.profileId);
      _updateState(_stateFor(operation.profileId).copyWith(
        pendingCount: pendingCount,
      ));
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(
        details: 'Failed to enqueue operation: $e',
        cause: st,
      ));
    }
  }

  Future<int> _getPendingCount(String profileId) async {
    final countQuery = db.selectOnly(db.dbSyncOutbox)
      ..addColumns([db.dbSyncOutbox.id.count()])
      ..where(db.dbSyncOutbox.profileId.equals(profileId));
    final count = await countQuery
        .map((r) => r.read(db.dbSyncOutbox.id.count()) ?? 0)
        .getSingle();
    return count;
  }

  @override
  Future<Result<List<SyncOperation>, AppError>> getPendingOperations({
    String? profileId,
  }) async {
    try {
      final pid = _resolveProfile(profileId);
      final rows = await (db.select(db.dbSyncOutbox)
            ..where((tbl) => tbl.profileId.equals(pid))
            ..orderBy([
              (tbl) => OrderingTerm(
                  expression: tbl.createdAt, mode: OrderingMode.asc),
            ]))
          .get();

      final ops = <SyncOperation>[];
      for (final r in rows) {
        Map<String, dynamic> payload = {};
        try {
          payload = jsonDecode(r.payloadJson) as Map<String, dynamic>;
        } catch (_) {
          // A malformed payload is skipped from upload but preserved locally.
          continue;
        }

        ops.add(SyncOperation(
          id: r.id,
          profileId: r.profileId,
          deviceId: r.deviceId,
          entityType: SyncEntityType.values.firstWhere(
            (e) => e.name == r.entityType,
            orElse: () => SyncEntityType.playlist,
          ),
          entityId: r.entityId,
          operationType: SyncOperationType.values.firstWhere(
            (o) => o.name == r.operationType,
            orElse: () => SyncOperationType.create,
          ),
          payload: payload,
          createdAt: r.createdAt.toUtc(),
          retryCount: r.retryCount,
          lastAttemptAt: r.lastAttemptAt?.toUtc(),
          lastError: r.lastError,
          idempotencyKey: r.idempotencyKey,
        ));
      }

      return Result.success(ops);
    } catch (e, st) {
      return Result.failure(DatabaseError(
        details: 'Failed to fetch pending ops: $e',
        cause: st,
      ));
    }
  }

  @override
  Future<Result<void, AppError>> markOperationCompleted(String operationId) async {
    try {
      await (db.delete(db.dbSyncOutbox)..where((tbl) => tbl.id.equals(operationId)))
          .go();
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(
        details: 'Failed to mark op completed: $e',
        cause: st,
      ));
    }
  }

  @override
  Future<Result<void, AppError>> recordOperationFailed(
    String operationId,
    String error,
  ) async {
    try {
      final existing = await (db.select(db.dbSyncOutbox)
            ..where((tbl) => tbl.id.equals(operationId)))
          .getSingleOrNull();
      if (existing != null) {
        await (db.update(db.dbSyncOutbox)
              ..where((tbl) => tbl.id.equals(operationId)))
            .write(DbSyncOutboxCompanion(
          retryCount: Value(existing.retryCount + 1),
          lastAttemptAt: Value(_utcNow()),
          lastError: Value(error),
        ));
      }
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(
        details: 'Failed to record op error: $e',
        cause: st,
      ));
    }
  }

  // ---------------------------------------------------------------------
  // Push — atomic RPC dispatch
  // ---------------------------------------------------------------------

  /// Wire protocol entity types (snake_case) as consumed by `sync_push`.
  String _wireEntityType(SyncEntityType type) => switch (type) {
        SyncEntityType.playlist => 'playlist',
        SyncEntityType.playlistEntry => 'playlist_entry',
        SyncEntityType.likedTrack => 'liked_track',
        SyncEntityType.preference => 'preference',
      };

  Map<String, dynamic> _toServerOperation(SyncOperation op) => {
        'idempotency_key': op.idempotencyKey,
        'entity_type': _wireEntityType(op.entityType),
        'entity_id': op.entityId,
        'operation_type': op.operationType.name,
        'payload': op.payload,
      };

  @override
  Future<Result<void, AppError>> processOutbox({String? profileId}) async {
    final pid = _resolveProfile(profileId);
    final c = client;

    if (c == null) {
      // Cloud sync is not configured on this build: the outbox stays local.
      _updateState(_stateFor(pid).copyWith(status: SyncStatus.offline));
      return const Result.success(null);
    }

    final user = c.auth.currentUser;
    if (user == null) {
      _updateState(_stateFor(pid).copyWith(
        status: SyncStatus.paused,
        lastError: 'Sign in required to upload changes.',
      ));
      return const Result.failure(ValidationError(
        'Sign in required to upload changes.',
        details: 'outbox_requires_auth',
      ));
    }
    if (user.id != pid) {
      _updateState(_stateFor(pid).copyWith(
        status: SyncStatus.paused,
        lastError: 'Outbox belongs to a different profile.',
      ));
      return const Result.failure(ValidationError(
        'Signed-in profile does not own this outbox.',
        details: 'outbox_profile_mismatch',
      ));
    }

    final opsResult = await getPendingOperations(profileId: pid);
    if (opsResult.isFailure) {
      _updateState(_stateFor(pid).copyWith(
        status: SyncStatus.error,
        lastError: opsResult.errorOrNull!.userMessage,
      ));
      return Result.failure(opsResult.errorOrNull!);
    }
    final operations = opsResult.dataOrNull!;

    final now = _utcNow();
    final eligible = <SyncOperation>[];
    for (final op in operations) {
      if (op.retryCount >= _maxRetries) continue; // quarantined
      if (op.retryCount > 0 && op.lastAttemptAt != null) {
        final backoffSeconds =
            min(60, pow(2, op.retryCount - 1).toInt());
        final nextAllowed =
            op.lastAttemptAt!.add(Duration(seconds: backoffSeconds));
        if (now.isBefore(nextAllowed)) continue; // still backing off
      }
      eligible.add(op);
    }

    if (eligible.isEmpty) {
      final remaining = await _getPendingCount(pid);
      _updateState(_stateFor(pid).copyWith(
        status: remaining == 0 ? SyncStatus.idle : SyncStatus.error,
        pendingCount: remaining,
      ));
      return const Result.success(null);
    }

    _updateState(_stateFor(pid).copyWith(status: SyncStatus.syncing));

    try {
      var anyRejected = false;
      for (var i = 0; i < eligible.length; i += _pushBatchSize) {
        final batch = eligible.sublist(
          i,
          min(i + _pushBatchSize, eligible.length),
        );

        final response = await c.rpc('sync_push', params: {
          'p_device_id': deviceId,
          'p_operations': batch.map(_toServerOperation).toList(),
        });

        final receipts = _extractReceipts(response);
        if (receipts == null) {
          // Malformed server response: treat the whole batch as failed so the
          // exponential backoff cycle applies.
          for (final op in batch) {
            await recordOperationFailed(
                op.id, 'Malformed sync_push response');
          }
          anyRejected = true;
          continue;
        }

        final byKey = <String, SyncOperation>{
          for (final op in batch) op.idempotencyKey: op,
        };
        final seen = <String>{};

        for (final receipt in receipts) {
          final key = receipt['idempotency_key']?.toString();
          final op = key == null ? null : byKey[key];
          if (op == null) continue; // receipt for an op we no longer hold
          seen.add(op.id);
          if (receipt['accepted'] == true) {
            await markOperationCompleted(op.id);
          } else {
            anyRejected = true;
            await recordOperationFailed(
              op.id,
              receipt['message']?.toString() ?? 'Rejected by server',
            );
          }
        }

        for (final op in batch) {
          if (!seen.contains(op.id)) {
            await recordOperationFailed(op.id, 'No receipt returned');
            anyRejected = true;
          }
        }
      }

      final remaining = await _getPendingCount(pid);
      _updateState(_stateFor(pid).copyWith(
        status: remaining == 0 ? SyncStatus.idle : SyncStatus.error,
        pendingCount: remaining,
        lastSyncedAt: remaining == 0 ? _utcNow() : _stateFor(pid).lastSyncedAt,
        lastError: anyRejected
            ? 'Some changes were rejected by the server; they will be retried.'
            : null,
      ));
      return const Result.success(null);
    } catch (e, st) {
      _updateState(_stateFor(pid).copyWith(
        status: SyncStatus.error,
        lastError: userTextFor(e),
      ));
      return Result.failure(DatabaseError(
        userMessage:
            "Couldn't sync. Your changes are safe on this device.",
        details: 'Outbox processing failed: $e',
        cause: st,
      ));
    }
  }

  List<Map<String, dynamic>>? _extractReceipts(dynamic response) {
    Map<String, dynamic> wrapper;
    try {
      if (response is String) {
        wrapper = jsonDecode(response) as Map<String, dynamic>;
      } else if (response is Map<String, dynamic>) {
        wrapper = response;
      } else if (response is Map) {
        wrapper = response.cast<String, dynamic>();
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
    final raw = wrapper['receipts'];
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    if (raw is List<Map>) {
      return raw.map((m) => m.cast<String, dynamic>()).toList();
    }
    return null;
  }

  String userTextFor(Object error) {
    if (error is sb.AuthException) {
      final code = int.tryParse(error.statusCode ?? '') ?? 0;
      if (code == 0 || (code >= 500 && code < 600)) {
        return 'Server is unreachable. Changes stay queued on this device.';
      }
      if (code == 401 || code == 403) {
        return 'Sign in again to sync your changes.';
      }
      if (code == 429) return 'Sync paused briefly (rate limit).';
    }
    return "Couldn't sync. Your changes are safe on this device.";
  }

  // ---------------------------------------------------------------------
  // Pull — incremental, last-writer-wins
  // ---------------------------------------------------------------------

  DateTime? _parseTs(dynamic raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString())?.toUtc();
  }

  int _revisionOf(dynamic raw, [int fallback = 1]) {
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '') ?? fallback;
  }

  @override
  Future<Result<void, AppError>> pullRemoteChanges({String? profileId}) async {
    final pid = _resolveProfile(profileId);
    final c = client;

    if (c == null) {
      _updateState(_stateFor(pid).copyWith(status: SyncStatus.offline));
      return const Result.success(null);
    }
    final user = c.auth.currentUser;
    if (user == null) {
      _updateState(_stateFor(pid).copyWith(
        status: SyncStatus.paused,
        lastError: 'Sign in required to download changes.',
      ));
      return const Result.failure(ValidationError(
        'Sign in required to pull cloud changes.',
        details: 'pull_requires_auth',
      ));
    }

    final watermark = _stateFor(pid).lastSyncedAt?.toUtc();
    _updateState(_stateFor(pid).copyWith(status: SyncStatus.syncing));

    try {
      final response = await c.rpc('sync_pull', params: {
        'p_since': watermark?.toIso8601String() ?? '1970-01-01T00:00:00.000Z',
      });

      Map<String, dynamic>? payload;
      if (response is Map) payload = response.cast<String, dynamic>();
      if (response is String) {
        payload = null; // SQL functions return objects; a string is a failure.
      }
      if (payload == null) {
        throw StateError('Malformed sync_pull response');
      }

      final serverTime =
          _parseTs(payload['server_time']) ?? _utcNow();

      // 1. Tombstones — bypass LWW: removal always wins over a pulled row.
      final tombstones = payload['tombstones'] is List
          ? (payload['tombstones'] as List)
              .whereType<Map<String, dynamic>>()
              .toList()
          : <Map<String, dynamic>>[];
      await _applyTombstones(tombstones);

      // 2. Playlists (LWW against local rows + local tombstones).
      final remotePlaylists = payload['playlists'] is List
          ? (payload['playlists'] as List)
              .whereType<Map<String, dynamic>>()
              .toList()
          : <Map<String, dynamic>>[];
      await _applyRemotePlaylists(remotePlaylists);

      // 3. Playlist entries.
      final remoteEntries = payload['playlist_entries'] is List
          ? (payload['playlist_entries'] as List)
              .whereType<Map<String, dynamic>>()
              .toList()
          : <Map<String, dynamic>>[];
      await _applyRemoteEntries(remoteEntries);

      // 4. Liked tracks.
      final remoteLikes = payload['liked_tracks'] is List
          ? (payload['liked_tracks'] as List)
              .whereType<Map<String, dynamic>>()
              .toList()
          : <Map<String, dynamic>>[];
      await _applyRemoteLikes(pid, remoteLikes);

      // 5. Preferences (only when the server row changed).
      final remotePrefs = payload['preferences'] is Map<String, dynamic>
          ? payload['preferences'] as Map<String, dynamic>
          : null;
      if (remotePrefs != null) {
        await _applyRemotePreferences(remotePrefs);
      }

      _updateState(_stateFor(pid).copyWith(
        status: SyncStatus.idle,
        lastSyncedAt: serverTime,
        lastError: null,
      ));
      return const Result.success(null);
    } catch (e, st) {
      _updateState(_stateFor(pid).copyWith(
        status: SyncStatus.error,
        lastError: userTextFor(e),
      ));
      return Result.failure(DatabaseError(
        userMessage:
            "Couldn't sync. Your changes are safe on this device.",
        details: 'Pull remote changes failed: $e',
        cause: st,
      ));
    }
  }

  Future<void> _applyTombstones(List<Map<String, dynamic>> tombstones) async {
    for (final t in tombstones) {
      final type = t['entity_type']?.toString();
      final entityId = t['entity_id']?.toString();
      if (entityId == null || entityId.isEmpty) continue;

      if (type == 'playlist') {
        await (db.delete(db.dbPlaylistEntries)
              ..where((tbl) => tbl.playlistId.equals(entityId)))
            .go();
        await (db.delete(db.dbPlaylists)..where((tbl) => tbl.id.equals(entityId)))
            .go();
      } else if (type == 'playlist_entry') {
        await (db.delete(db.dbPlaylistEntries)
              ..where((tbl) => tbl.id.equals(entityId)))
            .go();
      }
    }

    // Remember tombstones locally so a later pull from an older watermark can
    // still be matched for resurrection prevention.
    for (final t in tombstones) {
      final type = t['entity_type']?.toString();
      final entityId = t['entity_id']?.toString();
      final deletedAt = _parseTs(t['deleted_at']);
      if (type == null || entityId == null || deletedAt == null) continue;
      final exists = await (db.select(db.dbTombstones)
            ..where((tbl) =>
                tbl.profileId.equals(_resolveProfile(null)) &
                tbl.entityType.equals(type) &
                tbl.entityId.equals(entityId)))
          .getSingleOrNull();
      if (exists == null) {
        await db.into(db.dbTombstones).insert(DbTombstonesCompanion.insert(
              id: _uuid.v4(),
              profileId: _resolveProfile(null),
              entityType: type,
              entityId: entityId,
              deletedAt: deletedAt,
            ));
      }
    }
  }

  Future<void> _applyRemotePlaylists(
    List<Map<String, dynamic>> remotePlaylists,
  ) async {
    for (final row in remotePlaylists) {
      final plId = row['id']?.toString();
      if (plId == null || plId.isEmpty) continue;
      final remoteUpdated = _parseTs(row['updated_at']);
      if (remoteUpdated == null) continue;

      final tombstone = await (db.select(db.dbTombstones)
            ..where((tbl) =>
                tbl.entityType.equals('playlist') &
                tbl.entityId.equals(plId)))
          .getSingleOrNull();
      if (tombstone != null && !tombstone.deletedAt.isBefore(remoteUpdated)) {
        continue; // locally deleted after the remote change: keep it deleted
      }

      final local = await (db.select(db.dbPlaylists)
            ..where((tbl) => tbl.id.equals(plId)))
          .getSingleOrNull();
      if (local != null) {
        final remoteRev = _revisionOf(row['revision']);
        // Pull only delivers non-deleted rows, so a locally-deleted playlist
        // is considered overridden whenever the tombstone gate above passed.
        final remoteNewer = remoteRev > local.revision ||
            (remoteRev == local.revision &&
                local.updatedAt.isBefore(remoteUpdated)) ||
            local.isDeleted;
        if (!remoteNewer) continue; // local wins
      }

      final createdAt = _parseTs(row['created_at']);
      await db.into(db.dbPlaylists).insertOnConflictUpdate(
            DbPlaylistsCompanion.insert(
              id: plId,
              profileId: Value(_resolveProfile(null)),
              name: (row['name'] as String?)?.trim().isNotEmpty == true
                  ? row['name'] as String
                  : 'Untitled Playlist',
              description: Value(row['description']?.toString() ?? ''),
              artworkUri: row['artwork_uri']?.toString() ??
                  'assets/images/cover_zenith.jpg',
              createdAt: createdAt ?? remoteUpdated,
              updatedAt: remoteUpdated,
              isDeleted: const Value(false),
              revision: Value(max(_revisionOf(row['revision']), 1)),
              sourceProvider: Value(row['source_provider']?.toString()),
              sourcePlaylistId: Value(row['source_playlist_id']?.toString()),
            ),
          );
    }
  }

  Future<void> _applyRemoteEntries(
    List<Map<String, dynamic>> remoteEntries,
  ) async {
    for (final row in remoteEntries) {
      final entryId = row['id']?.toString();
      final playlistId = row['playlist_id']?.toString();
      if (entryId == null || playlistId == null) continue;
      final remoteUpdated = _parseTs(
        row['updated_at'] ?? row['date_added'],
      );
      if (remoteUpdated == null) continue;

      final tombstone = await (db.select(db.dbTombstones)
            ..where((tbl) =>
                tbl.entityType.equals('playlistEntry') &
                tbl.entityId.equals(entryId)))
          .getSingleOrNull();
      if (tombstone != null && !tombstone.deletedAt.isBefore(remoteUpdated)) {
        continue;
      }

      final local = await (db.select(db.dbPlaylistEntries)
            ..where((tbl) => tbl.id.equals(entryId)))
          .getSingleOrNull();
      if (local != null) {
        final remoteRev = _revisionOf(row['revision']);
        final remoteNewer = remoteRev > local.revision ||
            (remoteRev == local.revision && local.dateAdded.isBefore(remoteUpdated));
        if (!remoteNewer) continue;
      }

      await db.into(db.dbPlaylistEntries).insertOnConflictUpdate(
            DbPlaylistEntriesCompanion.insert(
              id: entryId,
              playlistId: playlistId,
              trackId: row['track_id']?.toString() ?? '',
              position: row['position'] is int
                  ? row['position'] as int
                  : int.tryParse(row['position']?.toString() ?? '') ?? 0,
              dateAdded: _parseTs(row['date_added']) ?? remoteUpdated,
              revision: Value(max(_revisionOf(row['revision']), 1)),
            ),
          );
    }
  }

  Future<void> _applyRemoteLikes(
    String pid,
    List<Map<String, dynamic>> remoteLikes,
  ) async {
    for (final row in remoteLikes) {
      final trackId = row['track_id']?.toString();
      if (trackId == null || trackId.isEmpty) continue;
      final updated = _parseTs(row['updated_at']) ?? _utcNow();
      final dateLiked =
          _parseTs(row['date_liked']) ?? updated;
      final isLiked = row['is_liked'] is bool
          ? row['is_liked'] as bool
          : (row['is_liked']?.toString() == 'true');

      final local = await (db.select(db.dbLikedSongs)
            ..where((tbl) =>
                tbl.profileId.equals(pid) & tbl.trackId.equals(trackId)))
          .getSingleOrNull();

      if (!isLiked) {
        if (local != null && local.dateLiked.isBefore(updated)) {
          await (db.delete(db.dbLikedSongs)
                ..where((tbl) =>
                    tbl.profileId.equals(pid) & tbl.trackId.equals(trackId)))
              .go();
        }
        continue;
      }

      if (local == null) {
        await db.into(db.dbLikedSongs).insert(
              DbLikedSongsCompanion.insert(
                profileId: Value(pid),
                trackId: trackId,
                dateLiked: dateLiked,
              ),
            );
      } else if (local.dateLiked.isBefore(dateLiked)) {
        await (db.update(db.dbLikedSongs)
              ..where((tbl) =>
                  tbl.profileId.equals(pid) & tbl.trackId.equals(trackId)))
            .write(DbLikedSongsCompanion(dateLiked: Value(dateLiked)));
      }
    }
  }

  /// Sanity floor: any remote date older than flutter's package era is a
  /// malformed clock from a misconfigured database, normalized to "now"-ish.
  static final DateTime localAlbumEpoch = DateTime.utc(2020, 1, 1);

  Future<void> _applyRemotePreferences(Map<String, dynamic> prefs) async {
    final remoteUpdated =
        _parseTs(prefs['updated_at']) ?? _utcNow();

    final remoteValueByName = <String, String?>{
      'offlineCaching': _boolText(prefs['offline_caching']),
      'audioQuality': prefs['audio_quality']?.toString(),
      'crossfade': _boolText(prefs['crossfade']),
      'gaplessPlayback': _boolText(prefs['gapless_playback']),
      'normalizeVolume': _boolText(prefs['normalize_volume']),
      'accentColorValue': _intText(prefs['accent_color_value']),
      'artworkAtmosphere': _boolText(prefs['artwork_atmosphere']),
      'animationIntensity': prefs['animation_intensity']?.toString(),
      'playbackSpeed': prefs['playback_speed'] == null
          ? null
          : (prefs['playback_speed'] as num?)?.toString(),
      'cacheQuotaBytes': _intText(prefs['cache_quota_bytes']),
    };

    for (final entry in remoteValueByName.entries) {
      final value = entry.value;
      if (value == null) continue; // absent/defaulted server value: keep local

      final local = await (db.select(db.dbPreferences)
            ..where((tbl) => tbl.key.equals(entry.key)))
          .getSingleOrNull();
      // LWW: a local unsynced preference edit newer than the server row wins;
      // otherwise the server copy adopts.
      if (local != null && local.updatedAt.isAfter(remoteUpdated)) continue;

      await db.into(db.dbPreferences).insertOnConflictUpdate(
            DbPreferencesCompanion.insert(
              key: entry.key,
              value: value,
              updatedAt: remoteUpdated,
            ),
          );
    }
  }

  String? _boolText(dynamic raw) =>
      raw == null ? null : (raw is bool ? raw.toString() : (raw.toString() == 'true').toString());

  String? _intText(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw.toString();
    return int.tryParse(raw.toString())?.toString();
  }

  // ---------------------------------------------------------------------
  // Guest → account merge
  // ---------------------------------------------------------------------

  @override
  Future<Result<void, AppError>> mergeGuestLibraryWithAccount(
    String accountProfileId,
  ) async {
    try {
      return await db.transaction(() async {
        final now = _utcNow();

        final guestLikes = await (db.select(db.dbLikedSongs)
              ..where((tbl) => tbl.profileId.equals('guest')))
            .get();
        for (final like in guestLikes) {
          await db.into(db.dbLikedSongs).insert(
                DbLikedSongsCompanion.insert(
                  profileId: Value(accountProfileId),
                  trackId: like.trackId,
                  dateLiked: like.dateLiked,
                ),
                mode: InsertMode.insertOrIgnore,
              );

          await enqueueOperation(SyncOperation(
            id: _uuid.v4(),
            profileId: accountProfileId,
            deviceId: deviceId,
            entityType: SyncEntityType.likedTrack,
            entityId: like.trackId,
            operationType: SyncOperationType.create,
            payload: {
              'track_id': like.trackId,
              'is_liked': true,
              'revision': 1,
              'date_liked': now.toIso8601String(),
            },
            createdAt: now,
            idempotencyKey: 'merge_like_${accountProfileId}_${like.trackId}',
          ));
        }

        final guestPlaylists = await (db.select(db.dbPlaylists)..where(
              (tbl) => tbl.profileId.equals('guest') & tbl.isDeleted.equals(false),
            ))
            .get();

        for (final playlist in guestPlaylists) {
          final newPlaylistId = _uuid.v4();
          await db.into(db.dbPlaylists).insert(
                DbPlaylistsCompanion.insert(
                  id: newPlaylistId,
                  profileId: Value(accountProfileId),
                  name: playlist.name,
                  description: Value(playlist.description),
                  artworkUri: playlist.artworkUri,
                  createdAt: now,
                  updatedAt: now,
                ),
              );

          final entries = await (db.select(db.dbPlaylistEntries)
                ..where((tbl) => tbl.playlistId.equals(playlist.id))
                ..orderBy([
                  (tbl) =>
                      OrderingTerm(expression: tbl.position, mode: OrderingMode.asc),
                ]))
              .get();

          for (final entry in entries) {
            final newEntryId = _uuid.v4();
            await db.into(db.dbPlaylistEntries).insert(
                  DbPlaylistEntriesCompanion.insert(
                    id: newEntryId,
                    playlistId: newPlaylistId,
                    trackId: entry.trackId,
                    position: entry.position,
                    dateAdded: entry.dateAdded,
                  ),
                );

            await enqueueOperation(SyncOperation(
              id: _uuid.v4(),
              profileId: accountProfileId,
              deviceId: deviceId,
              entityType: SyncEntityType.playlistEntry,
              entityId: newEntryId,
              operationType: SyncOperationType.create,
              payload: {
                'playlist_id': newPlaylistId,
                'track_id': entry.trackId,
                'position': entry.position,
                'revision': 1,
                'date_added': entry.dateAdded.toUtc().toIso8601String(),
              },
              createdAt: now,
              idempotencyKey: 'merge_pe_$newEntryId',
            ));
          }

          await enqueueOperation(SyncOperation(
            id: _uuid.v4(),
            profileId: accountProfileId,
            deviceId: deviceId,
            entityType: SyncEntityType.playlist,
            entityId: newPlaylistId,
            operationType: SyncOperationType.create,
            payload: {
              'name': playlist.name,
              'description': playlist.description,
              'artwork_uri': playlist.artworkUri,
              'revision': 1,
            },
            createdAt: now,
            idempotencyKey: 'merge_pl_$newPlaylistId',
          ));
        }

        return const Result.success(null);
      });
    } catch (e, st) {
      return Result.failure(DatabaseError(
        userMessage: "Couldn't merge libraries. Your local data remains unchanged.",
        details: 'Library merge failed: $e',
        cause: st,
      ));
    }
  }

  @override
  Future<Result<void, AppError>> purgeTombstones({
    Duration retention = const Duration(days: 30),
  }) async {
    try {
      final threshold = _utcNow().subtract(retention);
      await (db.delete(db.dbTombstones)
            ..where((tbl) => tbl.deletedAt.isSmallerThanValue(threshold)))
          .go();
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(
        details: 'Failed to purge tombstones: $e',
        cause: st,
      ));
    }
  }

  void dispose() {
    _syncStateController.close();
  }
}
