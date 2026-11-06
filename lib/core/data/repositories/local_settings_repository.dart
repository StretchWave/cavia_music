import '../../domain/models/app_preferences.dart';
import '../../domain/models/sync_operation.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/sync_repository.dart';
import '../../domain/result/result.dart';
import '../../domain/result/app_error.dart';
import '../database/cavia_database.dart';

class LocalSettingsRepository implements SettingsRepository {
  final CaviaDatabase db;
  final SyncRepository? syncRepository;

  LocalSettingsRepository(this.db, {this.syncRepository});

  @override
  Future<AppPreferences> getPreferences() async {
    try {
      final rows = await db.select(db.dbPreferences).get();
      final map = {for (final r in rows) r.key: r.value};

      return AppPreferences(
        offlineCaching: map['offlineCaching'] != 'false',
        cacheLimitBytes: double.tryParse(map['cacheLimitBytes'] ?? '') ?? 2.0 * 1024 * 1024 * 1024,
        audioQuality: map['audioQuality'] ?? 'Lossless (24-bit / 96kHz FLAC)',
        crossfade: map['crossfade'] != 'false',
        gaplessPlayback: map['gaplessPlayback'] != 'false',
        normalizeVolume: map['normalizeVolume'] == 'true',
        accentColorValue: int.tryParse(map['accentColorValue'] ?? '') ?? 0xFFE53935,
        artworkAtmosphere: map['artworkAtmosphere'] != 'false',
        animationIntensity: map['animationIntensity'] ?? 'Smooth',
        cloudSync: map['cloudSync'] == 'true',
        lastSyncTime: map['lastSyncTime'] ?? 'Never',
        currentCacheSizeBytes: double.tryParse(map['currentCacheSizeBytes'] ?? '') ?? 1.2 * 1024 * 1024 * 1024,
      );
    } catch (_) {
      return const AppPreferences();
    }
  }

  @override
  Stream<AppPreferences> watchPreferences() {
    return db.select(db.dbPreferences).watch().asyncMap((_) => getPreferences());
  }

  @override
  Future<Result<void, AppError>> updatePreferences(AppPreferences preferences) async {
    try {
      final now = DateTime.now();
      final entries = {
        'offlineCaching': preferences.offlineCaching.toString(),
        'cacheLimitBytes': preferences.cacheLimitBytes.toString(),
        'audioQuality': preferences.audioQuality,
        'crossfade': preferences.crossfade.toString(),
        'gaplessPlayback': preferences.gaplessPlayback.toString(),
        'normalizeVolume': preferences.normalizeVolume.toString(),
        'accentColorValue': preferences.accentColorValue.toString(),
        'artworkAtmosphere': preferences.artworkAtmosphere.toString(),
        'animationIntensity': preferences.animationIntensity,
        'cloudSync': preferences.cloudSync.toString(),
        'lastSyncTime': preferences.lastSyncTime,
        'currentCacheSizeBytes': preferences.currentCacheSizeBytes.toString(),
      };

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
            id: 'sync_pref_${preferences.profileId}_${now.millisecondsSinceEpoch}',
            profileId: preferences.profileId,
            deviceId: 'local',
            entityType: SyncEntityType.preference,
            entityId: preferences.profileId,
            operationType: SyncOperationType.update,
            payload: {
              'offline_caching': preferences.offlineCaching,
              'audio_quality': preferences.audioQuality,
              'crossfade': preferences.crossfade,
              'gapless_playback': preferences.gaplessPlayback,
              'normalize_volume': preferences.normalizeVolume,
              'accent_color_value': preferences.accentColorValue,
              'artwork_atmosphere': preferences.artworkAtmosphere,
              'animation_intensity': preferences.animationIntensity,
              'revision': 1,
            },
            createdAt: now,
            idempotencyKey: 'op_pref_${preferences.profileId}_${now.millisecondsSinceEpoch}',
          ));
        }
      });

      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to update preferences: $e', cause: st));
    }
  }

  @override
  Future<Result<void, AppError>> clearCache() async {
    try {
      await db.into(db.dbPreferences).insertOnConflictUpdate(
            DbPreferencesCompanion.insert(
              key: 'currentCacheSizeBytes',
              value: '0.0',
              updatedAt: DateTime.now(),
            ),
          );
      return const Result.success(null);
    } catch (e, st) {
      return Result.failure(DatabaseError(details: 'Failed to clear cache: $e', cause: st));
    }
  }
}
