import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF1A1A2E);
  static const Color accentColor = Color(0xFF0F3460);
  static const Color incomeColor = Color(0xFF2ECC71);
  static const Color expenseColor = Color(0xFFE74C3C);
  static const Color cardShadow = Color(0x0D000000);
  static const Color cardShadowDark = Color(0x33000000);

  /// Theme-aware accent (svijetli plavi u dark mode za bolji kontrast)
  static Color accent(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF58A6FF)
          : accentColor;

  /// Theme-aware income color (svjetliji zeleni u dark mode)
  static Color income(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF3FB950)
          : incomeColor;

  /// Theme-aware expense color (svjetliji crveni u dark mode)
  static Color expense(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFF85149)
          : expenseColor;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentColor,
        brightness: Brightness.light,
        primary: accentColor,
      ),
      scaffoldBackgroundColor: Colors.grey.shade50,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shadowColor: cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: primaryColor,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  static ThemeData get darkTheme {
    const surfaceDark = Color(0xFF0D1117);
    const cardDark = Color(0xFF161B22);
    const surfaceVariantDark = Color(0xFF21262D);
    const textPrimary = Color(0xFFF0F6FC);
    const textSecondary = Color(0xFFB1BAC4);
    const accentLight = Color(0xFF58A6FF);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: accentLight,
        secondary: const Color(0xFF3FB950),
        surface: surfaceDark,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        outline: const Color(0xFF30363D),
        error: const Color(0xFFF85149),
        onPrimary: const Color(0xFF0D1117),
      ),
      scaffoldBackgroundColor: surfaceDark,
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 4,
        shadowColor: cardShadowDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        foregroundColor: textPrimary,
      ),
      textTheme: GoogleFonts.dmSansTextTheme(
        ThemeData.dark().textTheme.copyWith(
          headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
          headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary),
          titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
          bodyLarge: TextStyle(fontSize: 16, color: textPrimary, letterSpacing: 0.15),
          bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariantDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF30363D)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accentLight, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardDark,
        selectedItemColor: accentLight,
        unselectedItemColor: textSecondary,
      ),
    );
  }
}
