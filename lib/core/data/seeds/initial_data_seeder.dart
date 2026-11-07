import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/cavia_database.dart';

class InitialDataSeeder {
  final CaviaDatabase db;

  InitialDataSeeder(this.db);

  Future<void> seedIfNeeded({String profileId = 'guest'}) async {
    final existingTracks = await (db.select(db.dbTracks)..limit(1)).get();
    if (existingTracks.isNotEmpty) {
      return; // Already seeded
    }

    await db.transaction(() async {
      // 1. Seed Tracks
      final afterglowLyrics = jsonEncode([
        {'timestampMs': 0, 'text': 'Walking through the lantern light'},
        {'timestampMs': 14000, 'text': 'Shadows dancing on the paper screen'},
        {'timestampMs': 28000, 'text': 'Crimson leaves begin to fall'},
        {'timestampMs': 42000, 'text': 'A distant bell echoes in the mist'},
        {'timestampMs': 58000, 'text': 'In the afterglow of your memory'},
        {'timestampMs': 75000, 'text': 'Night unfolds like black ink on silk'},
        {'timestampMs': 94000, 'text': 'We trace the lines that time forgot'},
        {'timestampMs': 112000, 'text': 'Until the silver moon appears'},
        {'timestampMs': 138000, 'text': 'Standing at the edge of quiet waters'},
        {'timestampMs': 160000, 'text': 'Nothing remains but the crimson embers'},
        {'timestampMs': 185000, 'text': 'And the wind humming in the pines'},
        {'timestampMs': 215000, 'text': 'In the afterglow...'},
        {'timestampMs': 249000, 'text': 'Drifting into the stillness of dawn'},
      ]);

      final tracks = [
        DbTracksCompanion.insert(
          id: 'song_1',
          providerId: const Value('local'),
          providerTrackId: const Value('trk_1'),
          title: 'Afterglow',
          artist: 'Luna Caine',
          artistsJson: Value(jsonEncode(['Luna Caine'])),
          album: 'Nocturne Whispers',
          durationMs: 249000,
          artworkUri: 'assets/images/cover_afterglow.jpg',
          isrc: const Value('US-CAV-24-00001'),
          availabilityState: const Value('available'),
          dateAdded: DateTime.now().subtract(const Duration(days: 10)),
          isCached: const Value(true),
          lyricsJson: Value(afterglowLyrics),
        ),
        DbTracksCompanion.insert(
          id: 'song_2',
          providerId: const Value('local'),
          providerTrackId: const Value('trk_2'),
          title: 'Zenith',
          artist: 'Kenshi Yonezu',
          artistsJson: Value(jsonEncode(['Kenshi Yonezu'])),
          album: 'Floating Realm',
          durationMs: 225000,
          artworkUri: 'assets/images/cover_zenith.jpg',
          isrc: const Value('JP-CAV-24-00002'),
          availabilityState: const Value('available'),
          dateAdded: DateTime.now().subtract(const Duration(days: 8)),
          isCached: const Value(true),
        ),
        DbTracksCompanion.insert(
          id: 'song_3',
          providerId: const Value('local'),
          providerTrackId: const Value('trk_3'),
          title: 'Crimson Shrine',
          artist: 'Ryuichi Sakamoto',
          artistsJson: Value(jsonEncode(['Ryuichi Sakamoto'])),
          album: 'Bamboo Mist',
          durationMs: 312000,
          artworkUri: 'assets/images/cover_shrine.jpg',
          isrc: const Value('JP-CAV-24-00003'),
          availabilityState: const Value('available'),
          dateAdded: DateTime.now().subtract(const Duration(days: 6)),
          isCached: const Value(false),
        ),
        DbTracksCompanion.insert(
          id: 'song_4',
          providerId: const Value('local'),
          providerTrackId: const Value('trk_4'),
          title: 'Misty Ridge',
          artist: 'Nujabes',
          artistsJson: Value(jsonEncode(['Nujabes'])),
          album: 'Modal Soul Reflections',
          durationMs: 262000,
          artworkUri: 'assets/images/cover_mist_mountain.jpg',
          isrc: const Value('JP-CAV-24-00004'),
          availabilityState: const Value('available'),
          dateAdded: DateTime.now().subtract(const Duration(days: 5)),
          isCached: const Value(true),
        ),
        DbTracksCompanion.insert(
          id: 'song_5',
          providerId: const Value('local'),
          providerTrackId: const Value('trk_5'),
          title: 'Blood Moon Ronin',
          artist: 'Tycho',
          artistsJson: Value(jsonEncode(['Tycho'])),
          album: 'Sunrise & Ink',
          durationMs: 238000,
          artworkUri: 'assets/images/cover_crimson_sun.jpg',
          isrc: const Value('US-CAV-24-00005'),
          availabilityState: const Value('available'),
          dateAdded: DateTime.now().subtract(const Duration(days: 4)),
          isCached: const Value(false),
        ),
        DbTracksCompanion.insert(
          id: 'song_6',
          providerId: const Value('local'),
          providerTrackId: const Value('trk_6'),
          title: 'Torii Horizon',
          artist: 'Kavinsky',
          artistsJson: Value(jsonEncode(['Kavinsky'])),
          album: 'Nightcall Tokyo',
          durationMs: 258000,
          artworkUri: 'assets/images/cover_shrine_gate.jpg',
          isrc: const Value('FR-CAV-24-00006'),
          availabilityState: const Value('available'),
          dateAdded: DateTime.now().subtract(const Duration(days: 3)),
          isCached: const Value(false),
        ),
        DbTracksCompanion.insert(
          id: 'song_7',
          providerId: const Value('local'),
          providerTrackId: const Value('trk_7'),
          title: 'Whispering Pines',
          artist: 'Haruomi Hosono',
          artistsJson: Value(jsonEncode(['Haruomi Hosono'])),
          album: 'Cochin Moon Sessions',
          durationMs: 214000,
          artworkUri: 'assets/images/cover_shrine.jpg',
          isrc: const Value('JP-CAV-24-00007'),
          availabilityState: const Value('available'),
          dateAdded: DateTime.now().subtract(const Duration(days: 2)),
          isCached: const Value(false),
        ),
        DbTracksCompanion.insert(
          id: 'song_8',
          providerId: const Value('local'),
          providerTrackId: const Value('trk_8'),
          title: 'Silver Rain Over Kyoto',
          artist: 'Joe Hisaishi',
          artistsJson: Value(jsonEncode(['Joe Hisaishi'])),
          album: 'Dream Songs',
          durationMs: 295000,
          artworkUri: 'assets/images/cover_mist_mountain.jpg',
          isrc: const Value('JP-CAV-24-00008'),
          availabilityState: const Value('available'),
          dateAdded: DateTime.now().subtract(const Duration(days: 1)),
          isCached: const Value(true),
        ),
      ];

      for (final t in tracks) {
        await db.into(db.dbTracks).insert(t);
      }

      // 2. Seed Liked Songs
      final likedTrackIds = ['song_1', 'song_2', 'song_3', 'song_5', 'song_8'];
      for (final tid in likedTrackIds) {
        await db.into(db.dbLikedSongs).insert(
              DbLikedSongsCompanion.insert(
                profileId: Value(profileId),
                trackId: tid,
                dateLiked: DateTime.now().subtract(const Duration(days: 2)),
              ),
            );
      }

      // 3. Seed Playlists
      final now = DateTime.now();
      await db.into(db.dbPlaylists).insert(
            DbPlaylistsCompanion.insert(
              id: 'playlist_1',
              profileId: Value(profileId),
              name: 'Midnight Ink & Rain',
              description: const Value('Atmospheric nocturnal soundscapes for deep focus and solitary travel.'),
              artworkUri: 'assets/images/cover_crimson_sun.jpg',
              createdAt: now.subtract(const Duration(days: 12)),
              updatedAt: now.subtract(const Duration(days: 12)),
            ),
          );

      await db.into(db.dbPlaylists).insert(
            DbPlaylistsCompanion.insert(
              id: 'playlist_2',
              profileId: Value(profileId),
              name: 'Zenith Sanctuary',
              description: const Value('Ethereal ambient Japanese neoclassical and contemplative piano.'),
              artworkUri: 'assets/images/cover_mist_mountain.jpg',
              createdAt: now.subtract(const Duration(days: 34)),
              updatedAt: now.subtract(const Duration(days: 34)),
            ),
          );

      await db.into(db.dbPlaylists).insert(
            DbPlaylistsCompanion.insert(
              id: 'playlist_3',
              profileId: Value(profileId),
              name: 'Torii Echoes',
              description: const Value('Modern beats, lo-fi textures and synthesized sumi-e melodies.'),
              artworkUri: 'assets/images/cover_shrine_gate.jpg',
              createdAt: now.subtract(const Duration(days: 5)),
              updatedAt: now.subtract(const Duration(days: 5)),
            ),
          );

      // Seed Playlist Entries
      final pl1Tracks = ['song_1', 'song_2', 'song_3', 'song_5'];
      for (int i = 0; i < pl1Tracks.length; i++) {
        await db.into(db.dbPlaylistEntries).insert(
              DbPlaylistEntriesCompanion.insert(
                id: 'pe_pl1_$i',
                playlistId: 'playlist_1',
                trackId: pl1Tracks[i],
                position: i,
                dateAdded: now.subtract(Duration(days: 12 - i)),
              ),
            );
      }

      final pl2Tracks = ['song_2', 'song_4', 'song_8'];
      for (int i = 0; i < pl2Tracks.length; i++) {
        await db.into(db.dbPlaylistEntries).insert(
              DbPlaylistEntriesCompanion.insert(
                id: 'pe_pl2_$i',
                playlistId: 'playlist_2',
                trackId: pl2Tracks[i],
                position: i,
                dateAdded: now.subtract(Duration(days: 34 - i)),
              ),
            );
      }

      final pl3Tracks = ['song_3', 'song_6', 'song_7'];
      for (int i = 0; i < pl3Tracks.length; i++) {
        await db.into(db.dbPlaylistEntries).insert(
              DbPlaylistEntriesCompanion.insert(
                id: 'pe_pl3_$i',
                playlistId: 'playlist_3',
                trackId: pl3Tracks[i],
                position: i,
                dateAdded: now.subtract(Duration(days: 5 - i)),
              ),
            );
      }

      // 4. Seed Albums
      final albums = [
        DbAlbumsCompanion.insert(
          id: 'album_1',
          title: 'Nocturne Whispers',
          artist: 'Luna Caine',
          year: 2024,
          artworkUri: 'assets/images/cover_afterglow.jpg',
          isSaved: const Value(true),
        ),
        DbAlbumsCompanion.insert(
          id: 'album_2',
          title: 'Floating Realm',
          artist: 'Kenshi Yonezu',
          year: 2023,
          artworkUri: 'assets/images/cover_zenith.jpg',
          isSaved: const Value(true),
        ),
        DbAlbumsCompanion.insert(
          id: 'album_3',
          title: 'Bamboo Mist',
          artist: 'Ryuichi Sakamoto',
          year: 2022,
          artworkUri: 'assets/images/cover_shrine.jpg',
          isSaved: const Value(false),
        ),
        DbAlbumsCompanion.insert(
          id: 'album_4',
          title: 'Sunrise & Ink',
          artist: 'Tycho',
          year: 2024,
          artworkUri: 'assets/images/cover_crimson_sun.jpg',
          isSaved: const Value(false),
        ),
      ];
      for (final a in albums) {
        await db.into(db.dbAlbums).insert(a);
      }

      // 5. Seed Artists
      final artists = [
        DbArtistsCompanion.insert(
          id: 'artist_1',
          name: 'Luna Caine',
          portraitUri: 'assets/images/cover_afterglow.jpg',
          isFollowed: const Value(true),
        ),
        DbArtistsCompanion.insert(
          id: 'artist_2',
          name: 'Kenshi Yonezu',
          portraitUri: 'assets/images/cover_zenith.jpg',
          isFollowed: const Value(true),
        ),
        DbArtistsCompanion.insert(
          id: 'artist_3',
          name: 'Ryuichi Sakamoto',
          portraitUri: 'assets/images/cover_shrine.jpg',
          isFollowed: const Value(false),
        ),
        DbArtistsCompanion.insert(
          id: 'artist_4',
          name: 'Tycho',
          portraitUri: 'assets/images/cover_crimson_sun.jpg',
          isFollowed: const Value(false),
        ),
      ];
      for (final a in artists) {
        await db.into(db.dbArtists).insert(a);
      }

      // 6. Seed Playback Queue
      for (int i = 0; i < tracks.length; i++) {
        await db.into(db.dbQueueEntries).insert(
              DbQueueEntriesCompanion.insert(
                id: 'queue_init_$i',
                profileId: Value(profileId),
                trackId: tracks[i].id.value,
                position: i,
              ),
            );
      }

      await db.into(db.dbQueueState).insert(
            DbQueueStateCompanion.insert(
              profileId: Value(profileId),
              currentIndex: const Value(0),
              repeatMode: const Value('off'),
              isShuffle: const Value(false),
              positionMs: const Value(138000), // 2 min 18 sec
              isPlaying: const Value(true),
            ),
          );

      // 7. Seed Initial Search History
      final searchQueries = [
        'Tame Impala',
        'Kenshi Yonezu',
        'After Hours',
        'Lo-Fi',
        'Ryuichi Sakamoto',
      ];
      for (int i = 0; i < searchQueries.length; i++) {
        await db.into(db.dbSearchHistory).insert(
              DbSearchHistoryCompanion.insert(
                id: 'sh_$i',
                profileId: Value(profileId),
                query: searchQueries[i],
                createdAt: now.subtract(Duration(minutes: (i + 1) * 15)),
              ),
            );
      }
    });
  }
}
