import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens from design/stitch HTML exports (Digital Sanctuary, light mode).
class AppTheme {
  AppTheme._();

  // ── Surface hierarchy (warm orange-tinted, no blue) ───────────────────────
  static const Color surface = Color(0xFFFFF8F6);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFFFF3EF);
  static const Color surfaceContainer = Color(0xFFFFEBE3);
  static const Color surfaceContainerHigh = Color(0xFFFFE2D5);
  static const Color surfaceContainerHighest = Color(0xFFFFD8C8);

  // ── Brand colours ─────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFB02F00);   // dark burnt orange
  static const Color accent = Color(0xFFFF5924);    // action orange
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryFixed = Color(0xFFFFDBD1);

  // ── Text / ink ────────────────────────────────────────────────────────────
  static const Color onSurface = Color(0xFF121C2B);
  static const Color textMuted = Color(0xFF5C5F61);
  static const Color textSubtle = Color(0xFF5B4039);
  static const Color outlineVariant = Color(0xFFE4BEB4);

  // ── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        surface: surface,
        onSurface: onSurface,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: accent,
        onPrimaryContainer: onPrimary,
        secondary: Color(0xFF6B5751),
        onSecondary: onPrimary,
        secondaryContainer: surfaceContainerHighest,
        onSecondaryContainer: textSubtle,
        outline: Color(0xFF8F7067),
        outlineVariant: outlineVariant,
      ),
      scaffoldBackgroundColor: surface,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: surfaceContainerHigh,
        thumbColor: accent,
        overlayColor: accent.withValues(alpha: 0.1),
        trackHeight: 4,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent.withValues(alpha: 0.3), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  // ── Typography helpers ─────────────────────────────────────────────────────
  static TextStyle notoSerif({
    double fontSize = 16,
    FontWeight weight = FontWeight.w400,
    bool italic = false,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.notoSerif(
        fontSize: fontSize,
        fontWeight: weight,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        color: color ?? onSurface,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle inter({
    double fontSize = 16,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: weight,
        color: color ?? onSurface,
        letterSpacing: letterSpacing,
        height: height,
      );

  // ── Shared decorations ────────────────────────────────────────────────────
  static BoxDecoration cardDecoration({Color? color}) => BoxDecoration(
        color: color ?? surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F121C2B),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      );
}
