import 'package:flutter/material.dart';

class AppTheme {
  static const _pink = Color(0xFFFF6FB5);
  static const _purple = Color(0xFF7C4DFF);
  static const _mint = Color(0xFF7AE7C7);

  static ThemeData get light {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _pink,
        primary: _pink,
        secondary: _mint,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFFFF8FD),
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: _purple,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
