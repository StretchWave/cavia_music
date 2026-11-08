import 'package:flutter/material.dart';
import '../../app/motion/cavia_motion.dart';
import '../../core/state/app_state_scope.dart';
import 'full_player_view.dart';

/// Coordinates fluid physics-based expansion between Mini-Player and Full-Player.
/// Fixes lifecycle disposal so collapse animation smoothly completes before unmounting.
class PlayerOverlayWrapper extends StatefulWidget {
  final Widget child;

  const PlayerOverlayWrapper({super.key, required this.child});

  @override
  State<PlayerOverlayWrapper> createState() => _PlayerOverlayWrapperState();
}

class _PlayerOverlayWrapperState extends State<PlayerOverlayWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: CaviaMotion.durationExpansion,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: CaviaMotion.curveFluid,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed && mounted) {
        setState(() => _isMounted = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncState(bool isExpanded) {
    if (isExpanded) {
      _isMounted = true;
      if (_controller.status != AnimationStatus.forward &&
          _controller.status != AnimationStatus.completed) {
        _controller.forward();
      }
    } else {
      if (_controller.status != AnimationStatus.reverse &&
          _controller.status != AnimationStatus.dismissed) {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playback = AppStateScope.playbackOf(context);

    return ListenableBuilder(
      listenable: playback,
      builder: (context, _) {
        _syncState(playback.isFullPlayerExpanded);

        return Stack(
          children: [
            // Underlying application content
            Positioned.fill(child: widget.child),

            // Full Player Screen Sliding smoothly with full reverse lifecycle
            if (_isMounted)
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: FullPlayerView(
                    onCollapse: () => playback.setFullPlayerExpanded(false),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
