import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/audio_player_provider.dart';
import '../providers/font_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/styled_snackbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> _showSnackBar(String message,
      {SnackbarType type = SnackbarType.info}) async {
    if (!mounted) return;
    StyledSnackBar.show(context, message: message, type: type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: AppTheme.textPrimary,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.settings_rounded,
                      color: AppTheme.accent,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Ajustes',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const _SectionTitle(text: 'Apariencia'),
                    const _FontSelectorTile(),
                    const SizedBox(height: 24),
                    const _SectionTitle(text: 'Música'),
                    _SwitchSettingTile(
                      icon: Icons.volume_up_rounded,
                      title: 'Normalización de volumen',
                      subtitle: 'Mantiene el volumen constante entre canciones',
                      value: context.watch<SettingsProvider>().normalize,
                      onChanged: (v) =>
                          context.read<SettingsProvider>().setNormalize(v),
                    ),
                    _SwitchSettingTile(
                      icon: Icons.compare_arrows_rounded,
                      title: 'Crossfade entre canciones',
                      subtitle: 'Mezcla el final con el inicio de la siguiente',
                      value: context.watch<SettingsProvider>().crossfade,
                      onChanged: (v) =>
                          context.read<SettingsProvider>().setCrossfade(v),
                    ),
                    _SwitchSettingTile(
                      icon: Icons.fast_forward_rounded,
                      title: 'Salto de silencios',
                      subtitle: 'Reproducción sin pausas entre pistas',
                      value: context.watch<SettingsProvider>().gapless,
                      onChanged: (v) =>
                          context.read<SettingsProvider>().setGapless(v),
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(text: 'Biblioteca'),
                    _SettingsTile(
                      icon: Icons.cleaning_services_rounded,
                      title: 'Eliminar archivos faltantes',
                      subtitle: 'Quita canciones cuyos archivos ya no existen',
                      onTap: () async {
                        final removed = context
                            .read<AudioPlayerProvider>()
                            .removeMissingFiles();
                        if (!mounted) return;
                        await _showSnackBar(
                          '$removed ${removed == 1 ? 'canción eliminada' : 'canciones eliminadas'}',
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(text: 'Almacenamiento'),
                    _SettingsTile(
                      icon: Icons.storage_rounded,
                      title: 'Tamaño usado',
                      subtitle: _formatBytes(
                        context.watch<AudioPlayerProvider>().getCacheSize(),
                      ),
                      onTap: null,
                    ),
                    _SettingsTile(
                      icon: Icons.cleaning_services_outlined,
                      title: 'Limpiar caché',
                      subtitle: 'Liberar espacio de artworks',
                      onTap: () async {
                        context.read<AudioPlayerProvider>().clearArtworkCache();
                        if (!mounted) return;
                        await _showSnackBar('Caché limpiado', type: SnackbarType.success);
                      },
                    ),
                    const SizedBox(height: 24),
                    const _SectionTitle(text: 'Acerca de'),
                    _SettingsTile(
                      icon: Icons.share_rounded,
                      title: 'Compartir app',
                      subtitle: 'Invita a tus amigos',
                      onTap: () async {
                        await Share.share(
                          '¡Estoy usando EcoPlayer! Descárgalo gratis.',
                        );
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.star_rate_rounded,
                      title: 'Calificar app',
                      subtitle: 'Déjanos tu opinión en Play Store',
                      onTap: () async {
                        final uri = Uri.parse(
                          'https://play.google.com/store/apps/details?id=com.ecoplayer.app',
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.exit_to_app_rounded,
                      title: 'Salir de la app',
                      subtitle: 'Cerrar EcoPlayer',
                      onTap: () => SystemNavigator.pop(),
                    ),
                    const SizedBox(height: 32),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'EcoPlayer',
                            style: TextStyle(
                              color: AppTheme.textMuted.withValues(alpha: 0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'v1.0.0',
                            style: TextStyle(
                              color: AppTheme.textMuted.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FontSelectorTile extends StatelessWidget {
  const _FontSelectorTile();

  @override
  Widget build(BuildContext context) {
    final fontProvider = context.watch<FontProvider>();
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showFontPicker(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: AppTheme.buttonGradient,
                  ),
                  child: const Icon(
                    Icons.font_download_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fuente',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'EcoPlayer',
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: fontProvider.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFontPicker(BuildContext context) {
    final fontProvider = context.read<FontProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black,
      builder: (_) => _FontPickerSheet(
        currentFamily: fontProvider.fontFamily,
        onSelect: (family) {
          fontProvider.setFontFamily(family);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _FontPickerSheet extends StatelessWidget {
  final String currentFamily;
  final ValueChanged<String> onSelect;

  const _FontPickerSheet({required this.currentFamily, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: const Text(
              'Seleccionar fuente',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...FontProvider.availableFonts.map((font) {
            final isSelected = font == currentFamily;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.accent.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.accent.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSelect(font),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EcoPlayer',
                                style: TextStyle(
                                  color: isSelected
                                      ? AppTheme.accent
                                      : AppTheme.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: font,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                FontProvider.fontDisplayNames[font] ?? font,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppTheme.accent.withValues(alpha: 0.7)
                                      : AppTheme.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppTheme.accent,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.accent,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: enabled
                        ? AppTheme.buttonGradient
                        : LinearGradient(
                            colors: [AppTheme.surfaceLight, AppTheme.surface],
                          ),
                  ),
                  child: Icon(
                    icon,
                    color: enabled ? Colors.white : AppTheme.textMuted,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: enabled
                              ? AppTheme.textPrimary
                              : AppTheme.textMuted,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (enabled)
                  Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwitchSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchSettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: AppTheme.buttonGradient,
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: AppTheme.accent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
