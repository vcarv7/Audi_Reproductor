import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/font_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
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
                    _SectionTitle(text: 'Apariencia'),
                    _FontSelectorTile(),
                    const SizedBox(height: 24),
                    _SectionTitle(text: 'Próximamente'),
                    _SettingsTile(
                      icon: Icons.equalizer_rounded,
                      title: 'Ecualizador',
                      subtitle: 'En desarrollo',
                      enabled: false,
                    ),
                    _SettingsTile(
                      icon: Icons.favorite_outline_rounded,
                      title: 'Favoritos',
                      subtitle: 'En desarrollo',
                      enabled: false,
                    ),
                    _SettingsTile(
                      icon: Icons.palette_outlined,
                      title: 'Tema',
                      subtitle: 'En desarrollo',
                      enabled: false,
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
                        'Fuente del título',
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
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textMuted,
                ),
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

  const _FontPickerSheet({
    required this.currentFamily,
    required this.onSelect,
  });

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
  final bool enabled;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.enabled = true,
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
          onTap: null,
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
                            colors: [
                              AppTheme.surfaceLight,
                              AppTheme.surface,
                            ],
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
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.textMuted,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
