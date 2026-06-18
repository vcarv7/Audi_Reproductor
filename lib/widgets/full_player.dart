import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../theme/app_theme.dart';
import 'vinyl_disc.dart';
import 'gradient_seek_bar.dart';
import 'audio_visualizer.dart';
import 'player_controls.dart';

class FullPlayer extends StatelessWidget {
  final VoidCallback onCollapse;

  const FullPlayer({super.key, required this.onCollapse});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioPlayerProvider>();
    final current = provider.currentAudio;

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    color: AppTheme.textPrimary,
                    iconSize: 32,
                    onPressed: onCollapse,
                  ),
                  const Text(
                    'Reproduciendo',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    color: AppTheme.textSecondary,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const Spacer(flex: 1),
            VinylDisc(
              isPlaying: provider.isPlaying,
              size: MediaQuery.of(context).size.width * 0.55,
            ),
            const Spacer(flex: 1),
            AudioVisualizer(isPlaying: provider.isPlaying),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    current?.name ?? 'Sin canción',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (current?.artist != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      current!.artist!,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            GradientSeekBar(
              position: provider.position,
              duration: provider.duration,
              onSeek: (pos) => provider.seek(pos),
              isPlaying: provider.isPlaying,
            ),
            const SizedBox(height: 24),
            const PlayerControls(),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}