import 'package:flutter/material.dart';
import 'playback_controller.dart';
import 'library_controller.dart';
import 'settings_controller.dart';

class AppStateScope extends InheritedWidget {
  final PlaybackController playback;
  final LibraryController library;
  final SettingsController settings;

  const AppStateScope({
    super.key,
    required this.playback,
    required this.library,
    required this.settings,
    required super.child,
  });

  static AppStateScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'No AppStateScope found in context');
    return scope!;
  }

  static PlaybackController playbackOf(BuildContext context) => of(context).playback;
  static LibraryController libraryOf(BuildContext context) => of(context).library;
  static SettingsController settingsOf(BuildContext context) => of(context).settings;

  @override
  bool updateShouldNotify(covariant AppStateScope oldWidget) {
    return oldWidget.playback != playback ||
        oldWidget.library != library ||
        oldWidget.settings != settings;
  }
}

