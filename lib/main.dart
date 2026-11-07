import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/cavia_app.dart';

void main() {
  // Enforce translucent system navigation and status bars for immersive liquid glass UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Render the shell immediately; bootstrap runs on the first frame.
  runApp(const CaviaApp());
}