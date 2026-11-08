import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cavia_music/app/cavia_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final resolutions = [
    // Mobile
    const Size(360, 800),
    const Size(390, 844),
    const Size(430, 932),
    // Tablet
    const Size(768, 1024),
    const Size(1024, 768),
    // Desktop
    const Size(1280, 800),
    const Size(1440, 900),
  ];

  final outputDir = Directory('test/screenshots');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  group('Responsive Visual QA & Screenshot Captures', () {
    for (final size in resolutions) {
      final label = '${size.width.toInt()}x${size.height.toInt()}';

      testWidgets('Renders and captures responsive layout at $label', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;

        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // 1. Launch CaviaApp
        final repaintKey = GlobalKey();
        await tester.pumpWidget(
          RepaintBoundary(
            key: repaintKey,
            child: const CaviaApp(autoSeed: true),
          ),
        );
        await tester.pumpAndSettle();

        // Verify zero overflow errors
        expect(tester.takeException(), isNull);

        // Capture Library screenshot
        await tester.runAsync(() async {
          final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
          if (boundary != null) {
            final image = await boundary.toImage(pixelRatio: 1.0);
            final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
            if (byteData != null) {
              final file = File('test/screenshots/library_$label.png');
              await file.writeAsBytes(byteData.buffer.asUint8List());
            }
          }
        });

        // 2. Navigate to Search Screen
        await tester.tap(find.byIcon(Icons.search_rounded));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Capture Search screenshot
        await tester.runAsync(() async {
          final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
          if (boundary != null) {
            final image = await boundary.toImage(pixelRatio: 1.0);
            final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
            if (byteData != null) {
              final file = File('test/screenshots/search_$label.png');
              await file.writeAsBytes(byteData.buffer.asUint8List());
            }
          }
        });

        // 3. Navigate to Settings Screen
        await tester.tap(find.byIcon(Icons.settings_rounded));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // Capture Settings screenshot
        await tester.runAsync(() async {
          final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
          if (boundary != null) {
            final image = await boundary.toImage(pixelRatio: 1.0);
            final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
            if (byteData != null) {
              final file = File('test/screenshots/settings_$label.png');
              await file.writeAsBytes(byteData.buffer.asUint8List());
            }
          }
        });

        // 4. Return to Library and expand Full Player
        await tester.tap(find.byIcon(Icons.window_rounded));
        await tester.pumpAndSettle();

        // Tap mini-player track to expand full player
        await tester.tap(find.text('Afterglow').last);
        await tester.pumpAndSettle();
        final playerErr = tester.takeException();
        if (playerErr != null) {
          debugPrint('FULL PLAYER OVERFLOW DETAILS: $playerErr');
        }
        expect(playerErr, isNull);

        // Capture Full Player screenshot
        await tester.runAsync(() async {
          final boundary = repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
          if (boundary != null) {
            final image = await boundary.toImage(pixelRatio: 1.0);
            final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
            if (byteData != null) {
              final file = File('test/screenshots/full_player_$label.png');
              await file.writeAsBytes(byteData.buffer.asUint8List());
            }
          }
        });

        // Clean unmount
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(milliseconds: 50));
      });
    }
  });
}
