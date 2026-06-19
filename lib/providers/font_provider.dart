import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontProvider extends ChangeNotifier {
  static const String _fontKey = 'selected_font';
  static const String defaultFont = 'Audiowide';

  static const List<String> availableFonts = [
    'Audiowide',
    'Orbitron',
    'BebasNeue',
    'Poppins',
    'Monoton',
  ];

  static const Map<String, String> fontDisplayNames = {
    'Audiowide': 'Audiowide',
    'Orbitron': 'Orbitron',
    'BebasNeue': 'Bebas Neue',
    'Poppins': 'Poppins',
    'Monoton': 'Monoton',
  };

  String _fontFamily = defaultFont;

  FontProvider() {
    _loadFont();
  }

  String get fontFamily => _fontFamily;

  Future<void> _loadFont() async {
    final prefs = await SharedPreferences.getInstance();
    _fontFamily = prefs.getString(_fontKey) ?? defaultFont;
    notifyListeners();
  }

  Future<void> setFontFamily(String family) async {
    if (_fontFamily == family) return;
    _fontFamily = family;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontKey, family);
    notifyListeners();
  }
}
