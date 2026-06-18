---
name: create-themed-widget
description: Convenciones para crear nuevos widgets que respeten el tema dark y el sistema de diseño de Audi Reproductor
---

# Create Themed Widget

## Principios de diseño

- **Dark mode siempre** - el tema es fijo, no hay toggle
- **Esquinas redondeadas**: 12-16px para cards, 8px para íconos internos, 3px para seek bars
- **Sombras con color primario**: Usar `AppTheme.primary.withValues(alpha: 0.3)` en box shadows
- **Gradientes**: Usar SIEMPRE los getters de `AppTheme`, nunca crear LinearGradient inline

## Gradientes disponibles

```dart
AppTheme.backgroundGradient  // Fondo principal (top: #1A1A2E → bottom: #0A0A0A)
AppTheme.cardGradient         // Cards (topLeft: #2A2A3E → bottomRight: #1A1A2E)
AppTheme.buttonGradient       // Botones (#E50914 → #B20710)
AppTheme.seekBarGradient      // Seek bars (#E50914 → #FF6B35)
```

## Colores semánticos

| Color | Uso |
|---|---|
| `AppTheme.textPrimary` (#FFFFFF) | Títulos y texto importante |
| `AppTheme.textSecondary` (#B3B3B3) | Subtítulos y metadata |
| `AppTheme.textMuted` (#666666) | Texto terciario y timestamps |
| `AppTheme.primary` (#E50914) | Acciones, elementos activos, acentos |
| `AppTheme.primaryDark` (#B20710) | Gradientes de botones |
| `AppTheme.accent` (#FF6B35) | Gradientes de seek bar |
| `AppTheme.background` (#0A0A0A) | Fondo del scaffold |
| `AppTheme.surface` (#1A1A1A) | Fondo de cards |
| `AppTheme.surfaceLight` (#2A2A2A) | Fondos de seek bar inactiva |

## Template: Widget con efecto glass

```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MyGlassWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const MyGlassWidget({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.cardGradient,  // NUNCA const
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),  // NUNCA .withOpacity()
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
```

## Template: Widget animado con AnimationController

```dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MyAnimatedWidget extends StatefulWidget {
  final bool isActive;

  const MyAnimatedWidget({super.key, required this.isActive});

  @override
  State<MyAnimatedWidget> createState() => _MyAnimatedWidgetState();
}

class _MyAnimatedWidgetState extends State<MyAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(MyAnimatedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive) {
      _controller.repeat(); // o .forward() para una sola vez
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159265,
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.buttonGradient,
        ),
      ),
    );
  }
}
```

## Template: Widget que consume el provider

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../theme/app_theme.dart';

class MyConsumerWidget extends StatelessWidget {
  const MyConsumerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioPlayerProvider>();

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        provider.isPlaying ? 'Reproduciendo' : 'Pausado',
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

## Errores comunes a evitar

| Error | Solución |
|---|---|
| `const BoxDecoration(gradient: AppTheme.cardGradient)` | Los getters no son const. Quitar `const` |
| `Scaffold.of(context).openDrawer()` | Usar `GlobalKey<ScaffoldState>` |
| `.withOpacity(0.3)` | Usar `.withValues(alpha: 0.3)` |
| `RepeatMode.off` | Usar `AudioRepeatMode.off` |
| `UrlSource(localPath)` | Usar `DeviceFileSource(localPath)` |