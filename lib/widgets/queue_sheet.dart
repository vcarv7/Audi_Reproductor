import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../theme/app_theme.dart';
import 'track_card.dart';

class QueueSheet extends StatelessWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioPlayerProvider>();
    final playlist = provider.playlist;
    final current = provider.currentAudio;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.queue_music_rounded,
                      color: AppTheme.accent,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Cola de reproducción',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${playlist.length}',
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Expanded(
                child: playlist.isEmpty
                    ? Center(
                        child: Text(
                          'La cola está vacía',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        itemCount: playlist.length,
                        itemBuilder: (context, index) {
                          final audio = playlist[index];
                          final isCurrent = current?.id == audio.id;
                          return TrackCard(
                            audio: audio,
                            isActive: isCurrent,
                            isPlaying: provider.isPlaying && isCurrent,
                            onTap: () {
                              provider.play(audio);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
