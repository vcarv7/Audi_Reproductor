---
name: add-platform-support
description: Cómo habilitar el reproductor en plataformas adicionales (Windows, iOS, web, macOS, Linux)
---

# Add Platform Support

## Estado actual de plataformas

| Plataforma | Estado | Notas |
|---|---|---|
| Android | ✅ Funcional | Verificado en ZTE Blade A51 (Android 11) |
| Windows | ❌ Bloqueado | Requiere Visual Studio con C++ workload |
| iOS | ❌ Sin probar | Requiere macOS + Xcode |
| Web | ⚠️ Limitado | audioplayers tiene soporte limitado en web |
| macOS | ❌ Sin probar | Requiere macOS + Xcode |
| Linux | ❌ Sin probar | Requiere dependencias de sistema |

## Windows

### Prerrequisitos
1. Instalar Visual Studio Community edition
2. Seleccionar workload "Desktop development with C++"
3. Verificar con `flutter doctor` que Windows aparece como disponible

### Habilitar
```bash
flutter config --enable-windows-desktop
flutter create --platforms=windows .
flutter run -d windows
```

### Consideraciones
- `file_picker` funciona diferente en Windows (diálogo nativo)
- Paths absolutos con backslashes (`C:\Users\...`)
- `audioplayers_windows` viene incluido como dependencia

## iOS

### Prerrequisitos (requiere macOS)
1. Xcode instalado (última versión)
2. CocoaPods instalado (`sudo gem install cocoapods`)
3. Cuenta de Apple Developer para deploy físico

### Setup
```bash
cd ios && pod install && cd ..
flutter run -d <iphone-device-id>
```

### Permisos necesarios en ios/Runner/Info.plist
```xml
<key>NSAppleMusicUsageDescription</key>
<string>Esta app necesita acceso a tu música para reproducir archivos de audio</string>
```

### Consideraciones
- Simulador de iOS no reproduce audio local siempre
- Probar en dispositivo físico
- `file_picker` en iOS usa el documento picker nativo

## Web

### Problemas conocidos
- `audioplayers_web` tiene soporte limitado para streaming local
- Archivos locales deben subirse primero (el navegador no tiene acceso directo al filesystem)
- `DeviceFileSource` no existe en web - usar `UrlSource` con URLs blob
- Las animaciones pueden tener worse performance en web

### Si se habilita web
```bash
flutter run -d chrome
# o
flutter run -d edge
```

### Adaptación necesaria
Se requiere lógica condicional para diferenciar plataformas:
```dart
import 'package:flutter/foundation.dart' show kIsWeb;

if (kIsWeb) {
  // Usar UrlSource con blob URL para archivos subidos
} else {
  // Usar DeviceFileSource para archivos locales
}
```

## macOS

### Prerrequisitos (requiere macOS)
1. Xcode instalado
2. `brew install cocoapods`

### Setup
```bash
cd macos && pod install && cd ..
flutter run -d macos
```

### Permisos en macos/Runner/DebugProfile.entitlements
```xml
<key>com.apple.security.files.user-selected.read-only</key>
<true/>
<key>com.apple.security.audio.playback</key>
<true/>
```

## Linux

### Dependencias de sistema
```bash
# Ubuntu/Debian
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev

# Fedora
sudo dnf install clang cmake ninja-build pkgconfig gtk3-devel lzma-devel
```

### Setup
```bash
flutter run -d linux
```

## Verificación por plataforma

Después de agregar una plataforma:
1. `flutter analyze` - debe dar 0 issues
2. `flutter run -d <platform>` - verificar que la app abre
3. Probar selección de archivos
4. Probar reproducción de audio
5. Probar controles (play, pause, seek, skip)
6. Verificar tema dark se ve correctamente