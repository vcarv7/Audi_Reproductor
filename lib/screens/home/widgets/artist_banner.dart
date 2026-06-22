import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/media_collection.dart';
import '../../../providers/audio_player_provider.dart';
import '../../../theme/app_theme.dart';
import '../../artist_detail_screen.dart';

class ArtistBanner extends StatelessWidget {
  final List<Artist> artists;
  final ValueChanged<Artist> onPlay;

  const ArtistBanner({
    super.key,
    required this.artists,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    if (artists.isEmpty) return const SizedBox.shrink();

    final featured = artists.take(3).toList();
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
                Icons.people_alt_rounded,
                color: accent,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Artistas destacados',
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
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: featured.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final artist = featured[index];
              return _ArtistBannerCard(
                artist: artist,
                accent: accent,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ArtistDetailScreen(artist: artist),
                  ),
                ),
                onPlay: () => onPlay(artist),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ArtistBannerCard extends StatefulWidget {
  final Artist artist;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  const _ArtistBannerCard({
    required this.artist,
    required this.accent,
    required this.onTap,
    required this.onPlay,
  });

  @override
  State<_ArtistBannerCard> createState() => _ArtistBannerCardState();
}

class _ArtistBannerCardState extends State<_ArtistBannerCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final isUnknown = widget.artist.isUnknown;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.96),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                isUnknown
                    ? const Color(0xFF2A2A3E)
                    : widget.accent.withValues(alpha: 0.7),
                isUnknown
                    ? const Color(0xFF1A1A2E)
                    : widget.accent.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Hero(
                tag: 'artist-art-${widget.artist.id}',
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isUnknown
                        ? Icons.question_mark_rounded
                        : Icons.person_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.artist.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.artist.trackCount} canciones',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Material(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: const StadiumBorder(),
                      child: InkWell(
                        customBorder: const StadiumBorder(),
                        onTap: widget.onPlay,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Reproducir',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
