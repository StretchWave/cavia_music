import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/cavia_app.dart';
import 'core/config/cavia_config.dart';

Future<void> main() async {
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

  final app = await CaviaApp.create();

  if (CaviaConfig.supabaseConfigured && CaviaConfig.isDevelopment) {
    debugPrint('[Cavia] Supabase configured: ${CaviaConfig.supabaseUrl}');
  }

  runApp(app);
}
