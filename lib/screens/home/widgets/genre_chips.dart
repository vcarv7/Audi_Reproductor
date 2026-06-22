import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/media_collection.dart';
import '../../../providers/audio_player_provider.dart';
import '../../../theme/app_theme.dart';
import '../../genre_detail_screen.dart';

class GenreChips extends StatelessWidget {
  final List<Genre> genres;

  const GenreChips({super.key, required this.genres});

  static const Map<String, List<Color>> _genreGradients = {
    'rock': [Color(0xFFE50914), Color(0xFF7A0007)],
    'pop': [Color(0xFFFF1493), Color(0xFF8B0054)],
    'jazz': [Color(0xFF1E90FF), Color(0xFF003875)],
    'clásica': [Color(0xFF8B5CF6), Color(0xFF4C1D95)],
    'classical': [Color(0xFF8B5CF6), Color(0xFF4C1D95)],
    'electrónica': [Color(0xFF00CED1), Color(0xFF006B6E)],
    'electronic': [Color(0xFF00CED1), Color(0xFF006B6E)],
    'edm': [Color(0xFF00CED1), Color(0xFF006B6E)],
    'hip': [Color(0xFFFF8C00), Color(0xFF8B4500)],
    'rap': [Color(0xFFFF8C00), Color(0xFF8B4500)],
    'reggaeton': [Color(0xFFADFF2F), Color(0xFF4F8B0E)],
    'reggae': [Color(0xFFADFF2F), Color(0xFF4F8B0E)],
    'metal': [Color(0xFF4B0082), Color(0xFF1A0030)],
    'k-pop': [Color(0xFFFF69B4), Color(0xFF8B2D5C)],
    'kpop': [Color(0xFFFF69B4), Color(0xFF8B2D5C)],
    'r&b': [Color(0xFFDC143C), Color(0xFF7A0825)],
    'folk': [Color(0xFFB8860B), Color(0xFF5A4306)],
    'country': [Color(0xFFB8860B), Color(0xFF5A4306)],
    'blues': [Color(0xFF4169E1), Color(0xFF1A2E7A)],
    'punk': [Color(0xFFFF4500), Color(0xFF8B1F00)],
    'indie': [Color(0xFF20B2AA), Color(0xFF0E5C57)],
    'soul': [Color(0xFF8B4513), Color(0xFF4A2509)],
    'funk': [Color(0xFFFF6347), Color(0xFF8B2F22)],
    'techno': [Color(0xFF00BFFF), Color(0xFF00668B)],
    'house': [Color(0xFF7B68EE), Color(0xFF3A2D7A)],
    'salsa': [Color(0xFFFF8C00), Color(0xFF8B4500)],
    'cumbia': [Color(0xFFFFA500), Color(0xFF8B5A00)],
    'bachata': [Color(0xFFFF1493), Color(0xFF8B0054)],
  };

  static const Map<String, IconData> _genreIcons = {
    'rock': Icons.electric_bolt_rounded,
    'pop': Icons.star_rounded,
    'jazz': Icons.music_note_rounded,
    'clásica': Icons.piano_rounded,
    'classical': Icons.piano_rounded,
    'electrónica': Icons.graphic_eq_rounded,
    'electronic': Icons.graphic_eq_rounded,
    'hip': Icons.headphones_rounded,
    'rap': Icons.headphones_rounded,
    'reggaeton': Icons.local_fire_department_rounded,
    'metal': Icons.bolt_rounded,
    'k-pop': Icons.favorite_rounded,
    'kpop': Icons.favorite_rounded,
    'r&b': Icons.favorite_border_rounded,
    'folk': Icons.eco_rounded,
    'country': Icons.terrain_rounded,
    'blues': Icons.mood_rounded,
    'punk': Icons.warning_rounded,
    'indie': Icons.eco_rounded,
    'soul': Icons.favorite_rounded,
    'funk': Icons.flash_on_rounded,
    'techno': Icons.settings_input_component_rounded,
    'house': Icons.home_rounded,
    'salsa': Icons.local_fire_department_rounded,
  };

  static List<Color> _getGradient(String genre) {
    final lower = genre.toLowerCase();
    for (final entry in _genreGradients.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return const [Color(0xFF2A2A3E), Color(0xFF1A1A2E)];
  }

  static IconData _getIcon(String genre) {
    final lower = genre.toLowerCase();
    for (final entry in _genreIcons.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return Icons.music_note_rounded;
  }

  @override
  Widget build(BuildContext context) {
    if (genres.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No hay géneros',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

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
                Icons.category_rounded,
                color: accent,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Explorar por género',
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
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: genres.map((genre) {
              final colors = genre.isUnknown
                  ? const [Color(0xFF2A2A3E), Color(0xFF1A1A2E)]
                  : _getGradient(genre.name);
              final icon = genre.isUnknown
                  ? Icons.question_mark_rounded
                  : _getIcon(genre.name);
              return _GenreChip(
                genre: genre,
                colors: colors,
                icon: icon,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GenreDetailScreen(genre: genre),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _GenreChip extends StatefulWidget {
  final Genre genre;
  final List<Color> colors;
  final IconData icon;
  final VoidCallback onTap;

  const _GenreChip({
    required this.genre,
    required this.colors,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_GenreChip> createState() => _GenreChipState();
}

class _GenreChipState extends State<_GenreChip> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.colors,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.colors.first.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                widget.genre.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${widget.genre.trackCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
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
