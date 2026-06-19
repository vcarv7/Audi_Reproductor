import 'package:flutter/material.dart';
import '../models/media_collection.dart';

class GenreGridCard extends StatefulWidget {
  final Genre genre;
  final VoidCallback onTap;
  final VoidCallback? onPlay;

  const GenreGridCard({
    super.key,
    required this.genre,
    required this.onTap,
    this.onPlay,
  });

  @override
  State<GenreGridCard> createState() => _GenreGridCardState();
}

class _GenreGridCardState extends State<GenreGridCard> {
  double _scale = 1.0;

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
      if (lower.contains(entry.key)) return entry.value;
    }
    return Icons.music_note_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final genre = widget.genre;
    final isUnknown = genre.isUnknown;
    final colors = isUnknown
        ? const [Color(0xFF2A2A3E), Color(0xFF1A1A2E)]
        : _getGradient(genre.name);
    final icon = isUnknown ? Icons.question_mark_rounded : _getIcon(genre.name);

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.first.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10,
                bottom: -10,
                child: Icon(
                  icon,
                  size: 90,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: Colors.white, size: 28),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          genre.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${genre.trackCount} canciones',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (widget.onPlay != null)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: widget.onPlay,
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
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