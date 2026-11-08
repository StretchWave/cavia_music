import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../core/responsive/responsive_breakpoints.dart';
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

  // Keep screen instances in memory to preserve search input, scroll offsets, and filters
  late final List<Widget> _screens = [
    LibraryScreen(onOpenSettings: _navController.goToSettings),
    const SearchScreen(),
    const SettingsScreen(),
  ];

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
          final isDesktop = constraints.maxWidth >= CaviaBreakpoints.tabletMin;

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

  Widget _buildMobileLayout(BuildContext context, PlaybackController playback) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final navBarBottom = 12.0 + (bottomInset > 0 ? bottomInset - 4 : 0);
    final miniPlayerBottom = navBarBottom + 64.0;

    return Stack(
      children: [
        // IndexedStack preserves state across tab changes (search queries, scroll offsets, filters)
        ListenableBuilder(
          listenable: _navController,
          builder: (context, _) {
            return IndexedStack(
              index: _navController.currentIndex,
              children: _screens,
            );
          },
        ),

        // Floating Mini-Player (Positioned directly above bottom nav bar with dynamic clearance)
        Positioned(
          left: 16,
          right: 16,
          bottom: miniPlayerBottom,
          child: ListenableBuilder(
            listenable: playback,
            builder: (context, _) => playback.hasCurrentSong
                ? MiniPlayer(onTap: () => playback.setFullPlayerExpanded(true))
                : const SizedBox.shrink(),
          ),
        ),

        // Floating Frosted Glass Bottom Navigation Bar
        Positioned(
          left: 20,
          right: 20,
          bottom: navBarBottom,
          child: SafeArea(
            top: false,
            bottom: false,
            child: CaviaBottomNavBar(navController: _navController),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    PlaybackController playback,
  ) {
    return Row(
      children: [
        // Desktop Sidebar
        DesktopSidebar(navController: _navController),

        // Main Content Area with desktop layout
        Expanded(
          child: Stack(
            children: [
              // Constrained, centered content area
              ResponsiveContentWrapper(
                child: ListenableBuilder(
                  listenable: _navController,
                  builder: (context, _) {
                    return IndexedStack(
                      index: _navController.currentIndex,
                      children: _screens,
                    );
                  },
                ),
              ),

              // Desktop Floating Bottom Mini-Player
              Positioned(
                left: 24,
                right: 24,
                bottom: 16,
                child: ResponsiveContentWrapper(
                  child: ListenableBuilder(
                    listenable: playback,
                    builder: (context, _) => playback.hasCurrentSong
                        ? MiniPlayer(
                            onTap: () => playback.setFullPlayerExpanded(true),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
