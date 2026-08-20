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
  static const softBlue = Color(0xFFE8F1FA);
  static const softGreen = Color(0xFFEAF7F0);
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

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: DigititanColors.background,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: DigititanColors.foreground,
        displayColor: DigititanColors.foreground,
      ).copyWith(
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          color: DigititanColors.primaryDark,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: DigititanColors.primaryDark,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: DigititanColors.foreground,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          color: DigititanColors.foreground.withOpacity(0.72),
          height: 1.35,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: DigititanColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: DigititanColors.teal,
        labelStyle: TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: DigititanColors.surface,
        elevation: 0,
        height: 68,
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
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DigititanColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 44),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DigititanColors.primary,
          side: const BorderSide(color: DigititanColors.primary),
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DigititanColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DigititanColors.muted),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DigititanColors.primary, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        color: DigititanColors.surface,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: DigititanColors.muted),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: DigititanColors.primary,
      ),
      dividerTheme: const DividerThemeData(
        color: DigititanColors.muted,
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: DigititanColors.accent,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: DigititanColors.primaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
