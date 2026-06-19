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

  Duration get _displayPosition {
    if (_dragging && _dragValue != null) {
      return Duration(
        milliseconds: (widget.duration.inMilliseconds * _dragValue!).round(),
      );
    }
    return widget.position;
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _handleSeekAt(double localDx, double width) {
    final progress = (localDx / width).clamp(0.0, 1.0);
    final seekPosition = Duration(
      milliseconds: (widget.duration.inMilliseconds * progress).round(),
    );
    widget.onSeek(seekPosition);
    if (_dragging) {
      setState(() {
        _dragValue = progress;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = _progress.clamp(0.0, 1.0);
    return Column(
      children: [
        SizedBox(
          height: 32,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  if (_dragging)
                    Positioned(
                      left: (width * progress) - 24,
                      top: -8,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _formatDuration(_displayPosition),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapUp: (details) {
                      _handleSeekAt(details.localPosition.dx, width);
                    },
                    onHorizontalDragStart: (details) {
                      setState(() {
                        _dragging = true;
                        _dragValue = (details.localPosition.dx / width)
                            .clamp(0.0, 1.0);
                      });
                      _handleSeekAt(details.localPosition.dx, width);
                    },
                    onHorizontalDragUpdate: (details) {
                      _handleSeekAt(details.localPosition.dx, width);
                    },
                    onHorizontalDragEnd: (_) {
                      setState(() {
                        _dragging = false;
                        _dragValue = null;
                      });
                    },
                    child: Container(
                      height: 32,
                      color: Colors.transparent,
                      child: Center(
                        child: SizedBox(
                          height: 4,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: progress,
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.seekBarGradient,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: (width * progress) - (_dragging ? 9 : 7),
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: _dragging ? 18 : 14,
                        height: _dragging ? 18 : 14,
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accent.withValues(alpha: 0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_displayPosition),
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                _formatDuration(widget.duration),
                style: TextStyle(
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
