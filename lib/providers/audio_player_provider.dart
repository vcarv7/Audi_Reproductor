import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/audio_file.dart';
import '../models/media_collection.dart';
import '../theme/app_theme.dart';

enum AudioRepeatMode { off, all, one }

class AudioPlayerProvider extends ChangeNotifier {
  static const int _minSongDurationMs = 60000; // 60 segundos

  final AudioPlayer _player = AudioPlayer();
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final List<AudioFile> _playlist = [];

  AudioFile? _currentAudio;
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _shuffle = false;
  AudioRepeatMode _repeatMode = AudioRepeatMode.off;
  bool _isSeeking = false;
  bool _isScanning = false;
  bool _permissionGranted = false;
  int _scannedCount = 0;
  int _lastScanCount = 0;
  bool _scanResultShown = false;
  String? _lastError;
  double _playbackSpeed = 1.0;
  double _volume = 1.0;
  Timer? _sleepTimer;
  Duration? _sleepTimerDuration;
  final Set<String> _likedIds = {};
  final List<String> _recentlyPlayedIds = [];
  final Map<String, Color> _dominantColorCache = {};
  Color _dynamicAccent = AppTheme.accent;
  bool _isTransitioning = false;
  int _consecutiveErrors = 0;
  static const int _maxConsecutiveErrors = 3;

  List<Album> _albums = [];
  List<Artist> _artists = [];
  List<Genre> _genres = [];
  final Map<int, Uint8List> _artworkCache = {};

  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playerStateSub;
  StreamSubscription? _completeSub;

  AudioPlayerProvider() {
    _initPlayer();
    _loadRecentlyPlayed();
  }

  List<AudioFile> get playlist => List.unmodifiable(_playlist);
  List<Album> get albums => List.unmodifiable(_albums);
  List<Artist> get artists => List.unmodifiable(_artists);
  List<Genre> get genres => List.unmodifiable(_genres);

  AudioFile? get currentAudio => _currentAudio;
  PlayerState get playerState => _playerState;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _playerState == PlayerState.playing;
  bool get isPaused => _playerState == PlayerState.paused;
  bool get shuffle => _shuffle;
  AudioRepeatMode get repeatMode => _repeatMode;
  bool get isScanning => _isScanning;
  bool get permissionGranted => _permissionGranted;
  int get scannedCount => _scannedCount;
  int get lastScanCount => _lastScanCount;
  bool get scanResultShown => _scanResultShown;
  String? get lastError => _lastError;
  double get playbackSpeed => _playbackSpeed;
  double get volume => _volume;
  Duration? get sleepTimerDuration => _sleepTimerDuration;

  bool isLiked(String id) => _likedIds.contains(id);

  Color get dynamicAccent => _dynamicAccent;

  List<AudioFile> get recentlyPlayed {
    final list = <AudioFile>[];
    for (final id in _recentlyPlayedIds) {
      final audio = _playlist.firstWhere(
        (a) => a.id == id,
        orElse: () => AudioFile(id: '', path: '', name: ''),
      );
      if (audio.id.isNotEmpty) list.add(audio);
    }
    return list;
  }

  Future<void> _loadRecentlyPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList('recently_played') ?? [];
      _recentlyPlayedIds.clear();
      _recentlyPlayedIds.addAll(ids);
    } catch (_) {}
  }

  Future<void> _saveRecentlyPlayed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('recently_played', _recentlyPlayedIds);
    } catch (_) {}
  }

  Color _colorFromString(String s) {
    var hash = 0;
    for (var i = 0; i < s.length; i++) {
      hash = s.codeUnitAt(i) + ((hash << 5) - hash);
      hash = hash & 0xFFFFFFFF;
    }
    final h = (hash.abs() % 360).toDouble();
    final hsl = HSLColor.fromAHSL(1.0, h, 0.7, 0.55);
    return hsl.toColor();
  }

  void _updateDynamicAccent(AudioFile audio) {
    final id = audio.id;
    if (_dominantColorCache.containsKey(id)) {
      _dynamicAccent = _dominantColorCache[id]!;
    } else {
      final color = _colorFromString(id);
      _dominantColorCache[id] = color;
      _dynamicAccent = color;
    }
  }

  void _trackPlay(AudioFile audio) {
    _recentlyPlayedIds.remove(audio.id);
    _recentlyPlayedIds.insert(0, audio.id);
    while (_recentlyPlayedIds.length > 6) {
      _recentlyPlayedIds.removeLast();
    }
    _saveRecentlyPlayed();
  }

  Future<Uint8List?> getArtwork(int id, {int size = 300}) async {
    if (_artworkCache.containsKey(id)) {
      return _artworkCache[id];
    }
    final artwork = await _audioQuery.queryArtwork(
      id,
      ArtworkType.AUDIO,
      size: size,
      quality: 80,
    );
    if (artwork != null) {
      _artworkCache[id] = artwork;
    }
    return artwork;
  }

  void _initPlayer() {
    _positionSub = _player.onPositionChanged.listen((pos) {
      if (!_isSeeking) {
        _position = pos;
        notifyListeners();
      }
    });

    _durationSub = _player.onDurationChanged.listen((dur) {
      _duration = dur;
      if (_currentAudio != null) {
        final idx = _playlist.indexWhere((a) => a.id == _currentAudio!.id);
        if (idx != -1) {
          _playlist[idx] = _playlist[idx].copyWith(duration: dur);
          _currentAudio = _currentAudio!.copyWith(duration: dur);
        }
      }
      notifyListeners();
    });

    _playerStateSub = _player.onPlayerStateChanged.listen((state) {
      _playerState = state;
      notifyListeners();
    });

    _completeSub = _player.onPlayerComplete.listen((_) {
      _playNext();
    });
  }

  Future<bool> requestPermission() async {
    _permissionGranted = await _audioQuery.checkAndRequest(
      retryRequest: true,
    );
    notifyListeners();
    return _permissionGranted;
  }

  bool _isValidSong(SongModel song) {
    if (song.data.isEmpty) return false;
    if (song.duration == null || song.duration! < _minSongDurationMs) {
      return false;
    }
    return true;
  }

  String? _cleanMetadata(String? value) {
    if (value == null || value.isEmpty || value == '<unknown>') {
      return null;
    }
    return value;
  }

  AudioFile _songToAudioFile(SongModel song) {
    String? artist = _cleanMetadata(song.artist);
    String? album = _cleanMetadata(song.album);
    String? name = _cleanMetadata(song.title);

    if (artist == null || album == null || name == null) {
      final parsed = _parseFileMetadata(song.data);
      artist ??= parsed.artist;
      album ??= parsed.album;
      name ??= parsed.name;
    }

    return AudioFile(
      id: song.id.toString(),
      path: song.data,
      name: name,
      artist: artist,
      album: album,
      duration: Duration(milliseconds: song.duration!),
    );
  }

  ({String? artist, String? album, String name}) _parseFileMetadata(String path) {
    final fileName = p.basenameWithoutExtension(path);
    String? artist;
    String? album;
    String name = fileName;

    final dashIndex = fileName.indexOf(' - ');
    if (dashIndex > 0) {
      final firstPart = fileName.substring(0, dashIndex).trim();
      final secondPart = fileName.substring(dashIndex + 3).trim();
      final isTrackNumber = RegExp(r'^\d+$').hasMatch(firstPart);

      if (!isTrackNumber && firstPart.length >= 2 && secondPart.isNotEmpty) {
        artist = firstPart;
        name = secondPart;
      } else if (isTrackNumber && secondPart.isNotEmpty) {
        name = secondPart;
      }
    } else {
      final trackMatch = RegExp(r'^\d+[\s\.\-]+').firstMatch(fileName);
      if (trackMatch != null) {
        name = fileName.substring(trackMatch.end).trim();
      }
    }

    final pathParts = p.split(path);
    if (pathParts.length >= 3) {
      const genericFolders = {
        'Music', 'Download', 'Downloads', 'Audio', 'Media', 'Songs',
      };
      final albumFolder = pathParts[pathParts.length - 2];
      final artistFolder = pathParts[pathParts.length - 3];

      if (!genericFolders.contains(albumFolder)) {
        album = albumFolder;
      }
      if (!genericFolders.contains(artistFolder) &&
          albumFolder != artistFolder) {
        artist = artistFolder;
      }
    }

    return (artist: artist, album: album, name: name);
  }

  Future<void> scanDeviceMusic({bool autoPlay = false}) async {
    if (_isScanning) return;

    _isScanning = true;
    _scannedCount = 0;
    _scanResultShown = false;
    notifyListeners();

    try {
      _permissionGranted = await _audioQuery.checkAndRequest(
        retryRequest: true,
      );

      if (!_permissionGranted) {
        _isScanning = false;
        notifyListeners();
        return;
      }

      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      _playlist.clear();
      _artworkCache.clear();
      for (final song in songs) {
        if (_isValidSong(song)) {
          _playlist.add(_songToAudioFile(song));
          _scannedCount++;
          notifyListeners();
        }
      }

      await _loadAlbums();
      await _loadArtists();
      await _loadGenres();

      if (autoPlay && _playlist.isNotEmpty && _currentAudio == null) {
        await play(_playlist.first);
      }

      _lastScanCount = _playlist.length;
    } catch (e) {
      debugPrint('Error scanning music: $e');
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  void markScanResultShown() {
    _scanResultShown = true;
    notifyListeners();
  }

  Future<void> _loadAlbums() async {
    final albumsData = await _audioQuery.queryAlbums(
      sortType: AlbumSortType.ALBUM,
      orderType: OrderType.ASC_OR_SMALLER,
      ignoreCase: true,
    );

    final List<Album> albums = [];
    bool hasUnknown = false;

    for (final a in albumsData) {
      final cleanedName = _cleanMetadata(a.album);
      if (cleanedName == null) continue;

      final count = _playlist
          .where((song) => song.album?.toLowerCase() == cleanedName.toLowerCase())
          .length;

      if (count == 0) continue;

      albums.add(Album(
        id: a.id,
        name: cleanedName,
        artistName: _cleanMetadata(a.artist),
        trackCount: count,
      ));
    }

    // Agregar "Álbum desconocido" si hay canciones sin álbum
    final unknownCount = _playlist.where((song) => song.album == null).length;
    if (unknownCount > 0) {
      hasUnknown = true;
      albums.add(const Album(
        id: -1,
        name: 'Álbum desconocido',
        trackCount: 0,
        isUnknown: true,
      ));
    }

    _albums = hasUnknown
        ? [...albums.where((a) => !a.isUnknown), ...albums.where((a) => a.isUnknown)]
        : albums;
  }

  Future<void> _loadArtists() async {
    final artistsData = await _audioQuery.queryArtists(
      sortType: ArtistSortType.ARTIST,
      orderType: OrderType.ASC_OR_SMALLER,
      ignoreCase: true,
    );

    final List<Artist> artists = [];
    int unknownCount = 0;

    for (final a in artistsData) {
      final cleanedName = _cleanMetadata(a.artist);
      if (cleanedName == null) continue;

      final trackCount = _playlist
          .where((song) => song.artist?.toLowerCase() == cleanedName.toLowerCase())
          .length;

      if (trackCount == 0) continue;

      artists.add(Artist(
        id: a.id,
        name: cleanedName,
        trackCount: trackCount,
        albumCount: a.numberOfAlbums ?? 0,
      ));
    }

    // Agregar "Artista desconocido" si hay canciones sin artista
    unknownCount = _playlist.where((song) => song.artist == null).length;
    if (unknownCount > 0) {
      artists.add(const Artist(
        id: -1,
        name: 'Artista desconocido',
        trackCount: 0,
        isUnknown: true,
      ));
    }

    _artists = artists;
  }

  Future<void> _loadGenres() async {
    final genresData = await _audioQuery.queryGenres();

    final List<Genre> genres = [];

    for (final g in genresData) {
      final cleanedName = _cleanMetadata(g.genre);
      if (cleanedName == null) continue;

      // Cargar canciones de este género y filtrar por _isValidSong
      final genreSongs = await _audioQuery.queryAudiosFrom(
        AudiosFromType.GENRE_ID,
        g.id,
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
      );

      final validCount = genreSongs.where(_isValidSong).length;

      if (validCount == 0) continue;

      genres.add(Genre(
        id: g.id,
        name: cleanedName,
        trackCount: validCount,
      ));
    }

    _genres = genres;
  }

  // Obtener canciones de un álbum
  List<AudioFile> songsByAlbum(Album album) {
    if (album.isUnknown) {
      return _playlist.where((a) => a.album == null).toList();
    }
    return _playlist
        .where((a) => a.album?.toLowerCase() == album.name.toLowerCase())
        .toList();
  }

  // Obtener canciones de un artista
  List<AudioFile> songsByArtist(Artist artist) {
    if (artist.isUnknown) {
      return _playlist.where((a) => a.artist == null).toList();
    }
    return _playlist
        .where((a) => a.artist?.toLowerCase() == artist.name.toLowerCase())
        .toList();
  }

  // Obtener canciones de un género
  Future<List<AudioFile>> songsByGenre(Genre genre) async {
    if (genre.isUnknown) {
      return _playlist.where((a) => a.album == null && a.artist == null).toList();
    }
    final songs = await _audioQuery.queryAudiosFrom(
      AudiosFromType.GENRE_ID,
      genre.id,
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
    );
    return songs.where(_isValidSong).map(_songToAudioFile).toList();
  }

  // Reproducir lista de canciones
  Future<void> playList(
    List<AudioFile> songs, {
    int startIndex = 0,
    bool startRandom = false,
  }) async {
    if (songs.isEmpty) return;
    _playlist.clear();
    _playlist.addAll(songs);
    if (startRandom) {
      startIndex = Random().nextInt(songs.length);
      _shuffle = true;
      _repeatMode = AudioRepeatMode.all;
      notifyListeners();
    } else if (startIndex >= songs.length) {
      startIndex = 0;
    }
    await play(songs[startIndex]);
  }

  // Reproducir álbum completo
  Future<void> playAlbum(Album album) async {
    final songs = songsByAlbum(album);
    if (songs.isNotEmpty) {
      await playList(songs);
    }
  }

  // Reproducir artista completo
  Future<void> playArtist(Artist artist) async {
    final songs = songsByArtist(artist);
    if (songs.isNotEmpty) {
      await playList(songs);
    }
  }

  // Reproducir género completo
  Future<void> playGenre(Genre genre) async {
    final songs = await songsByGenre(genre);
    if (songs.isNotEmpty) {
      await playList(songs);
    }
  }

  // Búsqueda
  List<AudioFile> search(String query) {
    if (query.trim().isEmpty) return [];
    final lower = query.toLowerCase();
    return _playlist.where((audio) {
      return audio.name.toLowerCase().contains(lower) ||
          (audio.artist?.toLowerCase().contains(lower) ?? false) ||
          (audio.album?.toLowerCase().contains(lower) ?? false);
    }).toList();
  }

  Future<void> play(AudioFile audio) async {
    if (_isTransitioning) return;
    _isTransitioning = true;
    try {
      _currentAudio = audio;
      _lastError = null;
      _updateDynamicAccent(audio);
      _trackPlay(audio);
      try {
        await _player.play(DeviceFileSource(audio.path));
        _consecutiveErrors = 0;
      } catch (e) {
        _consecutiveErrors++;
        _lastError = 'Error al reproducir "${audio.name}"';
        debugPrint(_lastError);
        notifyListeners();
        if (_consecutiveErrors >= _maxConsecutiveErrors) {
          _consecutiveErrors = 0;
          await stop();
          return;
        }
        await _advanceToNext();
        return;
      }
      notifyListeners();
    } finally {
      _isTransitioning = false;
    }
  }

  Future<void> resume() async {
    await _player.resume();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
    _position = Duration.zero;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    if (_isTransitioning) return;
    _isTransitioning = true;
    _isSeeking = true;
    _position = position;
    notifyListeners();
    try {
      await _player.seek(position);
    } catch (e) {
      debugPrint('Error en seek: $e');
    } finally {
      _isSeeking = false;
      _isTransitioning = false;
    }
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else if (isPaused) {
      await resume();
    } else if (_currentAudio != null) {
      await play(_currentAudio!);
    }
  }

  Future<void> _playNext() async {
    await _advanceToNext();
  }

  Future<void> _advanceToNext() async {
    if (_playlist.isEmpty || _currentAudio == null) return;

    if (_repeatMode == AudioRepeatMode.one) {
      await play(_currentAudio!);
      return;
    }

    final idx = _playlist.indexWhere((a) => a.id == _currentAudio!.id);
    if (idx == -1) return;

    int nextIdx;

    if (_shuffle) {
      if (_playlist.length == 1) {
        nextIdx = 0;
      } else {
        nextIdx = Random().nextInt(_playlist.length);
        while (nextIdx == idx) {
          nextIdx = Random().nextInt(_playlist.length);
        }
      }
    } else {
      nextIdx = idx + 1;
      if (nextIdx >= _playlist.length) {
        if (_repeatMode == AudioRepeatMode.all) {
          nextIdx = 0;
        } else {
          await stop();
          return;
        }
      }
    }

    await play(_playlist[nextIdx]);
  }

  Future<void> playNext() async {
    await _advanceToNext();
  }

  Future<void> playPrevious() async {
    if (_playlist.isEmpty || _currentAudio == null) return;
    final idx = _playlist.indexWhere((a) => a.id == _currentAudio!.id);
    if (idx <= 0) {
      await play(_playlist.last);
    } else {
      await play(_playlist[idx - 1]);
    }
  }

  void toggleShuffle() {
    _shuffle = !_shuffle;
    notifyListeners();
  }

  void toggleRepeatMode() {
    switch (_repeatMode) {
      case AudioRepeatMode.off:
        _repeatMode = AudioRepeatMode.all;
      case AudioRepeatMode.all:
        _repeatMode = AudioRepeatMode.one;
      case AudioRepeatMode.one:
        _repeatMode = AudioRepeatMode.off;
    }
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    await _player.setPlaybackRate(speed);
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
    notifyListeners();
  }

  void toggleLike(String id) {
    if (_likedIds.contains(id)) {
      _likedIds.remove(id);
    } else {
      _likedIds.add(id);
    }
    notifyListeners();
  }

  void setSleepTimer(Duration? duration) {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerDuration = duration;
    if (duration != null) {
      _sleepTimer = Timer(duration, () {
        pause();
        _sleepTimer = null;
        _sleepTimerDuration = null;
        notifyListeners();
      });
    }
    notifyListeners();
  }

  void cancelSleepTimer() {
    setSleepTimer(null);
  }

  Future<void> removeFromPlaylist(AudioFile audio) async {
    final index = _playlist.indexWhere((a) => a.id == audio.id);
    if (index == -1) return;

    final wasCurrent = _currentAudio?.id == audio.id;
    _playlist.removeAt(index);

    if (wasCurrent) {
      if (_playlist.isEmpty) {
        await stop();
      } else {
        final nextIndex = index >= _playlist.length ? 0 : index;
        await play(_playlist[nextIndex]);
      }
    } else {
      notifyListeners();
    }
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  int getCacheSize() {
    int total = 0;
    for (final bytes in _artworkCache.values) {
      total += bytes.length;
    }
    return total;
  }

  void clearArtworkCache() {
    _artworkCache.clear();
    notifyListeners();
  }

  int removeMissingFiles() {
    final initial = _playlist.length;
    _playlist.removeWhere((audio) {
      try {
        return !File(audio.path).existsSync();
      } catch (_) {
        return true;
      }
    });
    final removed = initial - _playlist.length;
    notifyListeners();
    return removed;
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _completeSub?.cancel();
    _sleepTimer?.cancel();
    _player.dispose();
    super.dispose();
  }
}