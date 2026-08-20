import 'package:flutter/material.dart';

/// Brand tokens from digititan.co.za (primary / accent / surfaces).
class DigititanColors {
  static const primary = Color(0xFF13418A);
  static const primaryDark = Color(0xFF14325C);
  static const accent = Color(0xFF2C9F58);
  static const teal = Color(0xFF2CC4C9);
  static const background = Color(0xFFF8F9FB);
  static const foreground = Color(0xFF15213B);
  static const muted = Color(0xFFE8EEF4);
  static const surface = Color(0xFFFFFFFF);
  static const danger = Color(0xFFDC2626);
}

class DigititanTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: DigititanColors.primary,
      primary: DigititanColors.primary,
      secondary: DigititanColors.accent,
      tertiary: DigititanColors.teal,
      surface: DigititanColors.surface,
      error: DigititanColors.danger,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: DigititanColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: DigititanColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: DigititanColors.surface,
        indicatorColor: DigititanColors.primary.withOpacity(0.12),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          final selected = states.contains(MaterialState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? DigititanColors.primary : DigititanColors.foreground,
          );
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          final selected = states.contains(MaterialState.selected);
          return IconThemeData(
            color: selected ? DigititanColors.primary : DigititanColors.foreground,
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DigititanColors.primary,
          foregroundColor: Colors.white,
          // Do NOT use Size.fromHeight — that sets width to infinity and
          // crashes buttons inside Row/Wrap/ListTile trailing.
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DigititanColors.primary,
          side: const BorderSide(color: DigititanColors.primary),
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: DigititanColors.primary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: DigititanColors.muted,
        selectedColor: DigititanColors.accent.withOpacity(0.2),
        labelStyle: const TextStyle(color: DigititanColors.foreground),
        side: BorderSide.none,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DigititanColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: DigititanColors.primary, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: DigititanColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: DigititanColors.muted),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: DigititanColors.accent,
        foregroundColor: Colors.white,
      ),
    );
  }
}
