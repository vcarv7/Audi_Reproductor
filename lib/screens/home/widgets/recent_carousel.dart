import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/audio_file.dart';
import '../../../providers/audio_player_provider.dart';
import '../../../theme/app_theme.dart';

class RecentCarousel extends StatelessWidget {
  final List<AudioFile> recent;
  final ValueChanged<AudioFile> onTap;

  const RecentCarousel({
    super.key,
    required this.recent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (recent.isEmpty) return const SizedBox.shrink();

    final provider = context.watch<AudioPlayerProvider>();
    final accent = provider.dynamicAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: accent,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Recientes',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recent.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final audio = recent[index];
              return _RecentCard(
                audio: audio,
                accent: accent,
                onTap: () => onTap(audio),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentCard extends StatefulWidget {
  final AudioFile audio;
  final Color accent;
  final VoidCallback onTap;

  const _RecentCard({
    required this.audio,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_RecentCard> createState() => _RecentCardState();
}

class _RecentCardState extends State<_RecentCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 130,
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 110,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.accent,
                      widget.accent.withValues(alpha: 0.4),
                      const Color(0xFF1A0000),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.music_note_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.audio.name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.audio.artist ?? 'Desconocido',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
