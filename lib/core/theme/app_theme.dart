import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_store.dart';

class AppTheme {
  // ─────────────────────────────────────────────────────────────────────────
  // Paleta LIGHT — "Foco Intelectual"
  // Índigo (cognição/foco) + Teal (calma/clareza) + Âmbar (energia criativa)
  // ─────────────────────────────────────────────────────────────────────────
  static const Color lightBackground  = Color(0xFFF5F7FA);
  static const Color lightSurface     = Color(0xFFFFFFFF);
  static const Color lightSurfaceVar  = Color(0xFFEEF2FF); // índigo bem claro
  static const Color lightPrimary     = Color(0xFF4F46E5); // índigo vibrante
  static const Color lightPrimaryVar  = Color(0xFF6366F1); // índigo médio
  static const Color lightSecondary   = Color(0xFF0D9488); // teal
  static const Color lightAccent      = Color(0xFFF59E0B); // âmbar
  static const Color lightTextPrimary = Color(0xFF1E1B4B); // índigo escuro
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightError       = Color(0xFFEF4444);
  static const Color lightBorder      = Color(0xFFE0E7FF);

  // ─────────────────────────────────────────────────────────────────────────
  // Paleta DARK — "Noite de Estudos"
  // ─────────────────────────────────────────────────────────────────────────
  static const Color darkBackground   = Color(0xFF0F0E1A);
  static const Color darkSurface      = Color(0xFF1A1830);
  static const Color darkSurfaceVar   = Color(0xFF231F3E);
  static const Color darkPrimary      = Color(0xFF818CF8); // índigo pastel
  static const Color darkPrimaryVar   = Color(0xFF6366F1);
  static const Color darkSecondary    = Color(0xFF2DD4BF); // teal brilhante
  static const Color darkAccent       = Color(0xFFFBBF24); // âmbar
  static const Color darkTextPrimary  = Color(0xFFEDE9FE);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkError        = Color(0xFFF87171);
  static const Color darkBorder       = Color(0xFF312E81);

  // ─────────────────────────────────────────────────────────────────────────
  // Paleta ALTO CONTRASTE — acessibilidade máxima (WCAG AAA)
  // ─────────────────────────────────────────────────────────────────────────
  static const Color hcBackground  = Color(0xFF000000);
  static const Color hcSurface     = Color(0xFF000000);
  static const Color hcPrimary     = Color(0xFFFFFF00);
  static const Color hcSecondary   = Color(0xFF00FFFF);
  static const Color hcTextPrimary = Color(0xFFFFFFFF);
  static const Color hcTextSecondary = Color(0xFFCCCCCC);
  static const Color hcError       = Color(0xFFFF4444);
  static const Color hcBorder      = Color(0xFFFFFFFF);

  static ThemeData getTheme(AppThemeMode mode) {
    // ── Seleção dos tokens por modo ──────────────────────────────────────
    Color background, surface, surfaceVar, primary, primaryVar,
        secondary, accent, textPrimary, textSecondary, error, border;
    Brightness brightness;

    switch (mode) {
      case AppThemeMode.dark:
        background    = darkBackground;
        surface       = darkSurface;
        surfaceVar    = darkSurfaceVar;
        primary       = darkPrimary;
        primaryVar    = darkPrimaryVar;
        secondary     = darkSecondary;
        accent        = darkAccent;
        textPrimary   = darkTextPrimary;
        textSecondary = darkTextSecondary;
        error         = darkError;
        border        = darkBorder;
        brightness    = Brightness.dark;
        break;
      case AppThemeMode.highContrast:
        background    = hcBackground;
        surface       = hcSurface;
        surfaceVar    = hcSurface;
        primary       = hcPrimary;
        primaryVar    = hcPrimary;
        secondary     = hcSecondary;
        accent        = hcPrimary;
        textPrimary   = hcTextPrimary;
        textSecondary = hcTextSecondary;
        error         = hcError;
        border        = hcBorder;
        brightness    = Brightness.dark;
        break;
      case AppThemeMode.light:
      default:
        background    = lightBackground;
        surface       = lightSurface;
        surfaceVar    = lightSurfaceVar;
        primary       = lightPrimary;
        primaryVar    = lightPrimaryVar;
        secondary     = lightSecondary;
        accent        = lightAccent;
        textPrimary   = lightTextPrimary;
        textSecondary = lightTextSecondary;
        error         = lightError;
        border        = lightBorder;
        brightness    = Brightness.light;
        break;
    }

    final isHC = mode == AppThemeMode.highContrast;

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: background,
      primaryColor: primary,

      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: isHC ? Colors.black : Colors.white,
        primaryContainer: surfaceVar,
        onPrimaryContainer: textPrimary,
        secondary: secondary,
        onSecondary: isHC ? Colors.black : Colors.white,
        secondaryContainer: secondary.withOpacity(0.15),
        onSecondaryContainer: textPrimary,
        tertiary: accent,
        onTertiary: isHC ? Colors.black : Colors.white,
        surface: surface,
        onSurface: textPrimary,
        surfaceContainerHighest: surfaceVar,
        error: error,
        onError: Colors.white,
        outline: border,
        outlineVariant: border.withOpacity(0.5),
      ),

      // ── Tipografia ─────────────────────────────────────────────────────
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge:  GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w800, letterSpacing: -1.0),
        displayMedium: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        displaySmall:  GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w700),
        headlineLarge: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w700),
        headlineMedium:GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge:    GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 18),
        titleMedium:   GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 15),
        titleSmall:    GoogleFonts.outfit(color: textSecondary, fontWeight: FontWeight.w500, fontSize: 13),
        bodyLarge:     GoogleFonts.inter(color: textPrimary, fontSize: 15, height: 1.5),
        bodyMedium:    GoogleFonts.inter(color: textSecondary, fontSize: 13, height: 1.5),
        bodySmall:     GoogleFonts.inter(color: textSecondary, fontSize: 12, height: 1.5),
        labelLarge:    GoogleFonts.inter(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
        labelMedium:   GoogleFonts.inter(color: textSecondary, fontWeight: FontWeight.w500, fontSize: 12),
      ),

      // ── AppBar ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ── Card ───────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: surface,
        elevation: isHC ? 0 : 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          side: isHC
              ? const BorderSide(color: Colors.white, width: 2)
              : BorderSide(color: border, width: 1.2),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      ),

      // ── ElevatedButton ─────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isHC ? Colors.black : Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      // ── TextButton ─────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),

      // ── OutlinedButton ─────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),

      // ── BottomSheet ────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      // ── Checkbox ───────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide(color: border, width: 1.5),
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(
          isHC ? Colors.black : Colors.white,
        ),
      ),

      // ── Divider ────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: border.withOpacity(0.6),
        thickness: 1,
        space: 1,
      ),

      // ── FloatingActionButton ───────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: isHC ? Colors.black : Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),

      // ── Chip ───────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVar,
        selectedColor: primary.withOpacity(0.15),
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
        side: BorderSide(color: border, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ── Input / TextField ──────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVar,
        hintStyle: GoogleFonts.inter(color: textSecondary, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),

      // ── ProgressIndicator ──────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: primary.withOpacity(0.12),
      ),

      // ── TabBar ─────────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textSecondary,
        indicatorColor: primary,
        labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w400, fontSize: 13),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
      ),
    );
  }
}
