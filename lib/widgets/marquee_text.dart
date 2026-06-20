import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final double speed;
  final TextAlign textAlign;

  const MarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.speed = 30.0,
    this.textAlign = TextAlign.center,
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _needsScroll = false;
  double _textWidth = 0;
  double _containerWidth = 0;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfNeedsScroll();
    });
  }

  @override
  void didUpdateWidget(covariant MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.reset();
      _needsScroll = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkIfNeedsScroll();
      });
    }
  }

  void _checkIfNeedsScroll() {
    if (!mounted) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    _containerWidth = renderBox.size.width;

    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    _textWidth = textPainter.width;

    if (_textWidth > _containerWidth) {
      setState(() {
        _needsScroll = true;
      });
      _startScrolling();
    } else {
      setState(() {
        _needsScroll = false;
      });
    }
  }

  void _startScrolling() {
    final distance = _textWidth - _containerWidth + 32;
    final duration = Duration(
      milliseconds: ((distance / widget.speed) * 1000).round(),
    );
    _controller.duration = duration;
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_needsScroll) {
      return Text(
        widget.text,
        style: widget.style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: widget.textAlign,
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isPaused = !_isPaused;
          if (_isPaused) {
            _controller.stop();
          } else {
            _controller.repeat();
          }
        });
      },
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(-_controller.value * (_textWidth - _containerWidth + 32), 0),
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
      ),
    );
  }
}
