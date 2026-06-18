import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphism_card.dart';
import '../widgets/mini_player.dart';
import '../widgets/full_player.dart';
import '../widgets/playlist_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _showFullPlayer = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFullPlayer() {
    setState(() {
      _showFullPlayer = !_showFullPlayer;
      if (_showFullPlayer) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioPlayerProvider>();
    final playlist = provider.playlist;
    final hasCurrentAudio = provider.currentAudio != null;

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      drawer: hasCurrentAudio ? const PlaylistDrawer() : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (hasCurrentAudio)
                          IconButton(
                            icon: const Icon(Icons.queue_music_rounded),
                            color: AppTheme.textPrimary,
                            iconSize: 28,
                            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                          )
                        else
                          const SizedBox(width: 48),
                        Column(
                          children: [
                            const Text(
                              'AUDI PLAYER',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 3,
                              ),
                            ),
                            Text(
                              '${playlist.length} canciones',
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.sort_rounded),
                          color: AppTheme.textSecondary,
                          iconSize: 24,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  if (playlist.isEmpty)
                    Expanded(
                      child: _EmptyState(onAdd: () => provider.pickAndAddFiles()),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.only(
                          bottom: hasCurrentAudio ? 80 : 16,
                          top: 8,
                        ),
                        itemCount: playlist.length,
                        itemBuilder: (context, index) {
                          final audio = playlist[index];
                          final isActive = provider.currentAudio?.id == audio.id;
                          final isPlaying = provider.isPlaying && isActive;
                          return _PlaylistCard(
                            audio: audio,
                            isActive: isActive,
                            isPlaying: isPlaying,
                            onTap: () => provider.play(audio),
                            onRemove: () => provider.removeFromPlaylist(audio.id),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            if (hasCurrentAudio && !_showFullPlayer)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: MiniPlayer(onExpand: _toggleFullPlayer),
              ),
            if (hasCurrentAudio && _showFullPlayer)
              Positioned.fill(
                child: FadeTransition(
                  opacity: _animation,
                  child: FullPlayer(onCollapse: _toggleFullPlayer),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => provider.pickAndAddFiles(),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Agregar'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.cardGradient,
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                size: 56,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Bienvenido a Audi Player',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Agrega archivos de audio para comenzar a reproducir tu música',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.folder_open_rounded),
              label: const Text('Seleccionar archivos'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final dynamic audio;
  final bool isActive;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _PlaylistCard({
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
    return GlassmorphismCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      opacity: isActive ? 0.25 : 0.1,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isActive ? AppTheme.buttonGradient : AppTheme.cardGradient,
            ),
            child: Center(
              child: isPlaying
                  ? const SizedBox(
                      width: 20,
                      height: 14,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _Bar(barHeight: 14),
                          _Bar(barHeight: 8),
                          _Bar(barHeight: 12),
                        ],
                      ),
                    )
                  : Icon(
                      isActive ? Icons.play_arrow_rounded : Icons.music_note_rounded,
                      color: isActive ? Colors.white : AppTheme.textSecondary,
                      size: 24,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  audio.name,
                  style: TextStyle(
                    color: isActive ? AppTheme.primary : AppTheme.textPrimary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  audio.artist ?? _formatDuration(audio.duration),
                  style: TextStyle(
                    color: isActive
                        ? AppTheme.primary.withValues(alpha: 0.7)
                        : AppTheme.textMuted,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: AppTheme.textMuted),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double barHeight;

  const _Bar({required this.barHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: barHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}