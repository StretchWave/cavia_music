import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'theme/cavia_theme.dart';
import '../core/config/cavia_config.dart';
import '../core/state/playback_controller.dart';
import '../core/state/library_controller.dart';
import '../core/state/settings_controller.dart';
import '../core/state/app_state_scope.dart';
import '../features/shell/main_scaffold.dart';

/// The root widget that displays a loading screen while the real
/// infrastructure is being assembled, then hands off to [MainScaffold].
class CaviaApp extends StatefulWidget {
  const CaviaApp({super.key, this.deviceId});

  final String? deviceId;

  @override
  State<CaviaApp> createState() => _CaviaAppState();
}

class _CaviaAppState extends State<CaviaApp> {
  bool _initialized = false;
  bool _showLoading = true;

  @override
  void initState() {
    super.initState();
    // Bootstrap asynchronously after widget insertion.
    _bootstrapAsync();
  }

  Future<void> _bootstrapAsync() async {
    try {
      // Simulate setup that may take a moment: database open, device id,
      // Supabase optional, audio session init. In production these would
      // be real calls; here we just brief-pause then mark ready.
      await Future.delayed(const Duration(milliseconds: 800));

      // If Supabase is configured in this build, mark it so controllers
      // can opt into it; otherwise the app stays fully offline-capable.
      if (CaviaConfig.supabaseConfigured) {
        debugPrint('[Cavia] Supabase configured: ${CaviaConfig.supabaseUrl}');
      }

      setState(() => _initialized = true);
      if (!mounted) return;
      setState(() => _showLoading = false);
    } catch (e) {
      debugPrint('[Cavia] Bootstrap error: $e');
      if (!mounted) return;
      setState(() => _showLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // During the first frames, show a branded splash so the user isn't
    // looking at a blank window while databases and audio engage.
    if (!_initialized) {
      return _buildLoadingContext(context);
    }

    // Once bootstrapped, hand off to the full scaffold.
    return MainScaffold();
  }

  Widget _buildLoadingContext(BuildContext context) {
    return MaterialApp(
      title: 'Cavia Music',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black87,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
              ),
              SizedBox(height: 24),
              Text(
                'Cavia Music — Initializing',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 18,
                ),
              ),
              Text(
                'Loading local library & configuring audio',
                style: TextStyle(
                  color: Color(0xFFBCAAA4),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}