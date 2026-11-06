import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../core/state/playback_controller.dart';
import '../../core/state/app_state_scope.dart';
import '../library/library_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';
import '../player/mini_player.dart';
import '../player/player_overlay_wrapper.dart';
import 'bottom_nav_bar.dart';
import 'desktop_sidebar.dart';
import 'nav_state.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final NavController _navController = NavController();

  @override
  void dispose() {
    _navController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playback = AppStateScope.playbackOf(context);

    return PlayerOverlayWrapper(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 720;

          return Scaffold(
            backgroundColor: CaviaColors.background,
            body: isDesktop
                ? _buildDesktopLayout(context, playback)
                : _buildMobileLayout(context, playback),
          );
        },
      ),
    );
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return LibraryScreen(onOpenSettings: _navController.goToSettings);
      case 1:
        return const SearchScreen();
      case 2:
        return const SettingsScreen();
      default:
        return LibraryScreen(onOpenSettings: _navController.goToSettings);
    }
  }

  Widget _buildMobileLayout(BuildContext context, PlaybackController playback) {
    return Stack(
      children: [
        // Indexed Active Page with smooth AnimatedSwitcher
        ListenableBuilder(
          listenable: _navController,
          builder: (context, _) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 240),
              child: KeyedSubtree(
                key: ValueKey<int>(_navController.currentIndex),
                child: _buildScreen(_navController.currentIndex),
              ),
            );
          },
        ),

        // Floating Mini-Player (Positioned directly above bottom nav bar)
        Positioned(
          left: 16,
          right: 16,
          bottom: 74,
          child: MiniPlayer(
            onTap: () => playback.setFullPlayerExpanded(true),
          ),
        ),

        // Floating Frosted Glass Bottom Navigation Bar
        Positioned(
          left: 20,
          right: 20,
          bottom: 12,
          child: SafeArea(
            top: false,
            child: CaviaBottomNavBar(navController: _navController),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, PlaybackController playback) {
    return Row(
      children: [
        // Compact Desktop Sidebar
        DesktopSidebar(navController: _navController),

        // Main Content Area with Bottom Mini-Player
        Expanded(
          child: Stack(
            children: [
              ListenableBuilder(
                listenable: _navController,
                builder: (context, _) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: KeyedSubtree(
                      key: ValueKey<int>(_navController.currentIndex),
                      child: _buildScreen(_navController.currentIndex),
                    ),
                  );
                },
              ),

              // Desktop Floating Bottom Mini-Player
              Positioned(
                left: 24,
                right: 24,
                bottom: 16,
                child: MiniPlayer(
                  onTap: () => playback.setFullPlayerExpanded(true),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

