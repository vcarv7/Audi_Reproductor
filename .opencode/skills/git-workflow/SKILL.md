---
name: git-workflow
description: Convenciones de Git, estrategia de branching, formato de commits y proceso de PR para el proyecto Audi Reproductor
---

# Git Workflow

## Configuración inicial

```bash
cd /path/to/Audi_Reproductor
git init
git add .
git commit -m "feat: initial project setup - Audi Reproductor v1.0.0"
git remote add origin <url-del-repo>
git branch -M main
git push -u origin main
```

## Convención de commits (Conventional Commits)

```
<tipo>(<scope>): <descripción>

[body opcional]

[footer opcional]
```

### Tipos

| Tipo | Uso |
|---|---|
| `feat` | Nueva funcionalidad |
| `fix` | Bug fix |
| `refactor` | Refactorización sin cambio de comportamiento |
| `style` | Cambios de UI/tema sin cambiar lógica |
| `docs` | Documentación |
| `test` | Agregar o modificar tests |
| `chore` | Mantenimiento (deps, config, etc.) |
| `perf` | Mejoras de performance |

### Scopes comunes

| Scope | Archivos típicos |
|---|---|
| `player` | `providers/audio_player_provider.dart` |
| `ui` | `widgets/*`, `screens/*` |
| `theme` | `theme/app_theme.dart` |
| `model` | `models/*` |
| `android` | `android/*` |
| `deps` | `pubspec.yaml` |

### Ejemplos

```bash
feat(player): agregar soporte para repeat one
fix(player): corregir crash al seleccionar archivo con espacios en el nombre
refactor(ui): extraer GlassmorphismCard a widget reutilizable
style(theme): ajustar opacidades del glassmorphism
chore(deps): actualizar file_picker a v8.3.7
fix(android): forzar compileSdk 36 con init script de Gradle
```

## Estrategia de branching

```
main ───────────────────────────────────────────
  │
  ├── feature/audio-equalizer ──────► merge to main
  │
  ├── feature/favorites ────────────► merge to main
  │
  ├── fix/android-url-encoding ─────► merge to main
  │
  └── feature/windows-support ──────► merge to main
```

### Reglas
- `main` siempre debe compilar y pasar `flutter analyze`
- Crear branch desde `main` para cada feature/fix
- Hacer Pull Request para mergear a `main`
- Squash commits al mergear si hay muchos commits pequeños

## .gitignore mínimo

```gitignore
# Flutter/Dart
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
build/
*.lock

# Android
android/.gradle/
android/app/debug/
android/app/profile/
android/app/release/
*.jks
*.keystore

# IDE
.vscode/
.idea/
*.iml

# OS
.DS_Store
Thumbs.db

# Generated
*.g.dart
*.freezed.dart

# Environment
.env
```

## Checklist antes de commit

1. `flutter analyze` = 0 issues
2. App compila en Android (`flutter build apk --debug`)
3. Sin secrets/keys en el código
4. Cambios de `pubspec.yaml` accompanied by `pub.lock` actualizado
5. Changes en `android/` accompanied by verificación de build