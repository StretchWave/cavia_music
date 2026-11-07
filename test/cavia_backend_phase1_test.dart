import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cavia_music/core/data/database/cavia_database.dart';
import 'package:cavia_music/core/data/repositories/local_track_repository.dart';
import 'package:cavia_music/core/data/repositories/local_playlist_repository.dart';
import 'package:cavia_music/core/data/repositories/local_queue_repository.dart';
import 'package:cavia_music/core/data/repositories/local_settings_repository.dart';
import 'package:cavia_music/core/data/repositories/local_search_repository.dart';
import 'package:cavia_music/core/data/seeds/initial_data_seeder.dart';
import 'package:cavia_music/core/domain/models/track.dart';
import 'package:cavia_music/core/domain/models/playback_queue.dart';
import 'package:cavia_music/core/domain/result/app_error.dart';

void main() {
  late CaviaDatabase db;
  late LocalTrackRepository trackRepo;
  late LocalPlaylistRepository playlistRepo;
  late LocalQueueRepository queueRepo;
  late LocalSettingsRepository settingsRepo;
  late LocalSearchRepository searchRepo;

  setUp(() async {
    db = CaviaDatabase.forTesting(NativeDatabase.memory());
    trackRepo = LocalTrackRepository(db);
    playlistRepo = LocalPlaylistRepository(db);
    queueRepo = LocalQueueRepository(db);
    settingsRepo = LocalSettingsRepository(db);
    searchRepo = LocalSearchRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Track Repository & Liked Songs Tests', () {
    final sampleTrack = Track(
      id: 'trk_test_1',
      providerId: 'local',
      providerTrackId: 'pt_1',
      title: 'Solitary Pine',
      artist: 'Kenshi Yonezu',
      album: 'Nocturne Whispers',
      duration: const Duration(minutes: 3, seconds: 40),
      artworkUri: 'assets/images/cover_afterglow.jpg',
      dateAdded: DateTime.now(),
    );

    test('Track CRUD and Liked Songs duplicate prevention', () async {
      // 1. Insert Track
      final insertRes = await trackRepo.insertTrack(sampleTrack);
      expect(insertRes.isSuccess, true);

      final fetchRes = await trackRepo.getTrackById('trk_test_1');
      expect(fetchRes.isSuccess, true);
      expect(fetchRes.dataOrNull!.title, 'Solitary Pine');
      expect(fetchRes.dataOrNull!.isLiked, false);

      // 2. Like Track
      final like1 = await trackRepo.toggleLike('trk_test_1');
      expect(like1.isSuccess, true);
      expect(like1.dataOrNull, true);

      final likedCheck1 = await trackRepo.isTrackLiked('trk_test_1');
      expect(likedCheck1.dataOrNull, true);

      // Verify no duplicate in liked_songs table
      final likedRows = await (db.select(db.dbLikedSongs)
            ..where((tbl) => tbl.trackId.equals('trk_test_1') & tbl.profileId.equals('guest')))
          .get();
      expect(likedRows.length, 1);

      // 3. Unlike Track
      final unlike = await trackRepo.toggleLike('trk_test_1');
      expect(unlike.isSuccess, true);
      expect(unlike.dataOrNull, false);

      final likedCheck2 = await trackRepo.isTrackLiked('trk_test_1');
      expect(likedCheck2.dataOrNull, false);
    });

    test('Unliking a track does NOT delete it from playlists', () async {
      await trackRepo.insertTrack(sampleTrack);

      // Create playlist
      final plRes = await playlistRepo.createPlaylist('Zenith Sanctuary');
      expect(plRes.isSuccess, true);
      final playlist = plRes.dataOrNull!;

      // Add track to playlist
      final addRes = await playlistRepo.addTrackToPlaylist(playlist.id, sampleTrack.id);
      expect(addRes.isSuccess, true);

      // Like track
      await trackRepo.toggleLike(sampleTrack.id);

      // Now unlike track
      await trackRepo.toggleLike(sampleTrack.id);

      // Check track is still in the playlist
      final entriesRes = await playlistRepo.getPlaylistEntries(playlist.id);
      expect(entriesRes.isSuccess, true);
      expect(entriesRes.dataOrNull!.length, 1);
      expect(entriesRes.dataOrNull!.first.trackId, sampleTrack.id);
      expect(entriesRes.dataOrNull!.first.track!.title, 'Solitary Pine');
      expect(entriesRes.dataOrNull!.first.track!.isLiked, false);
    });
  });

  group('Playlist Repository Tests', () {
    final trackA = Track(
      id: 'trk_a',
      title: 'Rain over Kyoto',
      artist: 'Joe Hisaishi',
      album: 'Dream Songs',
      duration: const Duration(minutes: 4),
      artworkUri: 'assets/images/cover_zenith.jpg',
      dateAdded: DateTime.now(),
    );
    final trackB = Track(
      id: 'trk_b',
      title: 'Mist of Nara',
      artist: 'Ryuichi Sakamoto',
      album: 'Bamboo Mist',
      duration: const Duration(minutes: 5),
      artworkUri: 'assets/images/cover_shrine.jpg',
      dateAdded: DateTime.now(),
    );

    setUp(() async {
      await trackRepo.insertTrack(trackA);
      await trackRepo.insertTrack(trackB);
    });

    test('Playlist creation validation rejects empty or whitespace names', () async {
      final emptyRes = await playlistRepo.createPlaylist('');
      expect(emptyRes.isFailure, true);
      expect(emptyRes.errorOrNull, isA<ValidationError>());

      final wsRes = await playlistRepo.createPlaylist('   \n\t  ');
      expect(wsRes.isFailure, true);
      expect(wsRes.errorOrNull, isA<ValidationError>());

      final validRes = await playlistRepo.createPlaylist('  Torii Gate Beats  ');
      expect(validRes.isSuccess, true);
      expect(validRes.dataOrNull!.name, 'Torii Gate Beats');
    });

    test('Permits deliberate duplicate track entries with independent entry IDs', () async {
      final plRes = await playlistRepo.createPlaylist('Loop Playlist');
      final playlist = plRes.dataOrNull!;

      // Add track A twice
      final entry1 = await playlistRepo.addTrackToPlaylist(playlist.id, trackA.id);
      final entry2 = await playlistRepo.addTrackToPlaylist(playlist.id, trackA.id);

      expect(entry1.isSuccess, true);
      expect(entry2.isSuccess, true);

      // Both entries exist with unique IDs and distinct positions
      expect(entry1.dataOrNull!.id != entry2.dataOrNull!.id, true);
      expect(entry1.dataOrNull!.position, 0);
      expect(entry2.dataOrNull!.position, 1);

      final entries = await playlistRepo.getPlaylistEntries(playlist.id);
      expect(entries.dataOrNull!.length, 2);
      expect(entries.dataOrNull![0].trackId, trackA.id);
      expect(entries.dataOrNull![1].trackId, trackA.id);
    });

    test('Playlist reordering and cascade deletion', () async {
      final plRes = await playlistRepo.createPlaylist('Ordered Playlist');
      final playlist = plRes.dataOrNull!;

      await playlistRepo.addTrackToPlaylist(playlist.id, trackA.id); // pos 0
      await playlistRepo.addTrackToPlaylist(playlist.id, trackB.id); // pos 1

      // Reorder track 0 to position 1
      final reorderRes = await playlistRepo.reorderPlaylistEntries(playlist.id, 0, 2);
      expect(reorderRes.isSuccess, true);

      final reorderedEntries = await playlistRepo.getPlaylistEntries(playlist.id);
      expect(reorderedEntries.dataOrNull![0].trackId, trackB.id);
      expect(reorderedEntries.dataOrNull![1].trackId, trackA.id);

      // Cascade deletion: deleting playlist deletes its entries
      final deleteRes = await playlistRepo.deletePlaylist(playlist.id);
      expect(deleteRes.isSuccess, true);

      final orphanedEntries = await (db.select(db.dbPlaylistEntries)
            ..where((tbl) => tbl.playlistId.equals(playlist.id)))
          .get();
      expect(orphanedEntries.isEmpty, true);
    });

    test('System collections cannot be deleted', () async {
      // Insert a system playlist
      await db.into(db.dbPlaylists).insert(
            DbPlaylistsCompanion.insert(
              id: 'pl_system_liked',
              name: 'Liked Songs Collection',
              artworkUri: 'assets/images/cover_zenith.jpg',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              isSystem: const Value(true),
            ),
          );

      final delRes = await playlistRepo.deletePlaylist('pl_system_liked');
      expect(delRes.isFailure, true);
      expect(delRes.errorOrNull, isA<OperationProhibitedError>());
    });
  });

  group('Playback Queue Persistence Tests', () {
    final track1 = Track(
      id: 'trk_q1',
      title: 'Afterglow',
      artist: 'Luna Caine',
      album: 'Nocturne Whispers',
      duration: const Duration(minutes: 4, seconds: 9),
      artworkUri: 'assets/images/cover_afterglow.jpg',
      dateAdded: DateTime.now(),
    );
    final track2 = Track(
      id: 'trk_q2',
      title: 'Zenith',
      artist: 'Kenshi Yonezu',
      album: 'Floating Realm',
      duration: const Duration(minutes: 3, seconds: 45),
      artworkUri: 'assets/images/cover_zenith.jpg',
      dateAdded: DateTime.now(),
    );

    setUp(() async {
      await trackRepo.insertTrack(track1);
      await trackRepo.insertTrack(track2);
    });

    test('Queue saves and restores state across application restarts', () async {
      final queueState = PlaybackQueueState(
        currentIndex: 1,
        position: const Duration(seconds: 45),
        repeatMode: CaviaRepeatMode.all,
        isShuffle: true,
        isPlaying: false,
        items: [
          QueueItem(id: 'qi_1', trackId: track1.id, position: 0, track: track1),
          QueueItem(id: 'qi_2', trackId: track2.id, position: 1, track: track2),
        ],
      );

      final saveRes = await queueRepo.saveQueue(queueState);
      expect(saveRes.isSuccess, true);

      // Simulate a restart with a new repository instance pointing to the same DB
      final restartedRepo = LocalQueueRepository(db);
      final loadRes = await restartedRepo.loadQueue();
      expect(loadRes.isSuccess, true);

      final restored = loadRes.dataOrNull!;
      expect(restored.currentIndex, 1);
      expect(restored.position.inSeconds, 45);
      expect(restored.repeatMode, CaviaRepeatMode.all);
      expect(restored.isShuffle, true);
      expect(restored.items.length, 2);
      expect(restored.items[0].track!.title, 'Afterglow');
      expect(restored.items[1].track!.title, 'Zenith');
    });

    test('Clear queue resets state', () async {
      await queueRepo.saveQueue(
        PlaybackQueueState(
          currentIndex: 0,
          position: Duration.zero,
          repeatMode: CaviaRepeatMode.off,
          items: [
            QueueItem(id: 'qi_1', trackId: track1.id, position: 0, track: track1),
          ],
        ),
      );

      final clearRes = await queueRepo.clearQueue();
      expect(clearRes.isSuccess, true);

      final loadRes = await queueRepo.loadQueue();
      expect(loadRes.isSuccess, true);
      expect(loadRes.dataOrNull!.items.isEmpty, true);
      expect(loadRes.dataOrNull!.currentIndex, -1);
    });
  });

  group('Search Repository Tests', () {
    setUp(() async {
      final seeder = InitialDataSeeder(db);
      await seeder.seedIfNeeded();
    });

    test('Case-insensitive and partial search for tracks, albums, artists, playlists', () async {
      // 1. Search Kenshi (lowercase)
      final search1 = await searchRepo.search('kenshi');
      expect(search1.isSuccess, true);
      final results1 = search1.dataOrNull!;
      expect(results1.songs.any((s) => s.artist.contains('Kenshi Yonezu')), true);
      expect(results1.artists.any((a) => a.name.contains('Kenshi Yonezu')), true);

      // 2. Search Kyoto (uppercase)
      final search2 = await searchRepo.search('KYOTO');
      expect(search2.isSuccess, true);
      final results2 = search2.dataOrNull!;
      expect(results2.songs.any((s) => s.title.contains('Silver Rain Over Kyoto')), true);

      // 3. Search Playlist by partial keyword 'ink'
      final search3 = await searchRepo.search('ink');
      expect(search3.isSuccess, true);
      final results3 = search3.dataOrNull!;
      expect(results3.playlists.any((p) => p.name.contains('Midnight Ink & Rain')), true);
    });

    test('Search history addition, limit of 10, duplicate deduplication, and removal', () async {
      await searchRepo.clearSearchHistory();

      // Add 12 items
      for (int i = 1; i <= 12; i++) {
        await searchRepo.addSearchQuery('Query $i');
      }

      final streamHistory = await searchRepo.watchSearchHistory().first;
      // Should cap at 10 items
      expect(streamHistory.length, 10);
      expect(streamHistory.first, 'Query 12');

      // Adding existing query moves it to top without duplicating
      await searchRepo.addSearchQuery('Query 5');
      final reordered = await searchRepo.watchSearchHistory().first;
      expect(reordered.first, 'Query 5');
      expect(reordered.where((q) => q == 'Query 5').length, 1);

      // Remove specific query
      await searchRepo.removeSearchQuery('Query 5');
      final afterRemove = await searchRepo.watchSearchHistory().first;
      expect(afterRemove.contains('Query 5'), false);
    });
  });

  group('Profile Isolation Tests', () {
    test('Library data is strictly isolated between guest and authenticated profiles', () async {
      final seeder = InitialDataSeeder(db);
      await seeder.seedIfNeeded(profileId: 'guest');

      // Guest playlists
      final guestPlaylists = await playlistRepo.getAllPlaylists(profileId: 'guest');
      expect(guestPlaylists.dataOrNull!.isNotEmpty, true);

      // User 123 playlists
      final userPlaylists = await playlistRepo.getAllPlaylists(profileId: 'user_123');
      expect(userPlaylists.dataOrNull!.isEmpty, true);

      // Create playlist for user_123
      final createdUser = await playlistRepo.createPlaylist(
        'User 123 Private Sanctuary',
        profileId: 'user_123',
      );
      expect(createdUser.isSuccess, true);

      // Guest still only sees guest playlists
      final guestCheck = await playlistRepo.getAllPlaylists(profileId: 'guest');
      expect(guestCheck.dataOrNull!.any((p) => p.name == 'User 123 Private Sanctuary'), false);

      // User 123 only sees user_123 playlist
      final userCheck = await playlistRepo.getAllPlaylists(profileId: 'user_123');
      expect(userCheck.dataOrNull!.length, 1);
      expect(userCheck.dataOrNull!.first.name, 'User 123 Private Sanctuary');
    });
  });

  group('Settings & Storage Integrity Tests', () {
    test('Offline caching toggle does NOT delete cache quota', () async {
      final initialPrefs = await settingsRepo.getPreferences();
      expect(initialPrefs.offlineCaching, true);
      expect(initialPrefs.cacheQuotaBytes > 0, true);

      // Disable caching
      await settingsRepo.updatePreferences(initialPrefs.copyWith(offlineCaching: false));
      final disabledPrefs = await settingsRepo.getPreferences();
      expect(disabledPrefs.offlineCaching, false);
      // Existing cache quota remains untouched
      expect(disabledPrefs.cacheQuotaBytes, initialPrefs.cacheQuotaBytes);

      // Clear cache explicitly
      await settingsRepo.clearCache();
      final clearedPrefs = await settingsRepo.getPreferences();
      expect(clearedPrefs.offlineCaching, false);
    });
  });
}
