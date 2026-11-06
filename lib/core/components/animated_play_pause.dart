import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/motion/cavia_motion.dart';

/// Glowing circular play/pause button with animated icon transition and vermilion halo.
class AnimatedPlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  const AnimatedPlayPauseButton({
    super.key,
    required this.isPlaying,
    required this.onTap,
    this.size = 64,
    this.iconSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: CaviaMotion.durationButton,
        curve: CaviaMotion.curveFluid,
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isPlaying
                ? [
                    CaviaColors.vermilionBright,
                    CaviaColors.vermilion,
                  ]
                : [
                    const Color(0x35FFFFFF),
                    const Color(0x10FFFFFF),
                  ],
          ),
          border: Border.all(
            color: isPlaying
                ? CaviaColors.vermilionBright
                : CaviaColors.glassHighlight,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isPlaying
                  ? CaviaColors.vermilion.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.3),
              blurRadius: isPlaying ? 24 : 12,
              spreadRadius: isPlaying ? 2 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: CaviaMotion.durationIcon,
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              key: ValueKey<bool>(isPlaying),
              size: iconSize,
              color: CaviaColors.textIvory,
            ),
          ),
        ),
      ),
    );
  }
}

