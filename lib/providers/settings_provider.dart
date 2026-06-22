import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _keyNormalize = 'setting_normalize';
  static const _keyCrossfade = 'setting_crossfade';
  static const _keyGapless = 'setting_gapless';

  bool _normalize = false;
  bool _crossfade = false;
  bool _gapless = false;
  bool _loaded = false;

  bool get normalize => _normalize;
  bool get crossfade => _crossfade;
  bool get gapless => _gapless;
  bool get loaded => _loaded;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _normalize = prefs.getBool(_keyNormalize) ?? false;
    _crossfade = prefs.getBool(_keyCrossfade) ?? false;
    _gapless = prefs.getBool(_keyGapless) ?? false;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setNormalize(bool value) async {
    _normalize = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNormalize, value);
    notifyListeners();
  }

  Future<void> setCrossfade(bool value) async {
    _crossfade = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCrossfade, value);
    notifyListeners();
  }

  Future<void> setGapless(bool value) async {
    _gapless = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGapless, value);
    notifyListeners();
  }
}
