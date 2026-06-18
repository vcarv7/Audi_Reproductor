# Audi Reproductor - Guía para Agentes

> Reproductor de audio Flutter personalizado con tema dark
> Stack: Flutter 3.44.1, Dart 3.12.1, Provider, audioplayers

## Comandos esenciales

- `flutter analyze` - Lint (objetivo: 0 issues)
- `flutter devices` - Listar dispositivos conectados
- `flutter run -d 320924222420` - Ejecutar en ZTE Blade A51
- `flutter test` - Ejecutar tests
- `flutter build apk` - Build de release Android
- `flutter clean && flutter pub get` - Limpiar y reinstalar dependencias

## Convenciones del proyecto

### Estado y datos
- **Provider único**: `AudioPlayerProvider` extiende `ChangeNotifier`
- **Consumir estado**: `context.watch<AudioPlayerProvider>()` en build
- **Acciones**: Métodos directos en el provider (`provider.play()`, `provider.pause()`)
- **Modelos**: `AudioFile` con `copyWith()` para inmutabilidad

### Audio
- **Archivos locales**: SIEMPRE `DeviceFileSource(path)`. NUNCA `UrlSource` con paths locales (causa FileNotFoundError en Android por URL encoding)
- **Archivo de audio**: Se obtiene via `FilePicker.platform.pickFiles(type: FileType.audio, allowMultiple: true)`
- **Path**: Usar `p.basenameWithoutExtension()` del paquete `path` para nombres limpios

### Tema y UI
- **Tema dark siempre**: Usar `AppTheme` para todos los colores y gradientes
- **Gradientes**: Usar getters de `AppTheme` (`cardGradient`, `backgroundGradient`, `buttonGradient`, `seekBarGradient`)
- **Colores semánticos**: `textPrimary` (#FFF), `textSecondary` (#B3B3B3), `textMuted` (#666), `primary` (#E50914), `surface` (#1A1A1A)
- **Esquinas redondeadas**: 12-16px para cards, 8px para íconos internos, 3px para seek bars
- **Fuentes**: Roboto del sistema (NO `google_fonts` - no hay internet garantizado)

### Widgets
- **GlassmorphismCard**: Para items de lista y contenedores con efecto glass
- **VinylDisc**: Disco animado que rota al reproducir (usa `AnimationController.repeat()`)
- **AudioVisualizer**: Barras de equalizador animadas
- **GradientSeekBar**: Barra de progreso con gradiente custom
- **MiniPlayer / FullPlayer**: Reproductor colapsado y expandido con transición animada

### Drawer y Scaffold
- **SIEMPRE** usar `GlobalKey<ScaffoldState>` para abrir drawer
- **NUNCA** usar `Scaffold.of(context).openDrawer()` desde el mismo widget que crea el Scaffold (causa error en runtime)

### Enums
- Prefijo con dominio para evitar colisiones: `AudioRepeatMode` (NO `RepeatMode`, colisiona con `Flutter`)

### Deprecaciones
- `.withOpacity(x)` está deprecado → usar `.withValues(alpha: x)`
- `const BoxDecoration(gradient: AppTheme.cardGradient)` → los getters NO son const, quitar `const`

## Estructura

```
lib/
├── main.dart                         # Entry point con ChangeNotifierProvider
├── theme/
│   └── app_theme.dart                # Paleta, gradientes, ThemeData
├── models/
│   └── audio_file.dart               # Modelo de archivo de audio
├── providers/
│   └── audio_player_provider.dart     # Estado global del reproductor
├── screens/
│   └── home_screen.dart              # Pantalla principal
└── widgets/
    ├── vinyl_disc.dart               # Disco animado
    ├── glassmorphism_card.dart       # Cards con efecto glass
    ├── gradient_seek_bar.dart         # Barra de progreso
    ├── audio_visualizer.dart          # Equalizador animado
    ├── player_controls.dart           # Play/pause/skip/shuffle/repeat
    ├── mini_player.dart              # Reproductor colapsado
    ├── full_player.dart              # Reproductor expandido
    └── playlist_drawer.dart          # Drawer lateral con playlist
```

## Trampas conocidas

| Problema | Solución |
|---|---|
| `flutter_plugin_android_lifecycle` requiere compileSdk 36 | Init script global: `~/.gradle/init.d/force-compile-sdk-36.gradle` |
| `file_picker` v8.x usa `FilePicker.platform.pickFiles()`, v11.x usa `FilePicker.pickFiles()` | Esta en v8.3.7, usar API `.platform` |
| `UrlSource` falla con archivos locales (URL encoding) | Usar `DeviceFileSource(path)` |
| `Scaffold.of(context)` desde mismo widget | Usar `GlobalKey<ScaffoldState>` |
| `RepeatMode` colisiona con Flutter | Usar `AudioRepeatMode` |
| `.withOpacity()` deprecado | Usar `.withValues(alpha: x)` |
| Getters de AppTheme no son const | Quitar `const` en BoxDecoration que use gradientes |

## Antes de commit

1. `flutter analyze` debe dar 0 issues
2. Probar en ZTE: selección de archivos + reproducción
3. Verificar que la barra de progreso avanza
4. Verificar que el drawer se abre sin crash

## Dependencias principales

| Paquete | Versión | Uso |
|---|---|---|
| `audioplayers` | ^6.1.0 | Reproducción de audio |
| `file_picker` | ^8.3.0 | Selección de archivos |
| `provider` | ^6.1.0 | Estado de la app |
| `path` | ^1.9.0 | Nombres de archivo limpios |
| `path_provider` | ^2.1.0 | Sistema de archivos |