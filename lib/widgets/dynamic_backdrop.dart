import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../theme/app_theme.dart';

class DynamicBackdrop extends StatefulWidget {
  final Widget child;
  final double accentAlpha;
  final bool animated;

  const DynamicBackdrop({
    super.key,
    required this.child,
    this.accentAlpha = 0.04,
    this.animated = false,
  });

  @override
  State<DynamicBackdrop> createState() => _DynamicBackdropState();
}

class _DynamicBackdropState extends State<DynamicBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    if (widget.animated) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.watch<AudioPlayerProvider>().dynamicAccent;

    final alignX = widget.animated ? -0.5 + 0.3 * _controller.value : -0.5;
    final alignY = widget.animated ? -0.8 + 0.2 * _controller.value : -0.8;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(alignX, alignY),
                radius: 1.5,
                colors: [
                  accent.withValues(alpha: widget.accentAlpha),
                  Colors.transparent,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}
