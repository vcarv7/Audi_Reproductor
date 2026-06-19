import 'package:flutter/material.dart';
import '../models/audio_file.dart';
import '../theme/app_theme.dart';
import 'glassmorphism_card.dart';

class TrackCard extends StatelessWidget {
  final AudioFile audio;
  final bool isActive;
  final bool isPlaying;
  final VoidCallback onTap;

  const TrackCard({
    super.key,
    required this.audio,
    required this.isActive,
    required this.isPlaying,
    required this.onTap,
  });

  String _formatDuration(Duration? d) {
    if (d == null) return '--:--';
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphismCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      opacity: isActive ? 0.25 : 0.1,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isActive ? AppTheme.buttonGradient : AppTheme.cardGradient,
            ),
            child: Center(
              child: isPlaying
                  ? const SizedBox(
                      width: 20,
                      height: 14,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _Bar(barHeight: 14),
                          _Bar(barHeight: 8),
                          _Bar(barHeight: 12),
                        ],
                      ),
                    )
                  : Icon(
                      isActive ? Icons.play_arrow_rounded : Icons.music_note_rounded,
                      color: isActive ? Colors.white : AppTheme.textSecondary,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  audio.name,
                  style: TextStyle(
                    color: isActive ? AppTheme.accent : AppTheme.textPrimary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  audio.artist ?? 'Artista desconocido',
                  style: TextStyle(
                    color: isActive
                        ? AppTheme.accent.withValues(alpha: 0.7)
                        : AppTheme.textMuted,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (audio.duration != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                _formatDuration(audio.duration),
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double barHeight;

  const _Bar({required this.barHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: barHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}