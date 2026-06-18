---
name: debug-android-build
description: Resolver errores de compilación de Android, especialmente conflictos de compileSdk con plugins y problemas de caché de Gradle
---

# Debug Android Build

## Errores comunes y soluciones

### 1. compileSdk 36 requerido por flutter_plugin_android_lifecycle

**Síntoma**: `Dependency ':flutter_plugin_android_lifecycle' requires libraries... to compile against version 36`

**Solución**: Crear init script global de Gradle en `~/.gradle/init.d/force-compile-sdk-36.gradle`:

```groovy
allprojects {
    afterEvaluate { project ->
        if (project.hasProperty('android')) {
            project.android.compileSdkVersion 36
        }
    }
}
```

También ensure que `android/app/build.gradle.kts` tenga:
```kotlin
compileSdk = 36
```

### 2. file_picker API cambió entre versiones

| Versión | API |
|---|---|
| v8.x | `FilePicker.platform.pickFiles(...)` |
| v11.x | `FilePicker.pickFiles(...)` (sin `.platform`) |

Este proyecto usa v8.3.7. Si se actualiza a v11+, cambiar la API.

Además, file_picker v11 requiere compileSdk 36 nativamente (sin init script).

### 3. cannot find symbol: FilePickerPlugin

**Síntoma**: `error: cannot find symbol ... FilePickerPlugin`

**Solución**: Caché de Gradle obsoleto después de cambiar versión de file_picker:

```bash
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get
flutter run -d <device-id>
```

### 4. Kotlin Gradle Plugin (KGP) warning

**Síntoma**: `Your app uses the following plugins that apply Kotlin Gradle Plugin (KGP)`

**Estado**: Warning no bloqueante. Los plugins (audioplayers_android, file_picker) aún usan KGP. En futuras versiones de Flutter esto será un error. Monitorear actualizaciones de estos plugins.

### 5. UrlSource causa FileNotFoundException con archivos locales

**Síntoma**: `java.io.FileNotFoundException: /path%20with%20spaces/file.mp3`

**Causa**: `UrlSource` hace URL encoding del path, rompiendo espacios y caracteres especiales.

**Solución**: SIEMPRE usar `DeviceFileSource(path)` para archivos locales:

```dart
// MAL
await _player.play(UrlSource(audio.path));

// BIEN
await _player.play(DeviceFileSource(audio.path));
```

### 6. Scaffold.of() context error

**Síntoma**: `Scaffold.of() called with a context that does not contain a Scaffold`

**Solución**: Usar `GlobalKey<ScaffoldState>`:

```dart
final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

Scaffold(
  key: _scaffoldKey,
  drawer: const PlaylistDrawer(),
  // ...
)

// Para abrir:
_scaffoldKey.currentState?.openDrawer();
```

## Secuencia de debugging recomendada

1. `flutter clean && flutter pub get`
2. `flutter analyze` (verificar issues Dart)
3. Verificar `android/app/build.gradle.kts` tiene `compileSdk = 36`
4. Verificar init script existe en `~/.gradle/init.d/`
5. `cd android && ./gradlew clean && cd ..`
6. `flutter run -d <device-id>`
7. Si falla, revisar log completo para identificar el error específico