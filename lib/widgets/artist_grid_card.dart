import 'package:flutter/material.dart';
import '../models/media_collection.dart';
import '../theme/app_theme.dart';

class ArtistGridCard extends StatefulWidget {
  final Artist artist;
  final VoidCallback onTap;
  final VoidCallback? onPlay;

  const ArtistGridCard({
    super.key,
    required this.artist,
    required this.onTap,
    this.onPlay,
  });

  @override
  State<ArtistGridCard> createState() => _ArtistGridCardState();
}

class _ArtistGridCardState extends State<ArtistGridCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final artist = widget.artist;
    final isUnknown = artist.isUnknown;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isUnknown
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2A2A3E), Color(0xFF1A1A2E)],
                          )
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF8B5CF6), Color(0xFF4C1D95)],
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accent.withValues(alpha: 0.2),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    isUnknown ? Icons.question_mark_rounded : Icons.person_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 56,
                  ),
                ),
                if (widget.onPlay != null)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accent,
                      border: Border.all(color: AppTheme.background, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
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
            const SizedBox(height: 10),
            Text(
              artist.displayName,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              isUnknown
                  ? '${artist.trackCount} canc.'
                  : '${artist.trackCount} canc.',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
              ),
              maxLines: 1,
            ),
            if (!isUnknown)
              Text(
                '${artist.albumCount} álbum${artist.albumCount == 1 ? '' : 'es'}',
                style: TextStyle(
                  color: AppTheme.textMuted.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
                maxLines: 1,
              ),
          ],
        ),
      ),
    );
  }
}