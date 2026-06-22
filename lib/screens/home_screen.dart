import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/audio_file.dart';
import '../providers/audio_player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/mini_player.dart';
import '../widgets/full_player.dart';
import '../widgets/styled_snackbar.dart';
import '../widgets/track_card.dart';
import '../widgets/album_grid_card.dart';
import '../widgets/artist_grid_card.dart';
import 'home/widgets/animated_header.dart';
import 'home/widgets/animated_count_badge.dart';
import 'home/widgets/artist_banner.dart';
import 'home/widgets/featured_albums.dart';
import 'home/widgets/genre_chips.dart';
import 'home/widgets/hero_play_all.dart';
import 'home/widgets/now_playing_card.dart';
import 'home/widgets/pill_tab_bar.dart';
import 'home/widgets/recent_carousel.dart';
import 'home/widgets/vinyl_scan_state.dart';
import 'album_detail_screen.dart';
import 'artist_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  bool _showFullPlayer = false;
  bool _showingError = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late TabController _tabController;
  late AnimationController _bgController;

  static const _tabLabels = ['Pistas', 'Álbumes', 'Géneros', 'Artistas'];

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
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioPlayerProvider>().scanDeviceMusic(autoPlay: false);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  void _showErrorSnackbar(String message) {
    if (_showingError) return;
    _showingError = true;
    StyledSnackBar.show(
      context,
      message: message,
      type: SnackbarType.error,
    );
    Future.delayed(const Duration(seconds: 3), () {
      _showingError = false;
    });
  }

  void _showScanResultSnackbar(int count) {
    context.read<AudioPlayerProvider>().markScanResultShown();
    StyledSnackBar.show(
      context,
      message: count == 0
          ? 'No se encontraron canciones'
          : 'Se encontraron $count ${count == 1 ? 'canción' : 'canciones'}',
      type: count == 0 ? SnackbarType.info : SnackbarType.success,
      duration: const Duration(seconds: 4),
    );
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

  int _currentCount(AudioPlayerProvider provider) {
    switch (_tabController.index) {
      case 0:
        return provider.playlist.length;
      case 1:
        return provider.albums.length;
      case 2:
        return provider.genres.length;
      case 3:
        return provider.artists.length;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioPlayerProvider>();
    final playlist = provider.playlist;
    final hasCurrentAudio = provider.currentAudio != null;
    final accent = provider.dynamicAccent;

    if (provider.lastError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showErrorSnackbar(provider.lastError!);
      });
    }

    if (!provider.isScanning &&
        provider.lastScanCount > 0 &&
        !provider.scanResultShown &&
        playlist.length == provider.lastScanCount) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showScanResultSnackbar(playlist.length);
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_showFullPlayer) {
          _toggleFullPlayer();
          return;
        }

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: Text(
              'Salir de EcoPlayer',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            content: Text(
              '¿Estás seguro que quieres salir?',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: Text(
                  'Salir',
                  style: TextStyle(color: AppTheme.accent),
                ),
              ),
            ],
          ),
        );

        if (shouldExit ?? false) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: AnimatedBuilder(
          animation: _bgController,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(
                    -0.5 + 0.3 * _bgController.value,
                    -0.8 + 0.2 * _bgController.value,
                  ),
                  radius: 1.5,
                  colors: [
                    accent.withValues(alpha: 0.06),
                    AppTheme.background,
                    AppTheme.background,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  SafeArea(
                    child: Column(
                      children: [
                        const AnimatedHeader(),
                        PillTabBar(
                          controller: _tabController,
                          labels: _tabLabels,
                        ),
                        AnimatedCountBadge(
                          count: _currentCount(provider),
                          tabController: _tabController,
                        ),
                        Expanded(
                          child: _buildContent(
                            provider,
                            playlist,
                            hasCurrentAudio,
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    AudioPlayerProvider provider,
    List<AudioFile> playlist,
    bool hasCurrentAudio,
  ) {
    if (provider.isScanning && playlist.isEmpty) {
      return VinylScanState(count: provider.scannedCount);
    }
    if (playlist.isEmpty && !provider.permissionGranted) {
      return _EmptyState(
        isPermissionDenied: true,
        onRetry: () => provider.scanDeviceMusic(),
      );
    }
    if (playlist.isEmpty) {
      return _EmptyState(
        isPermissionDenied: false,
        onRetry: () => provider.scanDeviceMusic(),
      );
    }
    return TabBarView(
      controller: _tabController,
      physics: const PageScrollPhysics().applyTo(
        const BouncingScrollPhysics(),
      ),
      children: [
        _TracksTab(
          playlist: playlist,
          provider: provider,
          hasCurrentAudio: hasCurrentAudio,
        ),
        _AlbumsTab(
          albums: provider.albums,
          provider: provider,
        ),
        _GenresTab(genres: provider.genres),
        _ArtistsTab(
          artists: provider.artists,
          provider: provider,
        ),
      ],
    );
  }
}

class _TracksTab extends StatelessWidget {
  final List<AudioFile> playlist;
  final AudioPlayerProvider provider;
  final bool hasCurrentAudio;

  const _TracksTab({
    required this.playlist,
    required this.provider,
    required this.hasCurrentAudio,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => provider.scanDeviceMusic(autoPlay: false),
      color: AppTheme.accent,
      backgroundColor: AppTheme.surface,
      child: ListView(
        padding: EdgeInsets.only(
          top: 4,
          bottom: hasCurrentAudio ? 140 : 100,
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          HeroPlayAll(
            onTap: () => provider.playList(playlist),
            totalSongs: playlist.length,
          ),
          if (hasCurrentAudio)
            NowPlayingCard(
              audio: provider.currentAudio!,
              position: provider.position,
              duration: provider.duration,
              isPlaying: provider.isPlaying,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      body: FullPlayer(onCollapse: () => Navigator.pop(context)),
                    ),
                  ),
                );
              },
            ),
          RecentCarousel(
            recent: provider.recentlyPlayed,
            onTap: (audio) => provider.play(audio),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(
                  Icons.queue_music_rounded,
                  color: AppTheme.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Todas las canciones',
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
          ...playlist.asMap().entries.map((entry) {
            final audio = entry.value;
            final isActive = provider.currentAudio?.id == audio.id;
            final isPlaying = provider.isPlaying && isActive;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
              child: TrackCard(
                audio: audio,
                isActive: isActive,
                isPlaying: isPlaying,
                onTap: () => provider.play(audio),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AlbumsTab extends StatelessWidget {
  final List<dynamic> albums;
  final AudioPlayerProvider provider;

  const _AlbumsTab({required this.albums, required this.provider});

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) {
      return Center(
        child: Text(
          'No hay álbumes',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.scanDeviceMusic(autoPlay: false),
      color: AppTheme.accent,
      backgroundColor: AppTheme.surface,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          FeaturedAlbums(
            albums: albums.cast(),
            onPlay: (album) => provider.playAlbum(album),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: [
                Icon(
                  Icons.album_rounded,
                  color: AppTheme.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Todos los álbumes',
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              return AlbumGridCard(
                album: album,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AlbumDetailScreen(album: album),
                  ),
                ),
                onPlay: () => provider.playAlbum(album),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GenresTab extends StatelessWidget {
  final List<dynamic> genres;

  const _GenresTab({required this.genres});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context
          .read<AudioPlayerProvider>()
          .scanDeviceMusic(autoPlay: false),
      color: AppTheme.accent,
      backgroundColor: AppTheme.surface,
      child: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 100),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          GenreChips(genres: genres.cast()),
        ],
      ),
    );
  }
}

class _ArtistsTab extends StatelessWidget {
  final List<dynamic> artists;
  final AudioPlayerProvider provider;

  const _ArtistsTab({required this.artists, required this.provider});

  @override
  Widget build(BuildContext context) {
    if (artists.isEmpty) {
      return Center(
        child: Text(
          'No hay artistas',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.scanDeviceMusic(autoPlay: false),
      color: AppTheme.accent,
      backgroundColor: AppTheme.surface,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ArtistBanner(
            artists: artists.cast(),
            onPlay: (artist) => provider.playArtist(artist),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Row(
              children: [
                Icon(
                  Icons.people_rounded,
                  color: AppTheme.textSecondary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Todos los artistas',
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 16,
              childAspectRatio: 0.65,
            ),
            itemCount: artists.length,
            itemBuilder: (context, index) {
              final artist = artists[index];
              return ArtistGridCard(
                artist: artist,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ArtistDetailScreen(artist: artist),
                  ),
                ),
                onPlay: () => provider.playArtist(artist),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isPermissionDenied;
  final VoidCallback onRetry;

  const _EmptyState({
    required this.isPermissionDenied,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioPlayerProvider>();
    final accent = provider.dynamicAccent;
    final icon = isPermissionDenied
        ? Icons.lock_outline_rounded
        : Icons.library_music_rounded;
    final title = isPermissionDenied ? 'Permiso requerido' : 'No hay música';
    final message = isPermissionDenied
        ? 'Otorga permiso para acceder a tu música y poder reproducirla'
        : 'No se encontró música en tu dispositivo';
    final buttonText = isPermissionDenied ? 'Otorgar permiso' : 'Reescanear';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: 0.3),
                    accent.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(
                  color: accent.withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 64,
                color: accent,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accent, accent.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onRetry,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          buttonText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
