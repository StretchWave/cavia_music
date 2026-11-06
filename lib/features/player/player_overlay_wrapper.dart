import 'package:flutter/material.dart';
import '../../app/motion/cavia_motion.dart';
import '../../core/state/app_state_scope.dart';
import 'full_player_view.dart';

/// Coordinates fluid physics-based expansion between Mini-Player and Full-Player.
class PlayerOverlayWrapper extends StatelessWidget {
  final Widget child;

  const PlayerOverlayWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final playback = AppStateScope.playbackOf(context);

    return ListenableBuilder(
      listenable: playback,
      builder: (context, _) {
        final isExpanded = playback.isFullPlayerExpanded;

        return Stack(
          children: [
            // Underlying application content
            Positioned.fill(child: child),

            // Full Player Screen Sliding from bottom
            AnimatedSlide(
              duration: CaviaMotion.durationExpansion,
              curve: CaviaMotion.curveFluid,
              offset: isExpanded ? Offset.zero : const Offset(0, 1),
              child: AnimatedOpacity(
                duration: CaviaMotion.durationStandard,
                curve: Curves.easeIn,
                opacity: isExpanded ? 1.0 : 0.0,
                child: isExpanded
                    ? FullPlayerView(
                        onCollapse: () => playback.setFullPlayerExpanded(false),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        );
      },
    );
  }
}
