---
name: add-audio-feature
description: Cómo agregar nuevas funcionalidades relacionadas con audio al reproductor (ecualizador, cola, favoritos, persistencia, etc.)
---

# Add Audio Feature

## Arquitectura del audio

Toda la lógica de audio vive en `AudioPlayerProvider` (`lib/providers/audio_player_provider.dart`).

### Streams disponibles de audioplayers

| Stream | Uso |
|---|---|
| `onPositionChanged` | Posición actual (para seek bar) |
| `onDurationChanged` | Duración total del archivo |
| `onPlayerStateChanged` | Estado: playing, paused, stopped |
| `onPlayerComplete` | Canción terminó (para auto-next) |

### Estado actual del provider

```dart
// Estado privado
AudioFile? _currentAudio;
PlayerState _playerState = PlayerState.stopped;
Duration _position = Duration.zero;
Duration _duration = Duration.zero;
bool _shuffle = false;
AudioRepeatMode _repeatMode = AudioRepeatMode.off;
bool _isSeeking = false;

// Getters públicos
AudioFile? get currentAudio
bool get isPlaying
Duration get position / duration
bool get shuffle
AudioRepeatMode get repeatMode
```

## Pasos para agregar una feature

### 1. Extender el modelo si es necesario

Editar `lib/models/audio_file.dart`. Siempre usar `copyWith()` para inmutabilidad:

```dart
class AudioFile {
  final String id;
  final String path;
  final String name;
  final String? artist;
  final Duration? duration;
  final bool isFavorite; // ← nueva propiedad

  AudioFile copyWith({
    String? id,
    String? path,
    String? name,
    String? artist,
    Duration? duration,
    bool? isFavorite,
  }) {
    return AudioFile(
      id: id ?? this.id,
      path: path ?? this.path,
      name: name ?? this.name,
      artist: artist ?? this.artist,
      duration: duration ?? this.duration,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
```

### 2. Agregar lógica al provider

En `lib/providers/audio_player_provider.dart`:

```dart
// Agregar estado privado
final Set<String> _favorites = {};

// Getter público
Set<String> get favorites => Set.unmodifiable(_favorites);

// Método que actualiza estado y notifica
void toggleFavorite(String audioId) {
  if (_favorites.contains(audioId)) {
    _favorites.remove(audioId);
  } else {
    _favorites.add(audioId);
  }
  notifyListeners();
}
```

### 3. Consumir en widgets

Usar `context.watch<AudioPlayerProvider>()` en build:

```dart
@override
Widget build(BuildContext context) {
  final provider = context.watch<AudioPlayerProvider>();
  final isFavorite = provider.favorites.contains(audio.id);

  return IconButton(
    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
    onPressed: () => provider.toggleFavorite(audio.id),
  );
}
```

## Features posibles de implementar

- **Favoritos**:Agregar propiedad `isFavorite` a AudioFile y persistir con SharedPreferences
- **Cola de reproducción**: Agregar cola dedicada separada de la playlist principal
- **Ecualizador**: Usar streams de audio data con `audioplayers` para visualización avanzada
- **Persistencia**: Guardar playlist con `shared_preferences` o `hive` para restaurar al reiniciar
- **Metadata ID3**: Usar paquete `audiotagger` para leer artist/album/cover de archivos MP3
- **Notificación media**: Agregar `audio_service` para controles en lock screen y notification bar