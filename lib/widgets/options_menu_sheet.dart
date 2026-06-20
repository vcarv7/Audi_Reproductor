import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/audio_file.dart';
import '../providers/audio_player_provider.dart';
import '../theme/app_theme.dart';
import 'song_info_sheet.dart';

class OptionsMenuSheet extends StatelessWidget {
  final AudioFile audio;

  const OptionsMenuSheet({super.key, required this.audio});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: AppTheme.buttonGradient,
                    ),
                    child: const Icon(
                      Icons.music_note_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          audio.name,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          audio.artist ?? 'Artista desconocido',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            _OptionTile(
              icon: Icons.delete_outline_rounded,
              title: 'Eliminar canción',
              subtitle: 'Quitar de la cola de reproducción',
              onTap: () async {
                Navigator.of(context).pop();
                final provider = context.read<AudioPlayerProvider>();
                await provider.removeFromPlaylist(audio);
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text('"${audio.name}" eliminada de la cola'),
                        backgroundColor: AppTheme.surfaceLight,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                }
              },
            ),
            _OptionTile(
              icon: Icons.info_outline_rounded,
              title: 'Información',
              subtitle: 'Ver detalles de la canción',
              onTap: () {
                Navigator.of(context).pop();
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  barrierColor: Colors.black,
                  isScrollControlled: true,
                  builder: (_) => SongInfoSheet(audio: audio),
                );
              },
            ),
            _OptionTile(
              icon: Icons.bedtime_outlined,
              title: 'Temporizador',
              subtitle: 'Apagar después de un tiempo',
              onTap: () {
                Navigator.of(context).pop();
                _showSleepTimerPicker(context);
              },
            ),
            _OptionTile(
              icon: Icons.speed_rounded,
              title: 'Velocidad',
              subtitle: 'Ajustar velocidad de reproducción',
              onTap: () {
                Navigator.of(context).pop();
                _showSpeedPicker(context);
              },
            ),
            _OptionTile(
              icon: Icons.equalizer_rounded,
              title: 'Ecualizador',
              subtitle: 'En desarrollo',
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text('Ecualizador próximamente'),
                      backgroundColor: AppTheme.surfaceLight,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showSleepTimerPicker(BuildContext context) {
    final provider = context.read<AudioPlayerProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black,
      builder: (_) => _SleepTimerSheet(provider: provider),
    );
  }

  void _showSpeedPicker(BuildContext context) {
    final provider = context.read<AudioPlayerProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black,
      builder: (_) => _SpeedPickerSheet(provider: provider),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppTheme.surfaceLight,
                ),
                child: Icon(icon, color: AppTheme.accent, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SleepTimerSheet extends StatelessWidget {
  final AudioPlayerProvider provider;

  const _SleepTimerSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    final options = [
      {'label': '15 minutos', 'duration': const Duration(minutes: 15)},
      {'label': '30 minutos', 'duration': const Duration(minutes: 30)},
      {'label': '45 minutos', 'duration': const Duration(minutes: 45)},
      {'label': '1 hora', 'duration': const Duration(hours: 1)},
      {'label': 'Fin de la canción', 'duration': const Duration(minutes: 0)},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    Icons.bedtime_outlined,
                    color: AppTheme.accent,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Temporizador',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            ...options.map((opt) {
              final isLast = opt['label'] == 'Fin de la canción';
              final isActive = !isLast &&
                  provider.sleepTimerDuration == opt['duration'];
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (isLast) {
                      provider.setSleepTimer(null);
                    } else {
                      provider.setSleepTimer(opt['duration'] as Duration);
                    }
                    Navigator.of(context).pop();
                    final label = isLast ? 'cancelado' : opt['label'];
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text('Temporizador $label'),
                          backgroundColor: AppTheme.surfaceLight,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            opt['label'] as String,
                            style: TextStyle(
                              color: isActive
                                  ? AppTheme.accent
                                  : AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isActive)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.accent,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (provider.sleepTimerDuration != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      provider.cancelSleepTimer();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancelar temporizador',
                      style: TextStyle(color: AppTheme.accent),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SpeedPickerSheet extends StatelessWidget {
  final AudioPlayerProvider provider;

  const _SpeedPickerSheet({required this.provider});

  @override
  Widget build(BuildContext context) {
    final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                    Icons.speed_rounded,
                    color: AppTheme.accent,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Velocidad de reproducción',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: speeds.map((speed) {
                final isActive = (provider.playbackSpeed - speed).abs() < 0.01;
                return Padding(
                  padding: const EdgeInsets.all(2),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        provider.setPlaybackSpeed(speed);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text('Velocidad: ${speed}x'),
                              backgroundColor: AppTheme.surfaceLight,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                            ),
                          );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.accent
                              : AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive
                                ? AppTheme.accent
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          '${speed}x',
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ).padding(horizontal: 20, vertical: 16),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

extension _PaddingWidget on Widget {
  Widget padding({double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }
}
