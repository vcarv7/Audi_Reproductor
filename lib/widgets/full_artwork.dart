import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/audio_file.dart';
import '../providers/audio_player_provider.dart';
import '../theme/app_theme.dart';

class FullArtwork extends StatelessWidget {
  final AudioFile audio;
  final double size;

  const FullArtwork({
    super.key,
    required this.audio,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 30,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FutureBuilder<Uint8List?>(
          future: _loadArtwork(context),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
                width: size,
                height: size,
                gaplessPlayback: true,
              );
            }
            return Container(
              decoration: BoxDecoration(
                gradient: AppTheme.cardGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.music_note,
                color: Colors.white,
                size: 80,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<Uint8List?> _loadArtwork(BuildContext context) {
    final id = int.tryParse(audio.id);
    if (id == null) return Future.value(null);
    return context.read<AudioPlayerProvider>().getArtwork(id, size: 500);
  }
}
