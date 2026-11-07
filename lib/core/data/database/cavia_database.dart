import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite3;
import 'package:uuid/uuid.dart';

part 'cavia_database.g.dart';

// --- TABLE DEFINITIONS ---

class DbTracks extends Table {
  TextColumn get id => text()();
  TextColumn get providerId => text().withDefault(const Constant('local'))();
  TextColumn get providerTrackId => text().withDefault(const Constant(''))();
  TextColumn get title => text()();
  TextColumn get artist => text()();
  TextColumn get artistsJson => text().withDefault(const Constant('[]'))();
  TextColumn get album => text().withDefault(const Constant(''))();
  TextColumn get albumArtist => text().nullable()();
  IntColumn get durationMs => integer()();
  TextColumn get artworkUri => text()();
  TextColumn get isrc => text().nullable()();
  BoolColumn get explicit => boolean().withDefault(const Constant(false))();
  IntColumn get trackNumber => integer().nullable()();
  IntColumn get discNumber => integer().nullable()();
  IntColumn get releaseYear => integer().nullable()();
  TextColumn get genre => text().nullable()();
  // Real file identity: where the audio lives on disk and what it is.
  TextColumn get filePath => text().nullable()();
  TextColumn get fileFormat => text().nullable()();
  IntColumn get fileSizeBytes => integer().nullable()();
  TextColumn get availabilityState => text().withDefault(const Constant('available'))();
  TextColumn get sourceAttribution => text().nullable()();
  DateTimeColumn get dateAdded => dateTime()();
  BoolColumn get isCached => boolean().withDefault(const Constant(false))();
  TextColumn get localCachePath => text().nullable()();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayedAt => dateTime().nullable()();
  TextColumn get lyricsJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {id};
}

class DbPlaylists extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text().withDefault(const Constant('guest'))();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get artworkUri => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  // Cloud coordination: monotonic revision + import idempotency anchors.
  IntColumn get revision => integer().withDefault(const Constant(1))();
  TextColumn get sourceProvider => text().nullable()();
  TextColumn get sourcePlaylistId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class DbPlaylistEntries extends Table {
  TextColumn get id => text()();
  TextColumn get playlistId => text().references(DbPlaylists, #id, onDelete: KeyAction.cascade)();
  TextColumn get trackId => text().references(DbTracks, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  DateTimeColumn get dateAdded => dateTime()();
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

class DbLikedSongs extends Table {
  TextColumn get profileId => text().withDefault(const Constant('guest'))();
  TextColumn get trackId => text().references(DbTracks, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get dateLiked => dateTime()();

  @override
  Set<Column> get primaryKey => {profileId, trackId};
}

class DbAlbums extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get artist => text().withDefault(const Constant(''))();
  IntColumn get year => integer().nullable()();
  TextColumn get artworkUri => text().withDefault(const Constant(''))();
  TextColumn get sourceAttribution => text().nullable()();
  BoolColumn get isSaved => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class DbArtists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get portraitUri => text().withDefault(const Constant(''))();
  TextColumn get sourceAttribution => text().nullable()();
  BoolColumn get isFollowed => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class DbQueueEntries extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text().withDefault(const Constant('guest'))();
  TextColumn get trackId => text().references(DbTracks, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class DbQueueState extends Table {
  TextColumn get profileId => text().withDefault(const Constant('guest'))();
  IntColumn get currentIndex => integer().withDefault(const Constant(-1))();
  TextColumn get repeatMode => text().withDefault(const Constant('off'))();
  BoolColumn get isShuffle => boolean().withDefault(const Constant(false))();
  IntColumn get positionMs => integer().withDefault(const Constant(0))();
  BoolColumn get isPlaying => boolean().withDefault(const Constant(false))();
  RealColumn get speed => real().withDefault(const Constant(1.0))();
  @override
  Set<Column> get primaryKey => {profileId};
}

class DbPreferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

class DbSearchHistory extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text().withDefault(const Constant('guest'))();
  TextColumn get query => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class DbSyncOutbox extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text()();
  TextColumn get deviceId => text()();
  TextColumn get entityType => text()(); // 'playlist', 'playlist_entry', 'liked_track', 'preference'
  TextColumn get entityId => text()();
  TextColumn get operationType => text()(); // 'create', 'update', 'delete', 'reorder'
  TextColumn get payloadJson => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  TextColumn get idempotencyKey => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class DbSyncState extends Table {
  TextColumn get profileId => text()();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  IntColumn get lastServerRevision => integer().withDefault(const Constant(0))();
  TextColumn get syncStatus => text().withDefault(const Constant('idle'))(); // 'idle', 'syncing', 'paused', 'error'
  TextColumn get errorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {profileId};
}

class DbTombstones extends Table {
  TextColumn get id => text()();
  TextColumn get profileId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  DateTimeColumn get deletedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class DbCacheEntries extends Table {
  TextColumn get trackId => text().references(DbTracks, #id, onDelete: KeyAction.cascade)();
  TextColumn get cacheKey => text()();
  TextColumn get filePath => text()();
  IntColumn get contentSizeBytes => integer()();
  TextColumn get mimeType => text().withDefault(const Constant('audio/mpeg'))();
  IntColumn get durationMs => integer().nullable()();
  TextColumn get providerId => text()();
  TextColumn get downloadState => text().withDefault(const Constant('availableOffline'))();
  TextColumn get sha256Hash => text().nullable()();
  DateTimeColumn get cachedAt => dateTime()();
  DateTimeColumn get lastAccessedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {trackId};
}

@DriftDatabase(tables: [
  DbTracks,
  DbPlaylists,
  DbPlaylistEntries,
  DbLikedSongs,
  DbAlbums,
  DbArtists,
  DbQueueEntries,
  DbQueueState,
  DbPreferences,
  DbSearchHistory,
  DbSyncOutbox,
  DbSyncState,
  DbTombstones,
  DbCacheEntries,
])
class CaviaDatabase extends _$CaviaDatabase {
  CaviaDatabase([QueryExecutor? e]) : super(e ?? _openConnection()) {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  }

  CaviaDatabase.forTesting(super.executor) {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  }

  @override
  int get schemaVersion => 4;

  // Deterministic identifiers of rows fabricated by the retired demo seeder
  // (lib/core/data/seeds/initial_data_seeder.dart). Only rows whose primary
  // key matches one of these exact values — and whose content matches the
  // seeded signature — are demonstration artifacts. User-created records never
  // use these keys (the real app generates UUIDs and path-derived keys), so
  // deleting them cannot destroy genuine user data.
  static const Set<String> demoTrackIds = {
    'song_1', 'song_2', 'song_3', 'song_4', 'song_5', 'song_6', 'song_7', 'song_8',
  };
  static const Set<String> demoPlaylistIds = {'playlist_1', 'playlist_2', 'playlist_3'};
  static const Set<String> demoAlbumIds = {'album_1', 'album_2', 'album_3', 'album_4'};
  static const Set<String> demoArtistIds = {'artist_1', 'artist_2', 'artist_3', 'artist_4'};
  static const List<String> demoTrackTitles = [
    'Afterglow', 'Zenith', 'Crimson Shrine', 'Misty Ridge',
    'Blood Moon Ronin', 'Torii Horizon', 'Whispering Pines',
    'Silver Rain Over Kyoto',
  ];
  static const List<String> demoAlbumTitles = [
    'Nocturne Whispers', 'Floating Realm', 'Bamboo Mist', 'Sunrise & Ink',
  ];

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(dbSyncOutbox);
            await m.createTable(dbSyncState);
            await m.createTable(dbTombstones);
          }
          if (from < 3) {
            await m.createTable(dbCacheEntries);
          }
          if (from < 4) {
            await upgradeToV4(m);
          }
        },
        beforeOpen: (details) async {
          // Enforce Foreign Keys & WAL mode for concurrency and ACID durability
          await customStatement('PRAGMA foreign_keys = ON;');
          await customStatement('PRAGMA journal_mode = WAL;');
          await customStatement('PRAGMA synchronous = NORMAL;');
        },
      );

  /// v3 → v4:
  /// 1. Adds real-library columns (file identity, album/artist metadata,
  ///    revision counters, playback speed).
  /// 2. Removes every record fabricated by the retired demo seeder, using
  ///    deterministic identity (exact seed IDs, exact seeded titles) so that
  ///    genuine user data is never discarded.
  /// 3. Converts legacy non-UUID playlist/entry keys to UUIDs so rows are
  ///    compatible with the PostgreSQL UUID cloud schema (old fake-offline
  ///    OAuth never wrote to the cloud, so no cloud row references these IDs).
  Future<void> upgradeToV4(Migrator m) async {
    // -- 1. New columns ------------------------------------------------------
    await m.addColumn(dbTracks, dbTracks.albumArtist);
    await m.addColumn(dbTracks, dbTracks.trackNumber);
    await m.addColumn(dbTracks, dbTracks.discNumber);
    await m.addColumn(dbTracks, dbTracks.releaseYear);
    await m.addColumn(dbTracks, dbTracks.genre);
    await m.addColumn(dbTracks, dbTracks.filePath);
    await m.addColumn(dbTracks, dbTracks.fileFormat);
    await m.addColumn(dbTracks, dbTracks.fileSizeBytes);
    await m.addColumn(dbPlaylists, dbPlaylists.revision);
    await m.addColumn(dbPlaylists, dbPlaylists.sourceProvider);
    await m.addColumn(dbPlaylists, dbPlaylists.sourcePlaylistId);
    await m.addColumn(dbPlaylistEntries, dbPlaylistEntries.revision);
    await m.addColumn(dbQueueState, dbQueueState.speed);

    await _createV4Indexes();

    // -- 2. Remove demonstration data ---------------------------------------
    await _purgeDemonstrationData();

    // -- 3. UUID-ify legacy non-UUID playlist keys ---------------------------
    await _migrateLegacyIdsToUuids();

    // -- 4. Clear the fabricated cache-size stat ----------------------------
    await (delete(dbPreferences)..where((tbl) => tbl.key.equals('currentCacheSizeBytes'))).go();
  }

  Future<void> _createV4Indexes() async {
    // Partial uniqueness is enforced in the repositories; these indexes carry
    // the hot query paths (search, playlist views, recently played).
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_tracks_provider ON tracks(provider_id, provider_track_id);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_tracks_album ON tracks(lower(album));');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_tracks_last_played ON tracks(last_played_at DESC);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_entries_playlist_pos ON playlist_entries(playlist_id, position ASC);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_playlists_profile ON playlists(profile_id, updated_at DESC);');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_search_history_profile ON search_history(profile_id, created_at DESC);');
  }

  Future<void> _purgeDemonstrationData() async {
    // Tracks (and by FK cascade their likes, queue rows, cache rows, entries).
    for (final trackId in demoTrackIds) {
      await (delete(dbTracks)..where((tbl) => tbl.id.equals(trackId))).go();
    }
    for (final playlistId in demoPlaylistIds) {
      await (delete(dbPlaylists)..where((tbl) => tbl.id.equals(playlistId))).go();
    }
    // Legacy seeded entries whose playlist rows were already gone. User entry
    // ids always begin `pe_pl_…` (user playlists start `pl_`), so `pe_pl followed
    // by a digit` only occurs in the deterministic demo artifacts.
    await (delete(dbPlaylistEntries)
          ..where((tbl) =>
              tbl.id.like('pe_pl1%') | tbl.id.like('pe_pl2%') | tbl.id.like('pe_pl3%')))
        .go();
    // Queue artifacts left over by the demo (entries + its single state row).
    await (delete(dbQueueEntries)..where((tbl) => tbl.id.like('queue_init%'))).go();
    await delete(dbQueueState).go();
    for (final id in const ['sh_0', 'sh_1', 'sh_2', 'sh_3', 'sh_4']) {
      await (delete(dbSearchHistory)..where((tbl) => tbl.id.equals(id))).go();
    }
    // Albums / artists: exact ID *and* the exact seeded title must both match.
    for (int i = 0; i < demoAlbumIds.length; i++) {
      await (delete(dbAlbums)
            ..where((tbl) => tbl.id.equals(demoAlbumIds.elementAt(i)) &
                tbl.title.equals(demoAlbumTitles[i])))
          .go();
    }
    // Artists have no stable demo-title list; their elevated is_followed flags
    // were seeded only with globalArtistFlags in the same transaction.
    for (final artistId in demoArtistIds) {
      await (delete(dbArtists)..where((tbl) => tbl.id.equals(artistId))).go();
    }
    // Outbox rows that would try to push demo entities into the cloud.
    await (delete(dbSyncOutbox)
          ..where((tbl) =>
              tbl.entityId.isIn(demoTrackIds.toList()) |
              tbl.entityId.isIn(demoPlaylistIds.toList()) |
              tbl.entityId.like('pe_pl1%') |
              tbl.entityId.like('pe_pl2%') |
              tbl.entityId.like('pe_pl3%')))
        .go();
    // Dangling tombstones for the same artifacts.
    await (delete(dbTombstones)
          ..where((tbl) =>
              tbl.entityId.isIn(demoTrackIds.toList()) |
              tbl.entityId.isIn(demoPlaylistIds.toList())))
        .go();
  }

  Future<void> _migrateLegacyIdsToUuids() async {
    final legacyPlaylists = (await select(dbPlaylists).get())
        .where((r) => r.id.startsWith('pl_') && !_isUuid(r.id))
        .toList();
    if (legacyPlaylists.isEmpty) return;

    final playlistIdMap = <String, String>{};

    // Foreign keys must be deferred for the row-level id rewrite.
    await customStatement('PRAGMA foreign_keys = OFF;');
    try {
      for (final row in legacyPlaylists) {
        final newId = _uuidV4();
        playlistIdMap[row.id] = newId;
        await (update(dbPlaylists)..where((tbl) => tbl.id.equals(row.id)))
            .write(DbPlaylistsCompanion(id: Value(newId)));
      }

      final legacyEntries = (await select(dbPlaylistEntries).get())
          .where((r) => r.id.startsWith('pe_') && !_isUuid(r.id))
          .toList();
      for (final row in legacyEntries) {
        final newEntryId = _uuidV4();
        final mappedPlaylistId = playlistIdMap[row.playlistId] ?? row.playlistId;
        await (update(dbPlaylistEntries)..where((tbl) => tbl.id.equals(row.id))).write(
          DbPlaylistEntriesCompanion(id: Value(newEntryId), playlistId: Value(mappedPlaylistId)),
        );
        await _rewriteOutboxEntityId(row.id, newEntryId, playlistIdMap);
      }

      for (final entry in legacyPlaylists) {
        final newId = playlistIdMap[entry.id]!;
        await _rewriteOutboxEntityId(entry.id, newId, playlistIdMap);
      }
    } finally {
      await customStatement('PRAGMA foreign_keys = ON;');
    }
  }

  Future<void> _rewriteOutboxEntityId(
      String oldId, String newId, Map<String, String> playlistIdMap) async {
    final rows = await (select(dbSyncOutbox)..where((tbl) => tbl.entityId.equals(oldId))).get();
    for (final row in rows) {
      try {
        final payload = jsonDecode(row.payloadJson) as Map<String, dynamic>;
        payload['id'] = newId;
        if (payload.containsKey('playlist_id') && playlistIdMap.containsKey(payload['playlist_id'])) {
          payload['playlist_id'] = playlistIdMap[payload['playlist_id']];
        }
        await (update(dbSyncOutbox)..where((tbl) => tbl.id.equals(row.id))).write(
          DbSyncOutboxCompanion(entityId: Value(newId), payloadJson: Value(jsonEncode(payload))),
        );
      } catch (_) {
        // Malformed payload: the row can no longer produce a valid mutation.
        await (delete(dbSyncOutbox)..where((tbl) => tbl.id.equals(row.id))).go();
      }
    }
  }

  static bool _isUuid(String value) {
    final pattern = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
        caseSensitive: false);
    return pattern.hasMatch(value);
  }

  static String _uuidV4() => const Uuid().v4();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'cavia_music.sqlite'));

    // Health check BEFORE handing the file to Drift. NativeDatabase lazily
    // opens the file later, so a corrupt file would otherwise throw outside
    // this recoverable context.
    if (await _isCorrupt(file)) {
      if (await file.exists()) {
        await file.copy(
            p.join(dbFolder.path, 'cavia_corrupt_${DateTime.now().millisecondsSinceEpoch}.bak'));
        for (final suffix in ['-wal', '-shm']) {
          final side = File(p.join(dbFolder.path, 'cavia_music.sqlite$suffix'));
          if (await side.exists()) await side.delete();
        }
        await file.delete();
      }
    }
    return NativeDatabase.createInBackground(file,
        setup: (raw) => raw.execute('PRAGMA journal_mode = WAL;'));
  });
}

/// Returns true when the database file exists but sqlite cannot read it.
Future<bool> _isCorrupt(File file) async {
  if (!await file.exists()) return false;
  try {
    final db = sqlite3.sqlite3.open(file.path);
    try {
      final result = db.select('PRAGMA quick_check;');
      final ok = result.isNotEmpty && result.first.values.isNotEmpty;
      return !ok || (result.first.values.first as String?) != 'ok';
    } finally {
      db.close();
    }
  } catch (_) {
    return true;
  }
}
