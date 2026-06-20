import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double speed;
  final TextAlign textAlign;
  final Duration pauseDuration;

  const MarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.speed = 40.0,
    this.textAlign = TextAlign.center,
    this.pauseDuration = const Duration(seconds: 6),
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.addStatusListener(_onStatusChange);
  }

  void _onStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      Future.delayed(widget.pauseDuration, () {
        if (mounted) {
          _controller.forward(from: 0);
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onStatusChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;

        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          textDirection: TextDirection.ltr,
          maxLines: 1,
        )..layout();

        final textWidth = textPainter.width;

        if (textWidth <= containerWidth) {
          if (_controller.isAnimating) {
            _controller.stop();
          }
          return Text(
            widget.text,
            style: widget.style,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: widget.textAlign,
          );
        }

        final distance = textWidth - containerWidth + 40;
        final duration = Duration(
          milliseconds: ((distance / widget.speed) * 1000).round(),
        );
        _controller.duration = duration;
        if (_controller.status != AnimationStatus.forward &&
            _controller.status != AnimationStatus.completed) {
          _controller.forward(from: 0);
        }

        return ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  -_controller.value * (textWidth - containerWidth + 40),
                  0,
                ),
                child: child,
              );
            },
            child: Text(
              widget.text,
              style: widget.style,
              maxLines: 1,
              textAlign: widget.textAlign,
            ),
          ),
        );
      },
    );
  }
}
