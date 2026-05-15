import 'package:flutter/material.dart';

class AppTheme {
  static const soil = Color(0xFF33251E);
  static const soilLight = Color(0xFF5A3E2C);
  static const sprout = Color(0xFF7DD36F);
  static const terminal = Color(0xFF0B1110);
  static const panel = Color(0xFF15201C);
  static const amber = Color(0xFFFFC857);
  static const cyan = Color(0xFF65D6CE);

  static ThemeData get dark {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: sprout,
        brightness: Brightness.dark,
        primary: sprout,
        secondary: cyan,
        tertiary: amber,
        surface: panel,
      ),
      fontFamily: 'monospace',
      useMaterial3: true,
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF09110E),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
      cardTheme: CardThemeData(
        color: panel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.white.withAlpha(18)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: const Color(0xFF08110D),
          backgroundColor: sprout,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: terminal,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withAlpha(24)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withAlpha(24)),
        ),
      ),
    );
  }
}
