import 'package:flutter/material.dart';

/// Theme Material 3 terpusat (light & dark) beserta typography.
class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1E88E5),
        brightness: brightness,
      ),
    );
    final t = base.textTheme;
    return base.copyWith(
      textTheme: t.copyWith(
        displayLarge: t.displayLarge?.copyWith(
            fontSize: 72, fontWeight: FontWeight.w300, height: 1.0),
        headlineSmall:
            t.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyMedium: t.bodyMedium?.copyWith(fontSize: 15, height: 1.4),
        labelMedium: t.labelMedium?.copyWith(letterSpacing: 0.4),
      ),
      appBarTheme: const AppBarTheme(centerTitle: false),
      cardTheme: CardThemeData(
        elevation: 0,
        color: base.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
