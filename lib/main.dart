import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/cavia_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce translucent system navigation and status bars for immersive liquid glass UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Supabase if configured at startup
  await CaviaApp.initializeSupabaseIfConfigured();

  // Development-only seeding can be opted into via --dart-define=CAVIA_DEV_SEED=true.
  // Production installs default to false (honest empty library).
  const bool devSeed = bool.fromEnvironment('CAVIA_DEV_SEED', defaultValue: false);

  // Render the shell immediately; bootstrap runs on the first frame.
  runApp(const CaviaApp(autoSeed: devSeed));
}