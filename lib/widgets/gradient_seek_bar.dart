import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientSeekBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;
  final bool isPlaying;

  const GradientSeekBar({
    super.key,
    required this.position,
    required this.duration,
    required this.onSeek,
    this.isPlaying = false,
  });

  @override
  State<GradientSeekBar> createState() => _GradientSeekBarState();
}

class _GradientSeekBarState extends State<GradientSeekBar> {
  double? _dragValue;
  bool _dragging = false;

  double get _progress {
    if (_dragging && _dragValue != null) return _dragValue!;
    if (widget.duration.inMilliseconds == 0) return 0;
    return widget.position.inMilliseconds / widget.duration.inMilliseconds;
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onHorizontalDragStart: (details) {
            setState(() {
              _dragging = true;
            });
          },
          onHorizontalDragUpdate: (details) {
            final box = context.findRenderObject() as RenderBox;
            final localPos = details.localPosition;
            final progress = (localPos.dx / box.size.width).clamp(0.0, 1.0);
            setState(() {
              _dragValue = progress;
            });
            final seekPosition = Duration(
              milliseconds: (widget.duration.inMilliseconds * progress).round(),
            );
            widget.onSeek(seekPosition);
          },
          onHorizontalDragEnd: (details) {
            setState(() {
              _dragging = false;
              _dragValue = null;
            });
          },
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(3),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Stack(
                children: [
                  Container(
                    color: AppTheme.surfaceLight,
                  ),
                  FractionallySizedBox(
                    widthFactor: _progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.seekBarGradient,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(widget.position),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                _formatDuration(widget.duration),
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}