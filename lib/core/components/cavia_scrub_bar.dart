import 'package:flutter/material.dart';
import '../../app/theme/cavia_colors.dart';
import '../../app/theme/cavia_typography.dart';

/// Clean, high-precision audio scrubber supporting tap-to-seek and drag-to-scrub.
class CaviaScrubBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<double> onSeek;
  final bool isPlaying;

  const CaviaScrubBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
    this.isPlaying = false,
  });

  @override
  State<CaviaScrubBar> createState() => _CaviaScrubBarState();
}

class _CaviaScrubBarState extends State<CaviaScrubBar> {
  bool _isDragging = false;
  double _dragFraction = 0.0;

  String _format(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  void _updateSeek(Offset localPosition, double totalWidth) {
    if (totalWidth <= 0) return;
    final fraction = (localPosition.dx / totalWidth).clamp(0.0, 1.0);
    setState(() {
      _dragFraction = fraction;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double actualFraction = widget.duration.inMilliseconds > 0
        ? (widget.position.inMilliseconds / widget.duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final displayFraction = _isDragging ? _dragFraction : actualFraction;

    final displayedPosition = _isDragging
        ? Duration(milliseconds: (widget.duration.inMilliseconds * displayFraction).round())
        : widget.position;

    return Semantics(
      slider: true,
      label: 'Audio scrubber',
      value: '${_format(displayedPosition)} of ${_format(widget.duration)}',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (details) {
                  setState(() {
                    _isDragging = true;
                  });
                  _updateSeek(details.localPosition, barWidth);
                },
                onHorizontalDragUpdate: (details) {
                  _updateSeek(details.localPosition, barWidth);
                },
                onHorizontalDragEnd: (details) {
                  setState(() {
                    _isDragging = false;
                  });
                  widget.onSeek(_dragFraction);
                },
                onTapDown: (details) {
                  _updateSeek(details.localPosition, barWidth);
                  widget.onSeek(_dragFraction);
                },
                child: Container(
                  height: 28,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Background Track
                      Container(
                        height: 4.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: CaviaColors.glassBorder.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                      // Elapsed Active Track
                      Container(
                        height: 4.0,
                        width: barWidth * displayFraction,
                        decoration: BoxDecoration(
                          color: CaviaColors.vermilionBright,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: CaviaColors.vermilion.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),

                      // Scrub Thumb
                      Positioned(
                        left: (barWidth * displayFraction - (_isDragging ? 7 : 5))
                            .clamp(0.0, barWidth - (_isDragging ? 14 : 10)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          width: _isDragging ? 14 : 10,
                          height: _isDragging ? 14 : 10,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: CaviaColors.vermilion.withValues(alpha: 0.7),
                                blurRadius: _isDragging ? 10 : 6,
                                spreadRadius: _isDragging ? 2 : 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Timestamps Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _format(displayedPosition),
                    style: CaviaTypography.caption.copyWith(
                      color: _isDragging ? CaviaColors.vermilionBright : CaviaColors.textSilver,
                      fontWeight: _isDragging ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  Text(
                    _format(widget.duration),
                    style: CaviaTypography.caption,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

