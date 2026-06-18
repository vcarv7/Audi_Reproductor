import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../models/audio_file.dart';

enum AudioRepeatMode { off, all, one }

class AudioPlayerProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final List<AudioFile> _playlist = [];

  AudioFile? _currentAudio;
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _shuffle = false;
  AudioRepeatMode _repeatMode = AudioRepeatMode.off;
  bool _isSeeking = false;
  StreamSubscription? _positionSub;
  StreamSubscription? _durationSub;
  StreamSubscription? _playerStateSub;
  StreamSubscription? _completeSub;

  AudioPlayerProvider() {
    _initPlayer();
  }

  List<AudioFile> get playlist => List.unmodifiable(_playlist);
  AudioFile? get currentAudio => _currentAudio;
  PlayerState get playerState => _playerState;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isPlaying => _playerState == PlayerState.playing;
  bool get isPaused => _playerState == PlayerState.paused;
  bool get shuffle => _shuffle;
  AudioRepeatMode get repeatMode => _repeatMode;

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

  Future<void> pickAndAddFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result != null) {
      for (final file in result.files) {
        if (file.path != null) {
          final audio = AudioFile(
            id: file.path!,
            path: file.path!,
            name: p.basenameWithoutExtension(file.path!),
          );
          _playlist.add(audio);
        }
      }
      notifyListeners();

      if (_currentAudio == null && _playlist.isNotEmpty) {
        await play(_playlist.first);
      }
    }
  }

  Future<void> play(AudioFile audio) async {
    _currentAudio = audio;
    await _player.play(DeviceFileSource(audio.path));
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

  void removeFromPlaylist(String id) {
    _playlist.removeWhere((a) => a.id == id);
    if (_currentAudio?.id == id) {
      stop();
      _currentAudio = null;
    }
    notifyListeners();
  }

  void clearPlaylist() {
    _playlist.clear();
    stop();
    _currentAudio = null;
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