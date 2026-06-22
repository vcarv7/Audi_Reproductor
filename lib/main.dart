import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/audio_player_provider.dart';
import 'providers/font_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const EcoApp());
}

class EcoApp extends StatelessWidget {
  const EcoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioPlayerProvider()),
        ChangeNotifierProvider(create: (_) => FontProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<FontProvider>(
        builder: (context, fontProvider, _) => MaterialApp(
          title: 'EcoPlayer',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.themeWithFont(fontProvider.fontFamily),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
