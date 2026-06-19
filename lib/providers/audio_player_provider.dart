import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path/path.dart' as p;
import '../models/audio_file.dart';
import '../models/media_collection.dart';

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
  Future<void> playList(List<AudioFile> songs, {int startIndex = 0}) async {
    if (songs.isEmpty) return;
    _playlist.clear();
    _playlist.addAll(songs);
    if (startIndex >= songs.length) startIndex = 0;
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
    _currentAudio = audio;
    _lastError = null;
    try {
      await _player.play(DeviceFileSource(audio.path));
    } catch (e) {
      _lastError = 'Error al reproducir "${audio.name}"';
      debugPrint(_lastError);
      notifyListeners();
      await _playNext();
      return;
    }
    notifyListeners();
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
    _isSeeking = true;
    _position = position;
    notifyListeners();
    await _player.seek(position);
    _isSeeking = false;
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
    if (_playlist.isEmpty || _currentAudio == null) return;

    final idx = _playlist.indexWhere((a) => a.id == _currentAudio!.id);

    if (_repeatMode == AudioRepeatMode.one) {
      await play(_currentAudio!);
      return;
    }

    int nextIdx;
    if (_shuffle) {
      nextIdx = (idx + 1 + (_playlist.length - 1)) % _playlist.length;
      if (_playlist.length > 1) {
        while (nextIdx == idx) {
          nextIdx = (idx + 1 + (_playlist.length - 1)) % _playlist.length;
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
    if (_playlist.isEmpty || _currentAudio == null) return;
    final idx = _playlist.indexWhere((a) => a.id == _currentAudio!.id);
    int nextIdx;
    if (_shuffle) {
      nextIdx = (idx + 1 + (_playlist.length - 1)) % _playlist.length;
    } else {
      nextIdx = (idx + 1) % _playlist.length;
    }
    if (nextIdx >= _playlist.length) nextIdx = 0;
    await play(_playlist[nextIdx]);
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

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _completeSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}