---
name: flutter-testing
description: Cómo escribir y ejecutar tests para el reproductor de audio, incluyendo tests unitarios del provider, tests de widgets y mocks de audioplayers
---

# Flutter Testing

## Comandos

```bash
flutter test                    # Ejecutar todos los tests
flutter test test/foo_test.dart # Ejecutar un test específico
flutter test --coverage         # Ejecutar con cobertura
```

## Estructura de tests

```
test/
├── models/
│   └── audio_file_test.dart
├── providers/
│   └── audio_player_provider_test.dart
├── widgets/
│   ├── mini_player_test.dart
│   └── player_controls_test.dart
└── widget_test.dart           # Test básico de smoke
```

## Test unitario del modelo

```dart
// test/models/audio_file_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:audi_reproductor/models/audio_file.dart';

void main() {
  group('AudioFile', () {
    test('displayName returns name only when no artist', () {
      final audio = AudioFile(id: '1', path: '/test/song.mp3', name: 'Song');
      expect(audio.displayName, 'Song');
    });

    test('displayName returns artist - name when artist exists', () {
      final audio = AudioFile(
        id: '1', path: '/test/song.mp3', name: 'Song', artist: 'Artist',
      );
      expect(audio.displayName, 'Artist - Song');
    });

    test('copyWith preserves unchanged fields', () {
      final audio = AudioFile(id: '1', path: '/test.mp3', name: 'Test');
      final copy = audio.copyWith(duration: Duration(minutes: 3));
      expect(copy.id, '1');
      expect(copy.name, 'Test');
      expect(copy.duration, Duration(minutes: 3));
    });
  });
}
```

## Test del Provider con mock

```dart
// test/providers/audio_player_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:audi_reproductor/providers/audio_player_provider.dart';

void main() {
  group('AudioPlayerProvider', () {
    late AudioPlayerProvider provider;

    setUp(() {
      provider = AudioPlayerProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('initial state is correct', () {
      expect(provider.playlist.isEmpty, true);
      expect(provider.currentAudio, isNull);
      expect(player.isPlaying, false);
      expect(provider.shuffle, false);
      expect(provider.repeatMode, AudioRepeatMode.off);
    });

    test('toggleShuffle toggles value', () {
      expect(provider.shuffle, false);
      provider.toggleShuffle();
      expect(provider.shuffle, true);
      provider.toggleShuffle();
      expect(provider.shuffle, false);
    });

    test('toggleRepeatMode cycles through modes', () {
      expect(provider.repeatMode, AudioRepeatMode.off);
      provider.toggleRepeatMode();
      expect(provider.repeatMode, AudioRepeatMode.all);
      provider.toggleRepeatMode();
      expect(provider.repeatMode, AudioRepeatMode.one);
      provider.toggleRepeatMode();
      expect(provider.repeatMode, AudioRepeatMode.off);
    });

    test('formatDuration formats correctly', () {
      expect(provider.formatDuration(Duration(minutes: 3, seconds: 5)), '03:05');
      expect(provider.formatDuration(Duration.zero), '00:00');
      expect(provider.formatDuration(Duration(hours: 1, minutes: 30)), '90:00');
    });

    test('clearPlaylist clears everything', () {
      // Nota: no se puede agregar sin picker, pero se puede testear la lógica
      provider.clearPlaylist();
      expect(provider.playlist.isEmpty, true);
      expect(provider.currentAudio, isNull);
    });
  });
}
```

## Test de widgets

```dart
// test/widgets/mini_player_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:audi_reproductor/providers/audio_player_provider.dart';
import 'package:audi_reproductor/widgets/mini_player.dart';

void main() {
  testWidgets('MiniPlayer renders null when no audio', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: () => AudioPlayerProvider(),
        child: const MaterialApp(
          home: Scaffold(
            body: MiniPlayer(onExpand: () {}),
          ),
        ),
      ),
    );

    expect(find.byType(SizedBox), findsOneWidget);
  });
}
```

## Notas importantes

- **No mockear `AudioPlayer` directamente** - `audioplayers` se inicializa en el constructor del provider, lo que hace difícil hacer test unitarios del reproductor real sin un dispositivo
- **Usar `AudioPlayerProvider` sin reproducir audio real** en tests - solo testear lógica de estado
- **Los tests de integración** requieren un dispositivo físico para probar reproducción real
- **`flutter test`** corre en el entorno Dart VM, no en un dispositivo, así que plugins nativos como `file_picker` no funcionan en tests unitarios