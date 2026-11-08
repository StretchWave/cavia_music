import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cavia_music/app/cavia_app.dart';
import 'package:cavia_music/core/state/playback_controller.dart';
import 'package:cavia_music/core/state/library_controller.dart';
import 'package:cavia_music/core/state/settings_controller.dart';

void main() {
  group('PlaybackController Unit Tests', () {
    late PlaybackController playback;

    setUp(() {
      playback = PlaybackController();
    });

    tearDown(() {
      playback.dispose();
    });

    test('Initial state is playing with Afterglow as default track', () {
      expect(playback.isPlaying, true);
      expect(playback.currentSong?.title, 'Afterglow');
      expect(playback.currentPosition.inSeconds, 138); // 2 min 18 sec
      expect(playback.queue.isNotEmpty, true);
    });

    test('Play/Pause toggle works cleanly', () {
      playback.pause();
      expect(playback.isPlaying, false);
      playback.play();
      expect(playback.isPlaying, true);
      playback.togglePlayPause();
      expect(playback.isPlaying, false);
    });

    test('Seek accurately updates current position', () {
      playback.seekTo(0.5);
      final expectedMs = (0.5 * playback.totalDuration.inMilliseconds).round();
      expect(playback.currentPosition.inMilliseconds, expectedMs);
    });

    test('Shuffle and repeat cycles work', () {
      expect(playback.isShuffle, false);
      playback.toggleShuffle();
      expect(playback.isShuffle, true);

      expect(playback.repeatMode, CaviaRepeatMode.off);
      playback.cycleRepeatMode();
      expect(playback.repeatMode, CaviaRepeatMode.all);
      playback.cycleRepeatMode();
      expect(playback.repeatMode, CaviaRepeatMode.one);
      playback.cycleRepeatMode();
      expect(playback.repeatMode, CaviaRepeatMode.off);
    });

    test('Queue reordering and removal', () {
      final initialSecond = playback.queue[1];

      playback.reorderQueue(0, 2);
      expect(playback.queue.first.id, initialSecond.id);

      final countBefore = playback.queue.length;
      playback.removeFromQueue(0);
      expect(playback.queue.length, countBefore - 1);
    });
  });

  group('LibraryController Unit Tests', () {
    late LibraryController library;

    setUp(() {
      library = LibraryController();
    });

    tearDown(() {
      library.dispose();
    });

    test('Library initializes with populated mock data', () {
      expect(library.songs.isNotEmpty, true);
      expect(library.playlists.isNotEmpty, true);
      expect(library.albums.isNotEmpty, true);
      expect(library.artists.isNotEmpty, true);
      expect(library.searchHistory.isNotEmpty, true);
    });

    test('Like/Unlike toggle updates reactive state', () {
      final song = library.songs.first;
      final initialLiked = song.isLiked;

      library.toggleLikeSong(song);
      expect(library.isSongLiked(song.id), !initialLiked);

      library.toggleLikeSong(song);
      expect(library.isSongLiked(song.id), initialLiked);
    });

    test('Create, edit, and delete playlist', () {
      final initialCount = library.playlists.length;

      library.createPlaylist('Kyoto Nights', 'Ambient soundscapes');
      expect(library.playlists.length, initialCount + 1);
      final created = library.playlists.first;
      expect(created.name, 'Kyoto Nights');

      library.editPlaylist(created.id, 'Kyoto Rainy Nights', 'Updated desc');
      expect(
        library.playlists.firstWhere((p) => p.id == created.id).name,
        'Kyoto Rainy Nights',
      );

      library.deletePlaylist(created.id);
      expect(library.playlists.length, initialCount);
    });

    test('Search history addition, removal, and clear', () {
      library.addSearchHistory('Tycho New Release');
      expect(library.searchHistory.first, 'Tycho New Release');

      library.removeSearchHistory('Tycho New Release');
      expect(library.searchHistory.contains('Tycho New Release'), false);

      library.clearSearchHistory();
      expect(library.searchHistory.isEmpty, true);
    });
  });

  group('SettingsController Unit Tests', () {
    late SettingsController settings;

    setUp(() {
      settings = SettingsController();
    });

    tearDown(() {
      settings.dispose();
    });

    test('Offline caching toggle preserves cached data', () {
      expect(settings.offlineCaching, true);
      expect(settings.cacheSizeFormatted, '1.2 GB');

      // Disabling caching does NOT clear existing files
      settings.toggleOfflineCaching(false);
      expect(settings.offlineCaching, false);
      expect(settings.cacheSizeFormatted, '1.2 GB');

      // Clearing cache explicitly clears it
      settings.clearCache();
      expect(settings.cacheSizeFormatted, '0 MB');
    });

    test('Cloud sync and playback options update smoothly', () {
      expect(settings.cloudSync, false);
      settings.toggleCloudSync(true);
      expect(settings.cloudSync, true);
      expect(settings.lastSyncTime, 'Just now');

      settings.setAudioQuality('High (320 kbps AAC / Opus)');
      expect(settings.audioQuality, 'High (320 kbps AAC / Opus)');
    });
  });

  group('Widget & Navigation Integration Tests', () {
    testWidgets('Production CaviaApp defaults to autoSeed = false and launches with honest empty library', (tester) async {
      await tester.pumpWidget(const CaviaApp());
      await tester.pumpAndSettle();

      // Verify wordmark and Library headers
      expect(find.text('藏'), findsOneWidget);
      expect(find.text('L I B R A R Y'), findsOneWidget);

      // Verify honest empty state is shown (no fake seeded playlists or tracks)
      expect(find.text('Your Library is Empty'), findsOneWidget);
      expect(find.text('Import Playlist'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('App launches directly into populated Library screen', (tester) async {
      await tester.pumpWidget(const CaviaApp(autoSeed: true));
      await tester.pumpAndSettle();

      // Verify Cavia wordmark and Kanji
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('CAVIA'),
        ),
        findsWidgets,
      );
      expect(find.text('藏'), findsOneWidget);
      expect(find.text('L I B R A R Y'), findsOneWidget);

      // Verify 2x2 Glass Shortcuts
      expect(find.textContaining('Liked'), findsOneWidget);
      expect(find.textContaining('Playlists'), findsWidgets);
      expect(find.textContaining('Albums'), findsWidgets);
      expect(find.textContaining('Artists'), findsWidgets);

      // Verify Mini-Player exists with currently playing track
      expect(find.text('Afterglow'), findsWidgets);
      expect(find.text('Luna Caine'), findsWidgets);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('Switch tabs between Library, Search, and Settings', (tester) async {
      await tester.pumpWidget(const CaviaApp(autoSeed: true));
      await tester.pumpAndSettle();

      // Tap Search tab
      final searchTab = find.byIcon(Icons.search_rounded);
      await tester.tap(searchTab);
      await tester.pumpAndSettle();

      // Search screen should show Kanji '探'
      expect(find.text('探'), findsOneWidget);
      expect(find.text('S E A R C H'), findsOneWidget);
      expect(find.text('RECENT SEARCHES'), findsOneWidget);

      // Tap Settings tab
      final settingsTab = find.byIcon(Icons.settings_rounded);
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();

      // Settings screen should show Kanji '設定' and groups
      expect(find.text('設定'), findsOneWidget);
      expect(find.text('S E T T I N G S'), findsOneWidget);
      expect(find.text('Offline caching'), findsOneWidget);
      expect(find.text('Clear cache'), findsOneWidget);
      expect(find.text('Import from Spotify'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('Full Player expands on Mini-Player tap and collapses on chevron down', (tester) async {
      await tester.pumpWidget(const CaviaApp(autoSeed: true));
      await tester.pumpAndSettle();

      // Tap the Mini-Player track title
      await tester.tap(find.text('Afterglow').last);
      await tester.pumpAndSettle();

      // Full Player view should be visible with NOW PLAYING and large controls
      expect(find.text('NOW PLAYING'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
      expect(find.byIcon(Icons.shuffle_rounded), findsOneWidget);

      // Collapse back down
      await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
      await tester.pumpAndSettle();

      // Verify returned to Library screen
      expect(find.text('藏'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('Search query displays filtered results and allows clearing', (tester) async {
      await tester.pumpWidget(const CaviaApp(autoSeed: true));
      await tester.pumpAndSettle();

      // Go to Search
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      // Type in search bar
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Zenith');
      await tester.pumpAndSettle();

      // Should show matching song
      expect(find.text('Zenith'), findsWidgets);
      expect(find.textContaining('Kenshi Yonezu'), findsWidgets);

      // Clear search
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Should return to recent searches
      expect(find.text('RECENT SEARCHES'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });
  });
}
