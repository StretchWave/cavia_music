import 'package:uuid/uuid.dart';

import '../../domain/models/app_preferences.dart';
import '../../domain/models/sync_operation.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/result/result.dart';
import '../../domain/result/app_error.dart';
import '../database/cavia_database.dart';

/// Key/value-backed implementation of [SettingsRepository].
///
/// The current **cache occupied size** is never stored here; it is always
/// measured from the filesystem by the cache manager, so the database cannot
/// drift from reality.
class LocalSettingsRepository implements SettingsRepository {
  final CaviaDatabase db;
  final SyncRepository? syncRepository;

  /// Stable identity of THIS device for cloud-sync receipts.
  final String deviceId;

  LocalSettingsRepository(this.db, {this.syncRepository, String? deviceId})
      : deviceId = deviceId ?? const Uuid().v4();

  @override
  Future<AppPreferences> getPreferences() async {
    try {
      final rows = await db.select(db.dbPreferences).get();
      final map = {for (final r in rows) r.key: r.value};
      return AppPreferences.fromMap(map);
    } catch (e) {
      // A broken preferences store must not silently fake defaults for the
      // rest of the app; propagate a typed failure instead.
      throw StateError('Preferences table unreadable: $e');
    }
  }

  @override
  Stream<AppPreferences> watchPreferences() {
    return db.select(db.dbPreferences).watch().asyncMap((_) async {
      final rows = await db.select(db.dbPreferences).get();
      return AppPreferences.fromMap({for (final r in rows) r.key: r.value});
    });
  }

  @override
  Future<Result<void, AppError>> updatePreferences(AppPreferences preferences) async {
    try {
      final now = DateTime.now().toUtc();
      final entries = preferences.toMap();

      await db.transaction(() async {
        for (final entry in entries.entries) {
          await db.into(db.dbPreferences).insertOnConflictUpdate(
                DbPreferencesCompanion.insert(
                  key: entry.key,
                  value: entry.value,
                  updatedAt: now,
                ),
              );
        }

        if (syncRepository != null && preferences.profileId != 'guest') {
          await syncRepository!.enqueueOperation(SyncOperation(
            id: 'sync_pref_${const Uuid().v4()}',
            profileId: preferences.profileId,
            deviceId: deviceId,
            entityType: SyncEntityType.preference,
            entityId: preferences.profileId,
            operationType: SyncOperationType.update,
            payload: {
              'offline_caching': preferences.offlineCaching,
              'audio_quality': preferences.audioQuality,
              'crossfade': preferences.crossfade,
              'gapless_playback': preferences.gaplessPlayback,
              'normalize_volume': preferences.normalizeVolume,
              'playback_speed': preferences.playbackSpeed,
              'cache_quota_bytes': preferences.cacheQuotaBytes.round(),
              'accent_color_value': preferences.accentColorValue,
              'artwork_atmosphere': preferences.artworkAtmosphere,
              'animation_intensity': preferences.animationIntensity,
              'cloud_sync': preferences.cloudSync,
            },
            createdAt: now,
            idempotencyKey: 'op_pref_${preferences.profileId}_${const Uuid().v4()}',
          ));
        }
      });

      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to update preferences: $e', cause: st));
    }
  }

  /// Legacy hook kept for interface compatibility. Actual cache clearing is
  /// performed by the [CacheManager]; this method no longer fabricates a
  /// cache-size row.
  @override
  Future<Result<void, AppError>> clearCache() async {
    return const Result.success(null);
  }
}
