import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/audio_file.dart';
import '../providers/audio_player_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/mini_player.dart';
import '../widgets/full_player.dart';
import '../widgets/track_card.dart';
import '../widgets/album_grid_card.dart';
import '../widgets/artist_grid_card.dart';
import '../widgets/genre_grid_card.dart';
import 'settings_screen.dart';
import 'search_screen.dart';
import 'album_detail_screen.dart';
import 'artist_detail_screen.dart';
import 'genre_detail_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioPlayerProvider>().scanDeviceMusic(autoPlay: false);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  void _showErrorSnackbar(String message) {
    if (_showingError) return;
    _showingError = true;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: AppTheme.accent, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppTheme.surfaceLight,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      ).closed.then((_) => _showingError = false);
  }

  void _showScanResultSnackbar(int count) {
    context.read<AudioPlayerProvider>().markScanResultShown();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: AppTheme.accent, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  count == 0
                      ? 'No se encontraron canciones'
                      : 'Se encontraron $count ${count == 1 ? 'canción' : 'canciones'}',
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.surfaceLight,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioPlayerProvider>();
    final playlist = provider.playlist;
    final hasCurrentAudio = provider.currentAudio != null;

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

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(provider),
                  if (provider.isScanning && playlist.isEmpty)
                    Expanded(
                      child: _ScanningWidget(
                        count: provider.scannedCount,
                      ),
                    )
                  else if (playlist.isEmpty && !provider.permissionGranted)
                    Expanded(
                      child: _EmptyState(
                        isPermissionDenied: true,
                        onRetry: () => provider.scanDeviceMusic(),
                      ),
                    )
                  else if (playlist.isEmpty)
                    Expanded(
                      child: _EmptyState(
                        isPermissionDenied: false,
                        onRetry: () => provider.scanDeviceMusic(),
                      ),
                    )
                  else
                    Expanded(
                      child: Column(
                        children: [
                          _buildTabBar(),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              physics: const PageScrollPhysics().applyTo(
                                const BouncingScrollPhysics(),
                              ),
                              children: [
                                _TracksTab(
                                  hasCurrentAudio: hasCurrentAudio,
                                ),
                                _AlbumsTab(),
                                _GenresTab(),
                                _ArtistsTab(),
                              ],
                            ),
                          ),
                        ],
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
      floatingActionButton: _buildFab(provider, playlist, hasCurrentAudio),
    );
  }

  Widget? _buildFab(AudioPlayerProvider provider, List<AudioFile> playlist, bool hasCurrentAudio) {
    if (_tabController.index != 0) return null;
    if (playlist.isEmpty) return null;
    return Padding(
      padding: EdgeInsets.only(bottom: hasCurrentAudio ? 80 : 16),
      child: FloatingActionButton.extended(
        onPressed: () {
          context.read<AudioPlayerProvider>().playList(playlist);
        },
        backgroundColor: AppTheme.accent,
        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
        label: const Text(
          'Reproducir todo',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AudioPlayerProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SettingsScreen(),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  AppTheme.background,
                  BlendMode.lighten,
                ),
                child: Image.asset(
                  'lib/assets/icons/screen.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'EcoPlayer',
            style: TextStyle(
              color: AppTheme.accent,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              Icons.search_rounded,
              color: AppTheme.textSecondary,
            ),
            iconSize: 26,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SearchScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: AppTheme.accent,
        unselectedLabelColor: AppTheme.textMuted,
        indicatorColor: AppTheme.accent,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
        tabs: const [
          Tab(text: 'Pistas'),
          Tab(text: 'Álbumes'),
          Tab(text: 'Géneros'),
          Tab(text: 'Artistas'),
        ],
      ),
    );
  }
}

class _ScanningWidget extends StatelessWidget {
  final int count;

  const _ScanningWidget({required this.count});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: AppTheme.accent,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Escaneando tu música...',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$count ${count == 1 ? 'canción encontrada' : 'canciones encontradas'}',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TracksTab extends StatelessWidget {
  final bool hasCurrentAudio;

  const _TracksTab({required this.hasCurrentAudio});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioPlayerProvider>();
    final playlist = provider.playlist;

    return Column(
      children: [
        _CountBadge(count: playlist.length),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.scanDeviceMusic(autoPlay: false),
            color: AppTheme.accent,
            backgroundColor: AppTheme.surface,
            child: ListView.builder(
              padding: EdgeInsets.only(
                top: 4,
                bottom: hasCurrentAudio ? 140 : 90,
              ),
              itemCount: playlist.length,
              itemBuilder: (context, index) {
                final audio = playlist[index];
                final isActive = provider.currentAudio?.id == audio.id;
                final isPlaying = provider.isPlaying && isActive;
                return TrackCard(
                  audio: audio,
                  isActive: isActive,
                  isPlaying: isPlaying,
                  onTap: () => provider.play(audio),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _AlbumsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioPlayerProvider>();
    final albums = provider.albums;

    if (albums.isEmpty) {
      return Center(
        child: Text(
          'No hay álbumes',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        _CountBadge(count: albums.length),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.scanDeviceMusic(autoPlay: false),
            color: AppTheme.accent,
            backgroundColor: AppTheme.surface,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
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
          ),
        ),
      ],
    );
  }
}

class _GenresTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioPlayerProvider>();
    final genres = provider.genres;

    if (genres.isEmpty) {
      return Center(
        child: Text(
          'No hay géneros',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        _CountBadge(count: genres.length),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.scanDeviceMusic(autoPlay: false),
            color: AppTheme.accent,
            backgroundColor: AppTheme.surface,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.7,
              ),
              itemCount: genres.length,
              itemBuilder: (context, index) {
                final genre = genres[index];
                return GenreGridCard(
                  genre: genre,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => GenreDetailScreen(genre: genre),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ArtistsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioPlayerProvider>();
    final artists = provider.artists;

    if (artists.isEmpty) {
      return Center(
        child: Text(
          'No hay artistas',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        _CountBadge(count: artists.length),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.scanDeviceMusic(autoPlay: false),
            color: AppTheme.accent,
            backgroundColor: AppTheme.surface,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
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
          ),
        ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.accent.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: AppTheme.accent,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
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
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.cardGradient,
                border: Border.all(
                  color: AppTheme.accent.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 56,
                color: AppTheme.accent,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
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