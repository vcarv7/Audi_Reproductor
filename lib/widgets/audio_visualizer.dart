import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';

class AudioVisualizer extends StatefulWidget {
  final bool isPlaying;
  final int barCount;
  final double height;

  const AudioVisualizer({
    super.key,
    required this.isPlaying,
    this.barCount = 20,
    this.height = 40,
  });

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _barHeights = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    for (int i = 0; i < widget.barCount; i++) {
      _barHeights.add(_random.nextDouble());
    }
    if (widget.isPlaying) {
      _controller.repeat();
    }
    _controller.addListener(_updateBars);
  }

  void _updateBars() {
    if (!widget.isPlaying) return;
    setState(() {
      for (int i = 0; i < _barHeights.length; i++) {
        _barHeights[i] += (_random.nextDouble() - 0.5) * 0.3;
        _barHeights[i] = _barHeights[i].clamp(0.1, 1.0);
      }
    });
  }

  @override
  void didUpdateWidget(AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
      setState(() {
        for (int i = 0; i < _barHeights.length; i++) {
          _barHeights[i] = 0.1;
        }
      });
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
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.barCount, (index) {
          return Container(
            width: 8,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: widget.height * _barHeights[index],
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  accent.withValues(alpha: 0.5),
                  accent,
                ],
              ),
              borderRadius: BorderRadius.circular(3),
            ),
          );
        }),
      ),
    );
  }
}