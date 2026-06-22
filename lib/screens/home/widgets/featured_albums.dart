import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/media_collection.dart';
import '../../../providers/audio_player_provider.dart';
import '../../../theme/app_theme.dart';
import '../../album_detail_screen.dart';

class FeaturedAlbums extends StatelessWidget {
  final List<Album> albums;
  final ValueChanged<Album> onPlay;

  const FeaturedAlbums({
    super.key,
    required this.albums,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) return const SizedBox.shrink();

    final featured = albums.take(5).toList();
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
                Icons.star_rounded,
                color: accent,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Text(
                'Destacados',
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
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: featured.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final album = featured[index];
              return _FeaturedAlbumCard(
                album: album,
                accent: accent,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AlbumDetailScreen(album: album),
                  ),
                ),
                onPlay: () => onPlay(album),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FeaturedAlbumCard extends StatefulWidget {
  final Album album;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback onPlay;

  const _FeaturedAlbumCard({
    required this.album,
    required this.accent,
    required this.onTap,
    required this.onPlay,
  });

  @override
  State<_FeaturedAlbumCard> createState() => _FeaturedAlbumCardState();
}

class _FeaturedAlbumCardState extends State<_FeaturedAlbumCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final isUnknown = widget.album.isUnknown;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 170,
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: 'album-art-${widget.album.id}',
                    child: Container(
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        gradient: isUnknown
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF2A2A3E), Color(0xFF1A1A2E)],
                              )
                            : LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  widget.accent,
                                  widget.accent.withValues(alpha: 0.4),
                                ],
                              ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.album_rounded,
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: Material(
                      color: widget.accent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: widget.onPlay,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.album.displayName,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.album.displayArtist,
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 11,
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
      ),
    );
  }
}
