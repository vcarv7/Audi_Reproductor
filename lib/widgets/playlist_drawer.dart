import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/audio_file.dart';
import '../providers/audio_player_provider.dart';
import '../theme/app_theme.dart';

class PlaylistDrawer extends StatelessWidget {
  const PlaylistDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioPlayerProvider>();
    final playlist = provider.playlist;

    return Drawer(
      backgroundColor: AppTheme.background,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white10,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.queue_music_rounded,
                    color: AppTheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lista de reproducción',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${playlist.length} canciones',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (playlist.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Limpiar'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                      ),
                      onPressed: () => provider.clearPlaylist(),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: playlist.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.library_music_outlined,
                            size: 64,
                            color: AppTheme.textMuted.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Tu lista está vacía',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Agrega canciones para comenzar',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: playlist.length,
                      itemBuilder: (context, index) {
                        return _PlaylistItem(
                          audio: playlist[index],
                          isActive:
                              provider.currentAudio?.id == playlist[index].id,
                          isPlaying: provider.isPlaying &&
                              provider.currentAudio?.id == playlist[index].id,
                          onTap: () => provider.play(playlist[index]),
                          onRemove: () =>
                              provider.removeFromPlaylist(playlist[index].id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistItem extends StatelessWidget {
  final AudioFile audio;
  final bool isActive;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _PlaylistItem({
    required this.audio,
    required this.isActive,
    required this.isPlaying,
    required this.onTap,
    required this.onRemove,
  });

  String _formatDuration(Duration? d) {
    if (d == null) return '--:--';
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        gradient: isActive ? AppTheme.cardGradient : null,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: isActive ? AppTheme.buttonGradient : AppTheme.cardGradient,
          ),
          child: Icon(
            isPlaying
                ? Icons.equalizer_rounded
                : isActive
                    ? Icons.play_arrow_rounded
                    : Icons.music_note_rounded,
            color: isActive ? Colors.white : AppTheme.textSecondary,
            size: 22,
          ),
        ),
        title: Text(
          audio.name,
          style: TextStyle(
            color: isActive ? AppTheme.primary : AppTheme.textPrimary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: audio.artist != null
            ? Text(
                audio.artist!,
                style: TextStyle(
color: isActive
                        ? AppTheme.primary.withValues(alpha: 0.7)
                        : AppTheme.textMuted,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : Text(
                _formatDuration(audio.duration),
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 18),
          color: AppTheme.textMuted,
          onPressed: onRemove,
        ),
        onTap: onTap,
      ),
    );
  }
}