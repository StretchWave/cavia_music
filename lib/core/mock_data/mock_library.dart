import '../models/music_models.dart';

class MockLibrary {
  MockLibrary._();

  static final List<LyricLine> afterglowLyrics = [
    const LyricLine(timestamp: Duration(seconds: 0), text: "Walking through the lantern light"),
    const LyricLine(timestamp: Duration(seconds: 14), text: "Shadows dancing on the paper screen"),
    const LyricLine(timestamp: Duration(seconds: 28), text: "Crimson leaves begin to fall"),
    const LyricLine(timestamp: Duration(seconds: 42), text: "A distant bell echoes in the mist"),
    const LyricLine(timestamp: Duration(seconds: 58), text: "In the afterglow of your memory"),
    const LyricLine(timestamp: Duration(seconds: 75), text: "Night unfolds like black ink on silk"),
    const LyricLine(timestamp: Duration(seconds: 94), text: "We trace the lines that time forgot"),
    const LyricLine(timestamp: Duration(seconds: 112), text: "Until the silver moon appears"),
    const LyricLine(timestamp: Duration(seconds: 138), text: "Standing at the edge of quiet waters"),
    const LyricLine(timestamp: Duration(seconds: 160), text: "Nothing remains but the crimson embers"),
    const LyricLine(timestamp: Duration(seconds: 185), text: "And the wind humming in the pines"),
    const LyricLine(timestamp: Duration(seconds: 215), text: "In the afterglow..."),
    const LyricLine(timestamp: Duration(seconds: 249), text: "Drifting into the stillness of dawn"),
  ];

  static final List<Song> allSongs = [
    Song(
      id: 'song_1',
      title: 'Afterglow',
      artist: 'Luna Caine',
      album: 'Nocturne Whispers',
      duration: const Duration(minutes: 4, seconds: 9),
      artworkAsset: 'assets/images/cover_afterglow.jpg',
      isLiked: true,
      isCached: true,
      lyrics: afterglowLyrics,
    ),
    Song(
      id: 'song_2',
      title: 'Zenith',
      artist: 'Kenshi Yonezu',
      album: 'Floating Realm',
      duration: const Duration(minutes: 3, seconds: 45),
      artworkAsset: 'assets/images/cover_zenith.jpg',
      isLiked: true,
      isCached: true,
    ),
    Song(
      id: 'song_3',
      title: 'Crimson Shrine',
      artist: 'Ryuichi Sakamoto',
      album: 'Bamboo Mist',
      duration: const Duration(minutes: 5, seconds: 12),
      artworkAsset: 'assets/images/cover_shrine.jpg',
      isLiked: true,
      isCached: false,
    ),
    Song(
      id: 'song_4',
      title: 'Misty Ridge',
      artist: 'Nujabes',
      album: 'Modal Soul Reflections',
      duration: const Duration(minutes: 4, seconds: 22),
      artworkAsset: 'assets/images/cover_mist_mountain.jpg',
      isLiked: false,
      isCached: true,
    ),
    Song(
      id: 'song_5',
      title: 'Blood Moon Ronin',
      artist: 'Tycho',
      album: 'Sunrise & Ink',
      duration: const Duration(minutes: 3, seconds: 58),
      artworkAsset: 'assets/images/cover_crimson_sun.jpg',
      isLiked: true,
      isCached: false,
    ),
    Song(
      id: 'song_6',
      title: 'Torii Horizon',
      artist: 'Kavinsky',
      album: 'Nightcall Tokyo',
      duration: const Duration(minutes: 4, seconds: 18),
      artworkAsset: 'assets/images/cover_shrine_gate.jpg',
      isLiked: false,
      isCached: false,
    ),
    Song(
      id: 'song_7',
      title: 'Whispering Pines',
      artist: 'Haruomi Hosono',
      album: 'Cochin Moon Sessions',
      duration: const Duration(minutes: 3, seconds: 34),
      artworkAsset: 'assets/images/cover_shrine.jpg',
      isLiked: false,
      isCached: false,
    ),
    Song(
      id: 'song_8',
      title: 'Silver Rain Over Kyoto',
      artist: 'Joe Hisaishi',
      album: 'Dream Songs',
      duration: const Duration(minutes: 4, seconds: 55),
      artworkAsset: 'assets/images/cover_mist_mountain.jpg',
      isLiked: true,
      isCached: true,
    ),
  ];

  static final List<Album> allAlbums = [
    Album(
      id: 'album_1',
      title: 'Nocturne Whispers',
      artist: 'Luna Caine',
      year: 2024,
      artworkAsset: 'assets/images/cover_afterglow.jpg',
      isSaved: true,
      songs: [
        allSongs[0],
        allSongs[1],
        allSongs[4],
      ],
    ),
    Album(
      id: 'album_2',
      title: 'Floating Realm',
      artist: 'Kenshi Yonezu',
      year: 2023,
      artworkAsset: 'assets/images/cover_zenith.jpg',
      isSaved: true,
      songs: [
        allSongs[1],
        allSongs[3],
        allSongs[5],
      ],
    ),
    Album(
      id: 'album_3',
      title: 'Bamboo Mist',
      artist: 'Ryuichi Sakamoto',
      year: 2022,
      artworkAsset: 'assets/images/cover_shrine.jpg',
      isSaved: false,
      songs: [
        allSongs[2],
        allSongs[6],
        allSongs[7],
      ],
    ),
    Album(
      id: 'album_4',
      title: 'Sunrise & Ink',
      artist: 'Tycho',
      year: 2024,
      artworkAsset: 'assets/images/cover_crimson_sun.jpg',
      isSaved: false,
      songs: [
        allSongs[4],
        allSongs[5],
      ],
    ),
  ];

  static final List<Artist> allArtists = [
    Artist(
      id: 'artist_1',
      name: 'Luna Caine',
      portraitAsset: 'assets/images/cover_afterglow.jpg',
      isFollowed: true,
      popularSongs: [allSongs[0], allSongs[1], allSongs[4]],
      albums: [allAlbums[0]],
      singles: [allSongs[0]],
    ),
    Artist(
      id: 'artist_2',
      name: 'Kenshi Yonezu',
      portraitAsset: 'assets/images/cover_zenith.jpg',
      isFollowed: true,
      popularSongs: [allSongs[1], allSongs[3]],
      albums: [allAlbums[1]],
      singles: [allSongs[1]],
    ),
    Artist(
      id: 'artist_3',
      name: 'Ryuichi Sakamoto',
      portraitAsset: 'assets/images/cover_shrine.jpg',
      isFollowed: false,
      popularSongs: [allSongs[2], allSongs[6], allSongs[7]],
      albums: [allAlbums[2]],
      singles: [allSongs[2]],
    ),
    Artist(
      id: 'artist_4',
      name: 'Tycho',
      portraitAsset: 'assets/images/cover_crimson_sun.jpg',
      isFollowed: false,
      popularSongs: [allSongs[4], allSongs[5]],
      albums: [allAlbums[3]],
      singles: [allSongs[4]],
    ),
  ];

  static final List<Playlist> allPlaylists = [
    Playlist(
      id: 'playlist_1',
      name: 'Midnight Ink & Rain',
      description: 'Atmospheric nocturnal soundscapes for deep focus and solitary travel.',
      artworkAsset: 'assets/images/cover_crimson_sun.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      songs: [
        allSongs[0],
        allSongs[1],
        allSongs[2],
        allSongs[4],
      ],
    ),
    Playlist(
      id: 'playlist_2',
      name: 'Zenith Sanctuary',
      description: 'Ethereal ambient Japanese neoclassical and contemplative piano.',
      artworkAsset: 'assets/images/cover_mist_mountain.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 34)),
      songs: [
        allSongs[1],
        allSongs[3],
        allSongs[7],
      ],
    ),
    Playlist(
      id: 'playlist_3',
      name: 'Torii Echoes',
      description: 'Modern beats, lo-fi textures and synthesized sumi-e melodies.',
      artworkAsset: 'assets/images/cover_shrine_gate.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      songs: [
        allSongs[2],
        allSongs[5],
        allSongs[6],
      ],
    ),
  ];

  static final List<String> initialSearchHistory = [
    'Tame Impala',
    'Kenshi Yonezu',
    'After Hours',
    'Lo-Fi',
    'Ryuichi Sakamoto',
  ];
}
