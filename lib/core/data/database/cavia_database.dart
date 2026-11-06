import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'cavia_database.g.dart';

// --- TABLE DEFINITIONS ---

class DbTracks extends Table {
  TextColumn get id => text()();
  TextColumn get providerId => text().withDefault(const Constant('local'))();
  TextColumn get providerTrackId => text().withDefault(const Constant(''))();
  TextColumn get title => text()();
  TextColumn get artist => text()();
  TextColumn get artistsJson => text().withDefault(const Constant('[]'))();
  TextColumn get album => text()();
  IntColumn get durationMs => integer()();
  TextColumn get artworkUri => text()();
  TextColumn get isrc => text().nullable()();
  BoolColumn get explicit => boolean().withDefault(const Constant(false))();
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

  @override
  Set<Column> get primaryKey => {id};
}

class DbPlaylistEntries extends Table {
  TextColumn get id => text()();
  TextColumn get playlistId => text().references(DbPlaylists, #id, onDelete: KeyAction.cascade)();
  TextColumn get trackId => text().references(DbTracks, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  DateTimeColumn get dateAdded => dateTime()();

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
  TextColumn get artist => text()();
  IntColumn get year => integer()();
  TextColumn get artworkUri => text()();
  TextColumn get sourceAttribution => text().nullable()();
  BoolColumn get isSaved => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class DbArtists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get portraitUri => text()();
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
  int get schemaVersion => 3;

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
        },
        beforeOpen: (details) async {
          // Enforce Foreign Keys & WAL mode for concurrency and ACID durability
          await customStatement('PRAGMA foreign_keys = ON;');
          await customStatement('PRAGMA journal_mode = WAL;');
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'cavia_music.sqlite'));

    // Check if recovery is required from a previous corrupt write
    try {
      return NativeDatabase.createInBackground(file);
    } catch (e) {
      // Recovery fallback: Backup corrupted database and start clean
      if (await file.exists()) {
        final backupName = 'cavia_corrupt_${DateTime.now().millisecondsSinceEpoch}.bak';
        await file.copy(p.join(dbFolder.path, backupName));
        await file.delete();
      }
      return NativeDatabase.createInBackground(file);
    }
  });
}
