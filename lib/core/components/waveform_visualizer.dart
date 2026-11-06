import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';

/// Interactive crimson audio waveform scrubber.
class WaveformVisualizer extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final bool isPlaying;
  final ValueChanged<double>? onSeek;
  final double height;

  const WaveformVisualizer({
    super.key,
    required this.progress,
    required this.isPlaying,
    this.onSeek,
    this.height = 36,
  });

  // Fixed pseudo-random waveform bar heights (normalized between 0.2 and 1.0)
  static const List<double> _barHeights = [
    0.35, 0.55, 0.40, 0.70, 0.85, 0.60, 0.45, 0.75, 0.90, 0.65,
    0.50, 0.80, 1.00, 0.70, 0.40, 0.60, 0.85, 0.55, 0.35, 0.75,
    0.95, 0.65, 0.50, 0.80, 0.90, 0.45, 0.60, 0.85, 0.70, 0.40,
    0.55, 0.75, 0.90, 0.60, 0.45, 0.70, 0.80, 0.50, 0.35, 0.65,
    0.85, 0.60, 0.40, 0.55, 0.75, 0.90, 0.65, 0.45, 0.30, 0.50,
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragUpdate: (details) {
        if (onSeek == null) return;
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final localX = details.localPosition.dx;
        final fraction = (localX / box.size.width).clamp(0.0, 1.0);
        onSeek!(fraction);
      },
      onTapDown: (details) {
        if (onSeek == null) return;
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final localX = details.localPosition.dx;
        final fraction = (localX / box.size.width).clamp(0.0, 1.0);
        onSeek!(fraction);
      },
      child: SizedBox(
        height: height,
        child: CustomPaint(
          size: Size.infinite,
          painter: _WaveformPainter(
            progress: progress.clamp(0.0, 1.0),
            barHeights: _barHeights,
            isPlaying: isPlaying,
          ),
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final double progress;
  final List<double> barHeights;
  final bool isPlaying;

  _WaveformPainter({
    required this.progress,
    required this.barHeights,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = barHeights.length;
    final totalSpacing = size.width / barCount;
    final barWidth = (totalSpacing * 0.55).clamp(2.0, 4.0);

    final activePaint = Paint()
      ..color = CaviaColors.vermilionBright
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    final inactivePaint = Paint()
      ..color = CaviaColors.textSilver.withValues(alpha: 0.25)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = barWidth;

    final centerY = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      final x = (i + 0.5) * totalSpacing;
      final barFraction = (i / barCount);
      final isElapsed = barFraction <= progress;

      final normalizedHeight = barHeights[i];
      final barH = normalizedHeight * (size.height * 0.85);

      final paint = isElapsed ? activePaint : inactivePaint;

      // Draw vertical bar centered around centerY
      canvas.drawLine(
        Offset(x, centerY - barH / 2),
        Offset(x, centerY + barH / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isPlaying != isPlaying;
  }
}

