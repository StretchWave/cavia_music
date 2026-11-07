import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart' as sq;
import 'package:cavia_music/core/data/database/cavia_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Database Migration Regression Tests', () {
    test('Idempotently upgrades when columns already exist', () async {
      final tempDir = await Directory.systemTemp.createTemp('cavia_test_db_');
      final tempFile = File('${tempDir.path}/test_upgrade.sqlite');

      // 1. Manually create an SQLite database with schema v3 and partial v4 columns using sqlite3
      final rawSqlite = sq.sqlite3.open(tempFile.path);

      rawSqlite.execute('''
        CREATE TABLE db_tracks (
          id TEXT NOT NULL PRIMARY KEY,
          provider_id TEXT NOT NULL DEFAULT 'local',
          provider_track_id TEXT NOT NULL DEFAULT '',
          title TEXT NOT NULL,
          artist TEXT NOT NULL,
          artists_json TEXT NOT NULL DEFAULT '[]',
          album TEXT NOT NULL DEFAULT '',
          duration_ms INTEGER NOT NULL,
          artwork_uri TEXT NOT NULL,
          isrc TEXT,
          explicit INTEGER NOT NULL DEFAULT 0,
          availability_state TEXT NOT NULL DEFAULT 'available',
          source_attribution TEXT,
          date_added INTEGER NOT NULL,
          is_cached INTEGER NOT NULL DEFAULT 0,
          local_cache_path TEXT,
          play_count INTEGER NOT NULL DEFAULT 0,
          last_played_at INTEGER,
          lyrics_json TEXT NOT NULL DEFAULT '[]',
          album_artist TEXT
        );
      ''');

      rawSqlite.execute('''
        CREATE TABLE db_playlists (
          id TEXT NOT NULL PRIMARY KEY,
          profile_id TEXT NOT NULL DEFAULT 'guest',
          name TEXT NOT NULL,
          description TEXT NOT NULL DEFAULT '',
          artwork_uri TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL,
          is_system INTEGER NOT NULL DEFAULT 0,
          is_deleted INTEGER NOT NULL DEFAULT 0
        );
      ''');

      rawSqlite.execute('''
        CREATE TABLE db_playlist_entries (
          id TEXT NOT NULL PRIMARY KEY,
          playlist_id TEXT NOT NULL,
          track_id TEXT NOT NULL,
          position INTEGER NOT NULL,
          date_added INTEGER NOT NULL
        );
      ''');

      rawSqlite.execute('''
        CREATE TABLE db_queue_state (
          profile_id TEXT NOT NULL PRIMARY KEY,
          current_index INTEGER NOT NULL DEFAULT -1,
          repeat_mode TEXT NOT NULL DEFAULT 'off',
          is_shuffle INTEGER NOT NULL DEFAULT 0,
          position_ms INTEGER NOT NULL DEFAULT 0,
          is_playing INTEGER NOT NULL DEFAULT 0
        );
      ''');

      rawSqlite.execute('''
        CREATE TABLE db_search_history (
          id TEXT NOT NULL PRIMARY KEY,
          profile_id TEXT NOT NULL DEFAULT 'guest',
          query TEXT NOT NULL,
          created_at INTEGER NOT NULL
        );
      ''');

      rawSqlite.execute('''
        CREATE TABLE db_preferences (
          key TEXT NOT NULL PRIMARY KEY,
          value TEXT NOT NULL,
          updated_at INTEGER NOT NULL
        );
      ''');

      rawSqlite.execute('''
        CREATE TABLE db_sync_outbox (
          id TEXT NOT NULL PRIMARY KEY,
          profile_id TEXT NOT NULL,
          device_id TEXT NOT NULL,
          entity_type TEXT NOT NULL,
          entity_id TEXT NOT NULL,
          operation_type TEXT NOT NULL,
          payload_json TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          retry_count INTEGER NOT NULL DEFAULT 0,
          last_attempt_at INTEGER,
          last_error TEXT,
          idempotency_key TEXT NOT NULL
        );
      ''');

      rawSqlite.execute('''
        CREATE TABLE db_sync_state (
          profile_id TEXT NOT NULL PRIMARY KEY,
          last_synced_at INTEGER,
          last_server_revision INTEGER NOT NULL DEFAULT 0,
          sync_status TEXT NOT NULL DEFAULT 'idle',
          error_message TEXT
        );
      ''');

      rawSqlite.execute('''
        CREATE TABLE db_tombstones (
          id TEXT NOT NULL PRIMARY KEY,
          profile_id TEXT NOT NULL,
          entity_type TEXT NOT NULL,
          entity_id TEXT NOT NULL,
          deleted_at INTEGER NOT NULL
        );
      ''');

      rawSqlite.execute('''
        CREATE TABLE db_cache_entries (
          track_id TEXT NOT NULL PRIMARY KEY,
          cache_key TEXT NOT NULL,
          file_path TEXT NOT NULL,
          content_size_bytes INTEGER NOT NULL,
          mime_type TEXT NOT NULL DEFAULT 'audio/mpeg',
          duration_ms INTEGER,
          provider_id TEXT NOT NULL,
          download_state TEXT NOT NULL DEFAULT 'availableOffline',
          sha256_hash TEXT,
          cached_at INTEGER NOT NULL,
          last_accessed_at INTEGER NOT NULL
        );
      ''');

      rawSqlite.execute('PRAGMA user_version = 3;');
      rawSqlite.close();

      // Now open through CaviaDatabase which will trigger Drift onUpgrade(from: 3, to: 4)
      final caviaDb = CaviaDatabase(NativeDatabase(tempFile));

      // Verify selecting tracks does not throw duplicate column exception
      final tracks = await caviaDb.select(caviaDb.dbTracks).get();
      expect(tracks, isEmpty);

      // Verify user_version is now 4
      final versionResult = await caviaDb.customSelect('PRAGMA user_version;').getSingle();
      expect(versionResult.data['user_version'], equals(4));

      // Verify V4 indexes exist on the db_* tables
      final indexes = await caviaDb.customSelect(
        "SELECT name FROM sqlite_master WHERE type='index';",
      ).get();
      final indexNames = indexes.map((row) => row.read<String>('name')).toSet();
      expect(indexNames, contains('idx_tracks_provider'));
      expect(indexNames, contains('idx_tracks_album'));
      expect(indexNames, contains('idx_tracks_last_played'));
      expect(indexNames, contains('idx_entries_playlist_pos'));
      expect(indexNames, contains('idx_playlists_profile'));
      expect(indexNames, contains('idx_search_history_profile'));

      await caviaDb.close();
      await tempDir.delete(recursive: true);
    });

    test('Successfully opens and migrates the user disk database if present', () async {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile == null) return;
      final file = File('$userProfile\\Documents\\cavia_music.sqlite');
      if (!await file.exists()) return;

      final db = CaviaDatabase(NativeDatabase(file));
      final versionResult = await db.customSelect('PRAGMA user_version;').getSingle();
      expect(versionResult.data['user_version'], equals(4));

      final tracks = await db.select(db.dbTracks).get();
      expect(tracks, isA<List>());

      await db.close();
    });
  });
}
