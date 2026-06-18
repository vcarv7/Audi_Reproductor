import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/audio_player_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const AudiReproductorApp());
}

class AudiReproductorApp extends StatelessWidget {
  const AudiReproductorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AudioPlayerProvider(),
      child: MaterialApp(
        title: 'Audi Player',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const HomeScreen(),
      ),
    );
  }
}