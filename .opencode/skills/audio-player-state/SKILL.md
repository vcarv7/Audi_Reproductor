---
name: audio-player-state
description: Documentación detallada del estado y lógica del AudioPlayerProvider, incluyendo el flujo de datos, ciclo de vida del player y patrones de uso
---

# Audio Player State

## Arquitectura del estado

```
┌─────────────────────────────────────────────────────┐
│                  AudioPlayerProvider                  │
│                                                       │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐ │
│  │  Playlist   │  │ Current Audio │  │ Player State │ │
│  │ List<Audio> │  │  AudioFile?  │  │  PlayerState  │ │
│  └─────────────┘  └──────────────┘  └─────────────┘ │
│                                                       │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐ │
│  │  Position   │  │   Duration   │  │   Seeking    │ │
│  │  Duration   │  │   Duration   │  │    bool      │ │
│  └─────────────┘  └──────────────┘  └─────────────┘ │
│                                                       │
│  ┌─────────────┐  ┌──────────────┐                    │
│  │   Shuffle   │  │ Repeat Mode  │                    │
│  │    bool     │  │ AudioRepeat   │                    │
│  └─────────────┘  └──────────────┘                    │
└─────────────────────────────────────────────────────┘
         │                    │                    │
    notifyListeners()    notifyListeners()   notifyListeners()
         │                    │                    │
         ▼                    ▼                    ▼
    ┌─────────┐        ┌──────────┐        ┌──────────┐
    │  Mini   │        │  Full    │        │ Playlist │
    │ Player  │        │  Player  │        │  Drawer  │
    └─────────┘        └──────────┘        └──────────┘
```

## Ciclo de vida del AudioPlayer

```
                    ┌─────────┐
          pickAnd   │ empty   │
          AddFiles  │ playlist│
                    └────┬────┘
                         │ first file added
                         ▼
    ┌────────────────────────────────┐
    │ play(firstAudio)               │
    │ _currentAudio = audio          │
    │ _player.play(DeviceFileSource)  │
    │ notifyListeners()              │
    └────────────┬───────────────────┘
                 │
                 ▼
    ┌────────────┴──────────────┐
    │  PlayerState.playing      │◄──────┐
    └────────────┬──────────────┘       │
                 │                      │
        ┌────────┴────────┐             │
        │   pause()       │             │ resume()
        │   togglePlay    │             │ togglePlay
        │   Pause()        │             │ Pause()
        ▼                 │             │
    ┌────────────┐        │             │
    │ PlayerState│        │             │
    │  .paused   │        │             │
    └────────────┘        │             │
                          │             │
                 onPlayerComplete       │
                          │             │
                          ▼             │
                   _playNext()──────────┘
                   (según repeatMode y shuffle)
```

## Flujo de datos de posición/duración

```
AudioPlayer streams          AudioPlayerProvider           UI Widgets
─────────────────           ────────────────────           ───────────
onPositionChanged ───────► _position (si !_isSeeking) ──► GradientSeekBar
                                                          MiniPlayer progress
                                                          FullPlayer position text

onDurationChanged ────────► _duration                    ──► GradientSeekBar
                           _playlist[idx].duration          FullPlayer duration text
                           _currentAudio.duration

                          _isSeeking = true  ◄─────── User drag on seek bar
                          _position = dragPos
                          _player.seek(pos)
                          _isSeeking = false ◄─────── Seek complete
```

## Modos de repetición y shuffle

### AudioRepeatMode cycle
```
off ──toggleRepeat──► all ──toggleRepeat──► one ──toggleRepeat──► off
```

### Comportamiento en _playNext()
| Repeat Mode | Al terminar playlist | Shuffle | Comportamiento |
|---|---|---|---|
| off | Se detiene | no | Siguiente secuencial |
| off | Se detiene | yes | Random diferente |
| all | Vuelve al inicio | no | Siguiente secuencial |
| all | Vuelve al inicio | yes | Random diferente |
| one | Repite misma canción | n/a | Repite actual |

### playNext() manual (botón skip)
Siempre avanza, sin importar repeatMode. Shuffle aplica random si está activo.

### playPrevious() manual (botón previous)
Retrocede secuencialmente. Si está en la primera canción, va a la última.

## Modelo AudioFile

```dart
class AudioFile {
  final String id;       // Path del archivo (usado como ID único)
  final String path;     // Path completo del archivo
  final String name;     // Nombre sin extensión (via path package)
  final String? artist;  // Artista (null si no disponible)
  final Duration? duration; // Duración (null hasta que se reproduce)

  // Getters
  String get displayName;  // "Artist - Name" o "Name"
  String get fileName;      // Nombre del archivo con extensión

  // Inmutabilidad
  AudioFile copyWith({...});
}
```

## Patrón de uso desde widgets

```dart
// En build method - escuchar todos los cambios
final provider = context.watch<AudioPlayerProvider>();

// En callbacks - obtener sin escuchar
final provider = context.read<AudioPlayerProvider>();
provider.togglePlayPause();

// Para granularidad - Consumer
Consumer<AudioPlayerProvider>(
  builder: (context, provider, child) {
    return Text(provider.currentAudio?.name ?? 'Sin canción');
  },
)
```