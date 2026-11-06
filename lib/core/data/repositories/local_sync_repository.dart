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

class LocalSyncRepository implements SyncRepository {
  final CaviaDatabase db;
  final sb.SupabaseClient? client;
  final String deviceId;
  static const _uuid = Uuid();

  final StreamController<SyncState> _syncStateController = StreamController<SyncState>.broadcast();
  SyncState _currentState;

  LocalSyncRepository({
    required this.db,
    this.client,
    String? deviceId,
  })  : deviceId = deviceId ?? _uuid.v4(),
        _currentState = const SyncState(profileId: 'guest', status: SyncStatus.idle);

  String _resolveProfile(String? profileId) => profileId ?? 'guest';

  @override
  Stream<SyncState> watchSyncState({String? profileId}) {
    final pid = _resolveProfile(profileId);
    return _syncStateController.stream.where((s) => s.profileId == pid);
  }

  @override
  SyncState get currentSyncState => _currentState;

  void _updateState(SyncState newState) {
    _currentState = newState;
    _syncStateController.add(_currentState);
  }

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
              createdAt: operation.createdAt,
              retryCount: Value(operation.retryCount),
              lastAttemptAt: Value(operation.lastAttemptAt),
              lastError: Value(operation.lastError),
              idempotencyKey: operation.idempotencyKey,
            ),
          );

      // Update pending count in state
      final pendingCount = await _getPendingCount(operation.profileId);
      _updateState(_currentState.copyWith(
        profileId: operation.profileId,
        pendingCount: pendingCount,
      ));

      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to enqueue operation: $e', cause: st));
    }
  }

  Future<int> _getPendingCount(String profileId) async {
    final countQuery = db.selectOnly(db.dbSyncOutbox)
      ..addColumns([db.dbSyncOutbox.id.count()])
      ..where(db.dbSyncOutbox.profileId.equals(profileId));
    final count = await countQuery.map((r) => r.read(db.dbSyncOutbox.id.count()) ?? 0).getSingle();
    return count;
  }

  @override
  Future<Result<List<SyncOperation>, AppError>> getPendingOperations({String? profileId}) async {
    try {
      final pid = _resolveProfile(profileId);
      final rows = await (db.select(db.dbSyncOutbox)
            ..where((tbl) => tbl.profileId.equals(pid))
            ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.asc)]))
          .get();

      final ops = rows.map((r) {
        Map<String, dynamic> payload = {};
        try {
          payload = jsonDecode(r.payloadJson) as Map<String, dynamic>;
        } catch (_) {}

        return SyncOperation(
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
          createdAt: r.createdAt,
          retryCount: r.retryCount,
          lastAttemptAt: r.lastAttemptAt,
          lastError: r.lastError,
          idempotencyKey: r.idempotencyKey,
        );
      }).toList();

      return Result.success(ops);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to fetch pending ops: $e', cause: st));
    }
  }

  @override
  Future<Result<void, AppError>> markOperationCompleted(String operationId) async {
    try {
      await (db.delete(db.dbSyncOutbox)..where((tbl) => tbl.id.equals(operationId))).go();
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to mark op completed: $e', cause: st));
    }
  }

  @override
  Future<Result<void, AppError>> recordOperationFailed(String operationId, String error) async {
    try {
      final existing = await (db.select(db.dbSyncOutbox)..where((tbl) => tbl.id.equals(operationId))).getSingleOrNull();
      if (existing != null) {
        await (db.update(db.dbSyncOutbox)..where((tbl) => tbl.id.equals(operationId))).write(
          DbSyncOutboxCompanion(
            retryCount: Value(existing.retryCount + 1),
            lastAttemptAt: Value(DateTime.now()),
            lastError: Value(error),
          ),
        );
      }
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to record op error: $e', cause: st));
    }
  }

  @override
  Future<Result<void, AppError>> processOutbox({String? profileId}) async {
    final pid = _resolveProfile(profileId);
    if (pid == 'guest' || client == null) {
      // Guest mode or offline client does not upload to cloud
      return const Result.success(null);
    }

    final c = client!;
    final user = c.auth.currentUser;
    if (user == null || user.id != pid) {
      _updateState(_currentState.copyWith(
        status: SyncStatus.paused,
        lastError: 'Authentication session expired',
      ));
      return const Result.failure(ValidationError('Authentication required for cloud sync.'));
    }

    _updateState(_currentState.copyWith(status: SyncStatus.syncing));

    try {
      final opsResult = await getPendingOperations(profileId: pid);
      if (opsResult.isFailure) return Result.failure(opsResult.errorOrNull!);
      final operations = opsResult.dataOrNull!;

      final random = Random();
      for (final op in operations) {
        // Exponential backoff check: if retryCount > 0, check interval
        if (op.retryCount > 0 && op.lastAttemptAt != null) {
          final backoffSeconds = min(60, pow(2, op.retryCount - 1).toInt()) + random.nextInt(3);
          final nextAllowed = op.lastAttemptAt!.add(Duration(seconds: backoffSeconds));
          if (DateTime.now().isBefore(nextAllowed)) {
            continue; // Skip until backoff window expires
          }
        }

        if (op.retryCount >= 6) {
          // Permanent failure threshold: stop retrying this item
          continue;
        }

        try {
          // 1. Check idempotency receipt on Supabase
          final existingReceipt = await c
              .from('operation_receipts')
              .select('id')
              .eq('user_id', pid)
              .eq('idempotency_key', op.idempotencyKey)
              .maybeSingle();

          if (existingReceipt == null) {
            // Apply operation to target table
            await _dispatchOperationToCloud(c, pid, op);

            // Record operation receipt
            await c.from('operation_receipts').upsert({
              'id': _uuid.v4(),
              'user_id': pid,
              'device_id': op.deviceId,
              'idempotency_key': op.idempotencyKey,
              'entity_type': op.entityType.name,
              'entity_id': op.entityId,
              'operation_type': op.operationType.name,
              'applied_at': DateTime.now().toIso8601String(),
            });
          }

          // Operation confirmed by server: remove from outbox
          await markOperationCompleted(op.id);
        } catch (err) {
          await recordOperationFailed(op.id, err.toString());
        }
      }

      final remainingCount = await _getPendingCount(pid);
      _updateState(_currentState.copyWith(
        status: remainingCount == 0 ? SyncStatus.idle : SyncStatus.error,
        pendingCount: remainingCount,
        lastSyncedAt: remainingCount == 0 ? DateTime.now() : _currentState.lastSyncedAt,
      ));

      return const Result.success(null);
    } catch (e, st) {
      _updateState(_currentState.copyWith(
        status: SyncStatus.error,
        lastError: e.toString(),
      ));
      return Result.failure(DatabaseError(
        userMessage: "Couldn't sync. Your changes are safe on this device.",
        details: 'Outbox processing failed: $e',
        cause: st,
      ));
    }
  }

  Future<void> _dispatchOperationToCloud(
    sb.SupabaseClient c,
    String userId,
    SyncOperation op,
  ) async {
    switch (op.entityType) {
      case SyncEntityType.playlist:
        if (op.operationType == SyncOperationType.delete) {
          await c.from('playlists').update({
            'is_deleted': true,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', op.entityId).eq('user_id', userId);

          // Insert tombstone
          await c.from('sync_tombstones').upsert({
            'id': _uuid.v4(),
            'user_id': userId,
            'entity_type': 'playlist',
            'entity_id': op.entityId,
            'deleted_at': DateTime.now().toIso8601String(),
          });
        } else {
          await c.from('playlists').upsert({
            'id': op.entityId,
            'user_id': userId,
            'name': op.payload['name'] ?? 'Untitled Playlist',
            'description': op.payload['description'] ?? '',
            'artwork_uri': op.payload['artwork_uri'] ?? 'assets/images/cover_zenith.jpg',
            'revision': op.payload['revision'] ?? 1,
            'is_deleted': false,
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
        break;

      case SyncEntityType.playlistEntry:
        if (op.operationType == SyncOperationType.delete) {
          await c.from('playlist_entries').update({
            'is_deleted': true,
            'updated_at': DateTime.now().toIso8601String(),
          }).eq('id', op.entityId);

          await c.from('sync_tombstones').upsert({
            'id': _uuid.v4(),
            'user_id': userId,
            'entity_type': 'playlist_entry',
            'entity_id': op.entityId,
            'deleted_at': DateTime.now().toIso8601String(),
          });
        } else {
          await c.from('playlist_entries').upsert({
            'id': op.entityId,
            'playlist_id': op.payload['playlist_id'],
            'track_id': op.payload['track_id'],
            'position': op.payload['position'] ?? 0,
            'revision': op.payload['revision'] ?? 1,
            'is_deleted': false,
            'date_added': op.payload['date_added'] ?? DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
        break;

      case SyncEntityType.likedTrack:
        final isLiked = op.payload['is_liked'] ?? (op.operationType != SyncOperationType.delete);
        await c.from('liked_tracks').upsert({
          'id': op.payload['id'] ?? _uuid.v4(),
          'user_id': userId,
          'track_id': op.entityId,
          'is_liked': isLiked,
          'revision': op.payload['revision'] ?? 1,
          'date_liked': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        break;

      case SyncEntityType.preference:
        await c.from('user_preferences').upsert({
          'user_id': userId,
          'offline_caching': op.payload['offline_caching'] ?? true,
          'audio_quality': op.payload['audio_quality'] ?? 'Lossless (24-bit / 96kHz FLAC)',
          'crossfade': op.payload['crossfade'] ?? true,
          'gapless_playback': op.payload['gapless_playback'] ?? true,
          'normalize_volume': op.payload['normalize_volume'] ?? false,
          'accent_color_value': op.payload['accent_color_value'] ?? 4294336040,
          'artwork_atmosphere': op.payload['artwork_atmosphere'] ?? true,
          'animation_intensity': op.payload['animation_intensity'] ?? 'Smooth',
          'revision': op.payload['revision'] ?? 1,
          'updated_at': DateTime.now().toIso8601String(),
        });
        break;
    }
  }

  @override
  Future<Result<void, AppError>> pullRemoteChanges({String? profileId}) async {
    final pid = _resolveProfile(profileId);
    if (pid == 'guest' || client == null) {
      return const Result.success(null);
    }

    final c = client!;
    final user = c.auth.currentUser;
    if (user == null || user.id != pid) {
      return const Result.failure(ValidationError('Authentication required to pull cloud updates.'));
    }

    _updateState(_currentState.copyWith(status: SyncStatus.syncing));

    try {
      // 1. Fetch tombstones
      final tombstones = await c.from('sync_tombstones').select().eq('user_id', pid);
      final tombstonedPlaylists = <String>{};
      final tombstonedEntries = <String>{};

      for (final t in tombstones) {
        if (t['entity_type'] == 'playlist') {
          tombstonedPlaylists.add(t['entity_id'] as String);
        } else if (t['entity_type'] == 'playlist_entry') {
          tombstonedEntries.add(t['entity_id'] as String);
        }
      }

      // Apply tombstones locally
      for (final plId in tombstonedPlaylists) {
        await (db.delete(db.dbPlaylists)..where((tbl) => tbl.id.equals(plId))).go();
        await (db.delete(db.dbPlaylistEntries)..where((tbl) => tbl.playlistId.equals(plId))).go();
      }
      for (final entryId in tombstonedEntries) {
        await (db.delete(db.dbPlaylistEntries)..where((tbl) => tbl.id.equals(entryId))).go();
      }

      // 2. Pull remote playlists
      final remotePlaylists = await c.from('playlists').select().eq('user_id', pid).eq('is_deleted', false);
      for (final p in remotePlaylists) {
        final plId = p['id'] as String;
        if (tombstonedPlaylists.contains(plId)) continue;

        await db.into(db.dbPlaylists).insertOnConflictUpdate(
              DbPlaylistsCompanion.insert(
                id: plId,
                profileId: Value(pid),
                name: p['name'] as String,
                description: Value(p['description'] as String? ?? ''),
                artworkUri: p['artwork_uri'] as String? ?? 'assets/images/cover_zenith.jpg',
                createdAt: DateTime.tryParse(p['created_at'] as String) ?? DateTime.now(),
                updatedAt: DateTime.tryParse(p['updated_at'] as String) ?? DateTime.now(),
              ),
            );

        // Pull entries for this playlist
        final remoteEntries = await c
            .from('playlist_entries')
            .select()
            .eq('playlist_id', plId)
            .eq('is_deleted', false)
            .order('position', ascending: true);

        for (final entry in remoteEntries) {
          final entryId = entry['id'] as String;
          if (tombstonedEntries.contains(entryId)) continue;

          await db.into(db.dbPlaylistEntries).insertOnConflictUpdate(
                DbPlaylistEntriesCompanion.insert(
                  id: entryId,
                  playlistId: plId,
                  trackId: entry['track_id'] as String,
                  position: entry['position'] as int? ?? 0,
                  dateAdded: DateTime.tryParse(entry['date_added'] as String? ?? '') ?? DateTime.now(),
                ),
              );
        }
      }

      // 3. Pull liked tracks
      final remoteLikes = await c.from('liked_tracks').select().eq('user_id', pid);
      for (final l in remoteLikes) {
        final trackId = l['track_id'] as String;
        final isLiked = l['is_liked'] as bool? ?? true;

        if (isLiked) {
          await db.into(db.dbLikedSongs).insertOnConflictUpdate(
                DbLikedSongsCompanion.insert(
                  profileId: Value(pid),
                  trackId: trackId,
                  dateLiked: DateTime.tryParse(l['date_liked'] as String? ?? '') ?? DateTime.now(),
                ),
              );
        } else {
          await (db.delete(db.dbLikedSongs)
                ..where((tbl) => tbl.profileId.equals(pid) & tbl.trackId.equals(trackId)))
              .go();
        }
      }

      // 4. Pull user preferences
      final remotePrefs = await c.from('user_preferences').select().eq('user_id', pid).maybeSingle();
      if (remotePrefs != null) {
        final now = DateTime.now();
        final entries = {
          'offlineCaching': (remotePrefs['offline_caching'] ?? true).toString(),
          'audioQuality': (remotePrefs['audio_quality'] ?? 'Lossless (24-bit / 96kHz FLAC)').toString(),
          'crossfade': (remotePrefs['crossfade'] ?? true).toString(),
          'gaplessPlayback': (remotePrefs['gapless_playback'] ?? true).toString(),
          'normalizeVolume': (remotePrefs['normalize_volume'] ?? false).toString(),
          'accentColorValue': (remotePrefs['accent_color_value'] ?? 4294336040).toString(),
          'artworkAtmosphere': (remotePrefs['artwork_atmosphere'] ?? true).toString(),
          'animationIntensity': (remotePrefs['animation_intensity'] ?? 'Smooth').toString(),
          'cloudSync': 'true',
          'lastSyncTime': 'Just now',
        };
        for (final entry in entries.entries) {
          await db.into(db.dbPreferences).insertOnConflictUpdate(
                DbPreferencesCompanion.insert(
                  key: entry.key,
                  value: entry.value,
                  updatedAt: now,
                ),
              );
        }
      }

      _updateState(_currentState.copyWith(
        status: SyncStatus.idle,
        lastSyncedAt: DateTime.now(),
        lastError: null,
      ));

      return const Result.success(null);
    } catch (e, st) {
      _updateState(_currentState.copyWith(
        status: SyncStatus.error,
        lastError: e.toString(),
      ));
      return Result.failure(DatabaseError(
        userMessage: "Couldn't sync. Your changes are safe on this device.",
        details: 'Pull remote changes failed: $e',
        cause: st,
      ));
    }
  }

  @override
  Future<Result<void, AppError>> mergeGuestLibraryWithAccount(String accountProfileId) async {
    try {
      return await db.transaction(() async {
        // 1. Fetch guest liked songs
        final guestLikes = await (db.select(db.dbLikedSongs)..where((tbl) => tbl.profileId.equals('guest'))).get();
        for (final l in guestLikes) {
          await db.into(db.dbLikedSongs).insert(
                DbLikedSongsCompanion.insert(
                  profileId: Value(accountProfileId),
                  trackId: l.trackId,
                  dateLiked: l.dateLiked,
                ),
                mode: InsertMode.insertOrIgnore, // Prevent duplicates
              );

          // Enqueue sync operation for account
          final opId = _uuid.v4();
          await enqueueOperation(SyncOperation(
            id: opId,
            profileId: accountProfileId,
            deviceId: deviceId,
            entityType: SyncEntityType.likedTrack,
            entityId: l.trackId,
            operationType: SyncOperationType.create,
            payload: {'is_liked': true, 'revision': 1},
            createdAt: DateTime.now(),
            idempotencyKey: 'merge_like_${accountProfileId}_${l.trackId}',
          ));
        }

        // 2. Fetch guest playlists
        final guestPlaylists = await (db.select(db.dbPlaylists)
              ..where((tbl) => tbl.profileId.equals('guest') & tbl.isDeleted.equals(false)))
            .get();

        for (final pl in guestPlaylists) {
          final newPlaylistId = _uuid.v4();
          await db.into(db.dbPlaylists).insert(
                DbPlaylistsCompanion.insert(
                  id: newPlaylistId,
                  profileId: Value(accountProfileId),
                  name: pl.name,
                  description: Value(pl.description),
                  artworkUri: pl.artworkUri,
                  createdAt: pl.createdAt,
                  updatedAt: pl.updatedAt,
                ),
              );

          // Copy entries
          final entries = await (db.select(db.dbPlaylistEntries)
                ..where((tbl) => tbl.playlistId.equals(pl.id))
                ..orderBy([(tbl) => OrderingTerm(expression: tbl.position, mode: OrderingMode.asc)]))
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
              },
              createdAt: DateTime.now(),
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
              'name': pl.name,
              'description': pl.description,
              'artwork_uri': pl.artworkUri,
              'revision': 1,
            },
            createdAt: DateTime.now(),
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
  Future<Result<void, AppError>> purgeTombstones({Duration retention = const Duration(days: 30)}) async {
    try {
      final threshold = DateTime.now().subtract(retention);
      await (db.delete(db.dbTombstones)..where((tbl) => tbl.deletedAt.isSmallerThanValue(threshold))).go();
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to purge tombstones: $e', cause: st));
    }
  }

  void dispose() {
    _syncStateController.close();
  }
}
