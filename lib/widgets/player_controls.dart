import 'package:flutter/material.dart' hide RepeatMode;
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../theme/app_theme.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioPlayerProvider>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ShuffleButton(provider: provider),
        const SizedBox(width: 16),
        _IconButton(
          icon: Icons.skip_previous_rounded,
          size: 36,
          onPressed: () => provider.playPrevious(),
        ),
        const SizedBox(width: 16),
        _PlayPauseButton(provider: provider),
        const SizedBox(width: 16),
        _IconButton(
          icon: Icons.skip_next_rounded,
          size: 36,
          onPressed: () => provider.playNext(),
        ),
        const SizedBox(width: 16),
        _RepeatButton(provider: provider),
      ],
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final AudioPlayerProvider provider;

  const _PlayPauseButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.buttonGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          provider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 36,
        ),
        onPressed: () => provider.togglePlayPause(),
      ),
    );
  }
}

class _ShuffleButton extends StatelessWidget {
  final AudioPlayerProvider provider;

  const _ShuffleButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.shuffle_rounded,
        color: provider.shuffle ? provider.dynamicAccent : AppTheme.textMuted,
        size: 24,
      ),
      onPressed: () => provider.toggleShuffle(),
    );
  }
}

class _RepeatButton extends StatelessWidget {
  final AudioPlayerProvider provider;

  const _RepeatButton({required this.provider});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    switch (provider.repeatMode) {
      case AudioRepeatMode.off:
        icon = Icons.repeat_rounded;
      case AudioRepeatMode.all:
        icon = Icons.repeat_rounded;
      case AudioRepeatMode.one:
        icon = Icons.repeat_one_rounded;
    }
    return IconButton(
      icon: Icon(
        icon,
        color: provider.repeatMode != AudioRepeatMode.off
            ? provider.dynamicAccent
            : AppTheme.textMuted,
        size: 24,
      ),
      onPressed: () => provider.toggleRepeatMode(),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback onPressed;

  const _IconButton({
    required this.icon,
    required this.size,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: Colors.white, size: size),
      onPressed: onPressed,
    );
  }
}