import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_store.dart';

class AppTheme {
  // Paleta de Cores Light (Anti-Burnout)
  static const Color lightBackground = Color(0xFFFAFAF8);
  static const Color lightSurface = Colors.white;
  static const Color lightPrimary = Color(0xFF8DA399);
  static const Color lightSecondary = Color(0xFFD9C5B2);
  static const Color lightTextPrimary = Color(0xFF1A1E24);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightAlertSoft = Color(0xFFC68776);

  // Paleta de Cores Dark
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkPrimary = Color(0xFF9CAEA5);
  static const Color darkSecondary = Color(0xFFC4B4A4);
  static const Color darkTextPrimary = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFA0A0A0);
  static const Color darkAlertSoft = Color(0xFFD19A8D);

  // Paleta de Cores Alto Contraste
  static const Color hcBackground = Colors.black;
  static const Color hcSurface = Colors.black;
  static const Color hcPrimary = Color(0xFF00FF00); // Verde vibrante
  static const Color hcSecondary = Colors.white;
  static const Color hcTextPrimary = Colors.white;
  static const Color hcTextSecondary = Colors.white70;
  static const Color hcAlertSoft = Colors.redAccent;

  static ThemeData getTheme(AppThemeMode mode) {
    Color background;
    Color surface;
    Color primary;
    Color secondary;
    Color textPrimary;
    Color textSecondary;
    Color alertSoft;
    Brightness brightness;

    switch (mode) {
      case AppThemeMode.dark:
        background = darkBackground;
        surface = darkSurface;
        primary = darkPrimary;
        secondary = darkSecondary;
        textPrimary = darkTextPrimary;
        textSecondary = darkTextSecondary;
        alertSoft = darkAlertSoft;
        brightness = Brightness.dark;
        break;
      case AppThemeMode.highContrast:
        background = hcBackground;
        surface = hcSurface;
        primary = hcPrimary;
        secondary = hcSecondary;
        textPrimary = hcTextPrimary;
        textSecondary = hcTextSecondary;
        alertSoft = hcAlertSoft;
        brightness = Brightness.dark;
        break;
      case AppThemeMode.light:
      default:
        background = lightBackground;
        surface = lightSurface;
        primary = lightPrimary;
        secondary = lightSecondary;
        textPrimary = lightTextPrimary;
        textSecondary = lightTextSecondary;
        alertSoft = lightAlertSoft;
        brightness = Brightness.light;
        break;
    }

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: mode == AppThemeMode.highContrast ? Colors.black : Colors.white,
        secondary: secondary,
        onSecondary: textPrimary,
        surface: surface,
        onSurface: textPrimary,
        error: alertSoft,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.inter(color: textPrimary),
        bodyMedium: GoogleFonts.inter(color: textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: mode == AppThemeMode.highContrast ? 0 : 4,
        shadowColor: mode == AppThemeMode.highContrast ? Colors.transparent : const Color(0x0C000000),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          side: mode == AppThemeMode.highContrast 
              ? const BorderSide(color: Colors.white, width: 2) 
              : BorderSide.none,
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: mode == AppThemeMode.highContrast ? Colors.black : Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: alertSoft,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primary;
          }
          return Colors.transparent;
        }),
        checkColor: MaterialStateProperty.all(
          mode == AppThemeMode.highContrast ? Colors.black : Colors.white
        ),
      ),
    );
  }
}
