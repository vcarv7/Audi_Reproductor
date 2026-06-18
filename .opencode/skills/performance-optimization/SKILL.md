---
name: performance-optimization
description: Optimizaciones de rendimiento para el reproductor de audio en Flutter, especialmente en dispositivos de gama baja como el ZTE Blade A51
---

# Performance Optimization

## Contexto del dispositivo objetivo

**ZTE Blade A51** (dispositivo primario de prueba):
- Android 11 (API 30)
- RAM limitada
- GPU MediaTek
- Resolución 720x1560

Las optimizaciones están orientadas a este perfil de dispositivo.

## Problemas conocidos y soluciones

### 1. Imágenes y redeeming

**Problema**: `Skipped N frames! The application may be doing too much work on its main thread.`

**Soluciones**:
- Evitar `setState()` innecesario en widgets que no cambian
- Usar `const` en constructores de widgets stateless
- Dividir widgets grandes en sub-widgets más pequeños
- Usar `RepaintBoundary` alrededor de animaciones complejas

```dart
RepaintBoundary(
  child: VinylDisc(isPlaying: provider.isPlaying),
)
```

### 2. Animaciones

**Problema**: Animaciones que consumen CPU incluso cuando no son visibles.

**Soluciones**:
- Siempre detener `AnimationController` cuando el widget no es visible
- Usar `SingleTickerProviderStateMixin` en vez de `TickerProviderStateMixin` cuando solo hay 1 controller
- Considerar `AnimatedBuilder` en vez de `setState` para animaciones

```dart
// BIEN - solo anima lo necesario
AnimatedBuilder(
  animation: _controller,
  builder: (context, child) {
    return Transform.rotate(angle: _controller.value * 2 * pi, child: child);
  },
  child: ExpensiveWidget(), // No se rebuild
)

// MAL - rebuild todo el widget tree
setState(() { _angle = _controller.value * 2 * pi; });
```

### 3. ListView performance

**Problema**: Lista de canciones hace rebuild de todos los items.

**Soluciones**:
- `ListView.builder` (ya implementado) - solo construye items visibles
- Considerar `const` en sub-widgets de cada item
- Evitar `context.watch<AudioPlayerProvider>()` dentro de `itemBuilder` para no rebuild toda la lista

```dart
// MEJOR - escuchar solo lo que cambia
Selector<AudioPlayerProvider, String?>(
  selector: (_, provider) => provider.currentAudio?.id,
  builder: (context, currentId, child) {
    return ListView.builder(...);
  },
)
```

### 4. Google Fonts (ya resuelto)

**Problema original**: `google_fonts` intenta descargar fuentes por HTTP causando errores y lag.

**Solución aplicada**: Removido `google_fonts`, usando Roboto del sistema (siempre disponible en Android).

### 5. Audio player resources

**Problema**: MediaPlayer de Android no se libera correctamente.

**Soluciones**:
- Llamar `_player.dispose()` en `dispose()` del provider (ya implementado)
- Cancelar todos los `StreamSubscription` en dispose (ya implementado)
- Considerar `stop()` antes de `dispose()` para liberar recursos nativos

```dart
@override
void dispose() {
  _positionSub?.cancel();
  _durationSub?.cancel();
  _playerStateSub?.cancel();
  _completeSub?.cancel();
  _player.dispose();
  super.dispose();
}
```

### 6. Memory leaks de imágenes

**Problema**: Caching de imágenes por `file_picker` acumula archivos temporales.

**Solución potencial**:
```dart
// Limpiar caché de file_picker al salir
@override
void dispose() {
  FilePicker.platform.clearTemporaryFiles();
  super.dispose();
}
```

### 7. Seek bar throttle

**Problema**: El seek dispara demasiados `seek()` al arrastrar.

**Solución** (ya implementada con `_isSeeking` flag):
- Marcar `_isSeeking = true` al iniciar drag
- Ignorar updates de posición durante drag
- Llamar `seek()` solo en `onHorizontalDragUpdate`
- Marcar `_isSeeking = false` al terminar

### 8. Gradient rendering

**Problema**: Gradientes complejos pueden ser costosos en GPU baja.

**Soluciones**:
- Reutilizar instancias de `LinearGradient` cuando sea posible (ya son getters en AppTheme)
- Evitar gradientes animados sin necesidad
- Preferir colores sólidos para fondos estáticos

## Profiling

```bash
# Ejecutar en modo profile para medir performance real
flutter run --profile -d 320924222420

# Con DevTools
flutter pub global activate devtools
flutter pub global run devtools
# Abrir URL que muestraDevTools y conectar al device
```

### Métricas a monitorear
- **FPS**: Objetivo > 50fps en el ZTE
- **GPU usage**: Los gradientes y blur (glassmorphism) son costosos
- **Memory**: Verificar que no crezca indefinidamente al cambiar canciones
- **Widget rebuild count**: Usar Flutter DevTools Performance overlay