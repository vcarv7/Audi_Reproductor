import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../theme/app_theme.dart';
import 'gradient_seek_bar.dart';
import 'audio_visualizer.dart';
import 'player_controls.dart';
import 'options_menu_sheet.dart';
import 'full_artwork.dart';
import 'marquee_text.dart';
import 'queue_sheet.dart';

class FullPlayer extends StatelessWidget {
  final VoidCallback onCollapse;

  const FullPlayer({super.key, required this.onCollapse});

  String _getStateText(PlayerState state) {
    switch (state) {
      case PlayerState.playing:
        return 'Reproduciendo';
      case PlayerState.paused:
        return 'Pausada';
      case PlayerState.stopped:
        return 'Detenida';
      case PlayerState.completed:
        return 'Finalizada';
      case PlayerState.disposed:
        return 'Detenida';
    }
  }

  void _showQueue(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black,
      isScrollControlled: true,
      builder: (_) => const QueueSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioPlayerProvider>();
    final current = provider.currentAudio;

    return Container(
      decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    color: AppTheme.textPrimary,
                    iconSize: 32,
                    onPressed: onCollapse,
                  ),
                  Expanded(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          _getStateText(provider.playerState),
                          key: ValueKey(provider.playerState),
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    color: AppTheme.textSecondary,
                    onPressed: current == null
                        ? null
                        : () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              barrierColor: Colors.black,
                              isScrollControlled: true,
                              builder: (_) => OptionsMenuSheet(audio: current),
                            );
                          },
                  ),
                ],
              ),
            ),
            const Spacer(flex: 1),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: current == null
                  ? const SizedBox.shrink()
                  : FullArtwork(
                      key: ValueKey(current.id),
                      audio: current,
                      size: MediaQuery.of(context).size.width * 0.7,
                    ),
            ),
            const Spacer(flex: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 40,
                child: Stack(
                  children: [
                    if (provider.isPlaying)
                      Center(
                        child: AudioVisualizer(isPlaying: provider.isPlaying),
                      ),
                    if (current != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: _LikeButton(audioId: current.id),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MarqueeText(
                    text: current?.name ?? 'Sin canción',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (current?.artist != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      current!.artist!,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: 16),
            _SecondaryControls(onQueueTap: () => _showQueue(context)),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  final String audioId;

  const _LikeButton({required this.audioId});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioPlayerProvider>();
    final isLiked = provider.isLiked(audioId);
    return GestureDetector(
      onTap: () => provider.toggleLike(audioId),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isLiked ? AppTheme.accent : Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

class _SecondaryControls extends StatelessWidget {
  final VoidCallback onQueueTap;

  const _SecondaryControls({required this.onQueueTap});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioPlayerProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.queue_music_rounded, color: Colors.white),
            iconSize: 24,
            onPressed: onQueueTap,
          ),
          IconButton(
            icon: Icon(
              Icons.cast_rounded,
              color: AppTheme.textMuted.withValues(alpha: 0.5),
            ),
            iconSize: 24,
            onPressed: null,
          ),
          Expanded(
            child: Row(
              children: [
                Icon(
                  provider.volume == 0
                      ? Icons.volume_off_rounded
                      : provider.volume < 0.5
                      ? Icons.volume_down_rounded
                      : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppTheme.accent,
                      inactiveTrackColor: AppTheme.surfaceLight,
                      thumbColor: Colors.white,
                      overlayColor: AppTheme.accent.withValues(alpha: 0.2),
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                    ),
                    child: Slider(
                      value: provider.volume,
                      onChanged: (v) => provider.setVolume(v),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
