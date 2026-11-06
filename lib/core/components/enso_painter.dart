import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';

/// Calligraphic Zen Ensō (円相) circle painter.
class EnsoWidget extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const EnsoWidget({
    super.key,
    this.size = 120,
    this.color = CaviaColors.textSilver,
    this.strokeWidth = 14,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EnsoPainter(
          color: color,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _EnsoPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _EnsoPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth * 2) / 2;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    // Draw main broken circle arc (starts around -20 degrees, sweeps 310 degrees)
    const startAngle = -0.3;
    const sweepAngle = 5.6;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);

    // Subtle inner ink bleed stroke
    final innerPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth * 0.6;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 3),
      startAngle + 0.2,
      sweepAngle - 0.4,
      false,
      innerPaint,
    );

    // Ink flick at beginning of brush stroke
    final flickPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final flickCenter = Offset(
      center.dx + radius * math.cos(startAngle),
      center.dy + radius * math.sin(startAngle),
    );
    canvas.drawCircle(flickCenter, strokeWidth * 0.55, flickPaint);
  }

  @override
  bool shouldRepaint(covariant _EnsoPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}

