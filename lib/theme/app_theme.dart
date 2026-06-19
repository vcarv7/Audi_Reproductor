import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF000000);
  static const Color accent = Color(0xFFE50914);
  static const Color background = Color(0xFF000000);
  static const Color textPrimary = Color(0xFFFFFFFF);

  static Color get surface => Colors.white.withValues(alpha: 0.05);
  static Color get surfaceLight => Colors.white.withValues(alpha: 0.10);
  static Color get textSecondary => Colors.white.withValues(alpha: 0.70);
  static Color get textMuted => Colors.white.withValues(alpha: 0.40);

  static LinearGradient get backgroundGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF0A0A0A), Color(0xFF000000)],
      );

  static LinearGradient get cardGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
      );

  static LinearGradient get seekBarGradient => const LinearGradient(
        colors: [primary, accent],
      );

  static LinearGradient get buttonGradient => const LinearGradient(
        colors: [Color(0xFF1A1A1A), primary],
      );

  static ThemeData themeWithFont(String fontFamily) {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: Color(0xFF0A0A0A),
      ),
      fontFamily: fontFamily,
      textTheme: TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w700, fontFamily: fontFamily),
        headlineMedium: TextStyle(fontWeight: FontWeight.w600, fontFamily: fontFamily),
        headlineSmall: TextStyle(fontWeight: FontWeight.w600, fontFamily: fontFamily),
        bodyLarge: TextStyle(fontWeight: FontWeight.w400, fontFamily: fontFamily),
        bodyMedium: TextStyle(fontWeight: FontWeight.w400, fontFamily: fontFamily),
        bodySmall: TextStyle(fontWeight: FontWeight.w300, fontFamily: fontFamily),
        labelLarge: TextStyle(fontWeight: FontWeight.w600, fontFamily: fontFamily),
        labelMedium: TextStyle(fontWeight: FontWeight.w500, fontFamily: fontFamily),
        labelSmall: TextStyle(fontWeight: FontWeight.w400, fontFamily: fontFamily),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          fontFamily: fontFamily,
        ),
      ),
    );
  }
}
