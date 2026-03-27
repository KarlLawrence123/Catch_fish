import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color lightPrimaryColor = Color(0xFF0277BD);
  static const Color lightSecondaryColor = Color(0xFF00ACC1);
  static const Color lightAccentColor = Color(0xFF26A69A);
  static const Color lightBackgroundColor = Color(0xFFE1F5FE);

  static const Color darkPrimaryColor = Color(0xFF0D47A1);
  static const Color darkSecondaryColor = Color(0xFF01579B);
  static const Color darkBackgroundColor = Color(0xFF0A1929);
  static const Color darkCardColor = Color(0xFF283593);
  static const Color darkSurfaceColor = Color(0xFF1A237E);

  // Status Colors
  static const Color healthyColor = Color(0xFF4CAF50);
  static const Color suspiciousColor = Color(0xFFFF9800);
  static const Color diseaseColor = Color(0xFFE53935);

  static const Color lightWaterShadow = Color(0x290277BD);
  static const Color darkWaterShadow = Color(0x4D0D47A1);

  // Aliases - Fixed the "Member not found" errors
  static Color get primaryColor => lightPrimaryColor;
  static Color get secondaryColor => lightSecondaryColor;
  static Color get accentColor => lightAccentColor;
  static Color get backgroundColor => lightBackgroundColor;
  static Color get dangerColor => diseaseColor;
  static Color get warningColor => suspiciousColor;

  static BoxDecoration get aquaticBackground => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0F9FF), Color(0xFFE1F5FE)],
        ),
      );

  static Color getHealthStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return healthyColor;
      case 'suspicious':
        return suspiciousColor;
      default:
        return dangerColor;
    }
  }

  static String getHealthStatusEmoji(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return '🟢';
      case 'suspicious':
        return '🟡';
      default:
        return '🔴';
    }
  }

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData(brightness: Brightness.light).textTheme,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightPrimaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: lightBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: lightPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white, width: 0.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: lightPrimaryColor,
        unselectedItemColor: Colors.grey,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Dark Theme - Fixed the "Member not found: darkTheme" error
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkPrimaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurfaceColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: darkCardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white, width: 0.1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkSurfaceColor,
        selectedItemColor: lightPrimaryColor,
        unselectedItemColor: Colors.grey,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
