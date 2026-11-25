import 'package:material_ui/material_ui.dart';

class GreenleafColors {
  static const Color forestGreen = Color(0xFF1E4D2B);
  static const Color leafGreen = Color(0xFF2F7D4A);
  static const Color freshGreen = Color(0xFF4CAF50);
  static const Color mintSurface = Color(0xFFF4FAF5);
  static const Color mintTint = Color(0xFFE4F4E7);
  static const Color borderGreen = Color(0xFFD5E9D9);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color softYellow = Color(0xFFFFF6CC);
  static const Color warmYellow = Color(0xFFF7DB72);
  static const Color deepHoney = Color(0xFF7D5C00);
  static const Color mutedText = Color(0xFF5A6F60);
  static const Color frameBackdrop = Color(0xFFE8ECEF);
}

class GreenleafTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: GreenleafColors.leafGreen,
      primary: GreenleafColors.leafGreen,
      onPrimary: GreenleafColors.pureWhite,
      secondary: GreenleafColors.warmYellow,
      onSecondary: GreenleafColors.forestGreen,
      surface: GreenleafColors.pureWhite,
      onSurface: GreenleafColors.forestGreen,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: GreenleafColors.mintSurface,
      appBarTheme: const AppBarTheme(
        backgroundColor: GreenleafColors.mintSurface,
        foregroundColor: GreenleafColors.forestGreen,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: GreenleafColors.forestGreen,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: GreenleafColors.pureWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: GreenleafColors.borderGreen, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: GreenleafColors.leafGreen,
          foregroundColor: GreenleafColors.pureWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: GreenleafColors.pureWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: GreenleafColors.borderGreen),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: GreenleafColors.borderGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: GreenleafColors.leafGreen, width: 1.8),
        ),
        hintStyle: const TextStyle(color: GreenleafColors.mutedText),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: GreenleafColors.forestGreen,
        contentTextStyle: const TextStyle(
          color: GreenleafColors.pureWhite,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
