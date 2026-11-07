import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:cavia_music/app/cavia_app.dart';
import 'package:cavia_music/core/state/app_state_scope.dart';
import 'package:cavia_music/core/state/playback_controller.dart';
import 'package:cavia_music/core/state/library_controller.dart';
import 'package:cavia_music/core/state/settings_controller.dart';
import 'package:cavia_music/core/data/database/cavia_database.dart';
import 'package:cavia_music/core/domain/repositories/track_repository.dart';
import 'package:cavia_music/core/domain/models/track.dart';
import 'package:cavia_music/core/domain/result/result.dart';
import 'package:cavia_music/core/domain/result/app_error.dart';
import 'package:cavia_music/features/shell/main_scaffold.dart';

class _FailingTrackRepo implements TrackRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<Result<List<Track>, AppError>> getAllTracks({String? profileId}) async {
    throw StateError('Simulated fatal database corruption');
  }

  @override
  Stream<List<Track>> watchTracks({String? profileId}) {
    throw StateError('Simulated fatal database corruption');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CaviaApp Bootstrap & AppStateScope Regression Tests', () {
    testWidgets('1. CaviaApp launches without AppStateScope assertion error and renders single MaterialApp', (tester) async {
      await tester.pumpWidget(const CaviaApp());
      await tester.pumpAndSettle();

      // Verify single root MaterialApp
      expect(find.byType(MaterialApp), findsOneWidget);

      // Verify AppStateScope wraps MainScaffold
      expect(find.byType(AppStateScope), findsOneWidget);
      expect(find.byType(MainScaffold), findsOneWidget);

      // Verify MainScaffold is inside AppStateScope
      final appStateScopeFinder = find.byType(AppStateScope);
      final scaffoldFinder = find.descendant(
        of: appStateScopeFinder,
        matching: find.byType(MainScaffold),
      );
      expect(scaffoldFinder, findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('2. MainScaffold and children receive all 3 required controllers via AppStateScope', (tester) async {
      await tester.pumpWidget(const CaviaApp());
      await tester.pumpAndSettle();

      final scaffoldContext = tester.element(find.byType(MainScaffold));

      // Access all 3 controllers through AppStateScope static helpers
      final playback = AppStateScope.playbackOf(scaffoldContext);
      final library = AppStateScope.libraryOf(scaffoldContext);
      final settings = AppStateScope.settingsOf(scaffoldContext);

      expect(playback, isNotNull);
      expect(playback, isA<PlaybackController>());

      expect(library, isNotNull);
      expect(library, isA<LibraryController>());

      expect(settings, isNotNull);
      expect(settings, isA<SettingsController>());

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('3. Library, Search, Settings, and Player screens access their dependencies cleanly', (tester) async {
      await tester.pumpWidget(const CaviaApp());
      await tester.pumpAndSettle();

      // Library Screen verification
      expect(find.text('L I B R A R Y'), findsOneWidget);
      expect(find.text('藏'), findsOneWidget);

      // Navigate to Search Screen
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();
      expect(find.text('S E A R C H'), findsOneWidget);
      expect(find.text('探'), findsOneWidget);
      expect(find.text('RECENT SEARCHES'), findsOneWidget);

      // Navigate to Settings Screen
      await tester.tap(find.byIcon(Icons.settings_rounded));
      await tester.pumpAndSettle();
      expect(find.text('S E T T I N G S'), findsOneWidget);
      expect(find.text('設定'), findsOneWidget);
      expect(find.text('Offline caching'), findsOneWidget);

      // Navigate back to Library
      await tester.tap(find.byIcon(Icons.window_rounded));
      await tester.pumpAndSettle();

      // Expand Player Screen via Mini-Player
      await tester.tap(find.text('Afterglow').last);
      await tester.pumpAndSettle();
      expect(find.text('NOW PLAYING'), findsOneWidget);

      // Collapse Player Screen
      await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
      await tester.pumpAndSettle();
      expect(find.text('藏'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('4. Initialization failures display branded error screen with retry rather than crashing', (tester) async {
      // Launch CaviaApp with a track repository that throws during bootstrap
      await tester.pumpWidget(CaviaApp(
        trackRepository: _FailingTrackRepo(),
      ));
      await tester.pumpAndSettle();

      // Verify that rather than an unhandled assertion crash, an error screen is displayed
      expect(find.text('Initialization Failed'), findsOneWidget);
      expect(find.textContaining('Simulated fatal database corruption'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

      // Tap Retry button to verify retry trigger
      await tester.tap(find.text('Retry'));
      await tester.pump();

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('5. Rebuilding CaviaApp does not initialize duplicate controllers', (tester) async {
      await tester.pumpWidget(const CaviaApp());
      await tester.pumpAndSettle();

      final stateBefore = tester.state<CaviaAppState>(find.byType(CaviaApp));
      final playback1 = stateBefore.playbackController;
      final library1 = stateBefore.libraryController;
      final settings1 = stateBefore.settingsController;

      expect(playback1, isNotNull);
      expect(library1, isNotNull);
      expect(settings1, isNotNull);

      // Rebuild the CaviaApp widget with same key/state
      await tester.pumpWidget(const CaviaApp());
      await tester.pump();

      final stateAfter = tester.state<CaviaAppState>(find.byType(CaviaApp));
      final playback2 = stateAfter.playbackController;
      final library2 = stateAfter.libraryController;
      final settings2 = stateAfter.settingsController;

      // Controllers MUST be identical instances — never re-initialized or duplicated
      expect(identical(playback1, playback2), isTrue);
      expect(identical(library1, library2), isTrue);
      expect(identical(settings1, settings2), isTrue);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('6. Controllers and owned database are correctly disposed on unmount', (tester) async {
      final db = CaviaDatabase.forTesting(NativeDatabase.memory());

      await tester.pumpWidget(CaviaApp(database: db));
      await tester.pumpAndSettle();

      final state = tester.state<CaviaAppState>(find.byType(CaviaApp));
      final playback = state.playbackController!;
      final library = state.libraryController!;
      final settings = state.settingsController!;

      // Unmount the CaviaApp widget tree
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));

      // Verify listeners cannot be called on disposed controllers without error
      expect(() => playback.notifyListeners(), throwsFlutterError);
      expect(() => library.notifyListeners(), throwsFlutterError);
      expect(() => settings.notifyListeners(), throwsFlutterError);

      await db.close();
    });
  });
}
