import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_provider.dart';

class AppTheme {
  static ThemeData build(BloomTheme t) {
    final isDark = ThemeData.estimateBrightnessForColor(t.bgPrimary) == Brightness.dark;

    return (isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true)).copyWith(
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary       : t.accent,
        onPrimary     : t.accentText,
        secondary     : t.accent,
        onSecondary   : t.accentText,
        surface       : t.bgSurface,
        onSurface     : t.textPrimary,
        error         : t.error,
        onError       : Colors.white,
      ),
      scaffoldBackgroundColor: t.bgPrimary,
      textTheme: _buildTextTheme(t),
      appBarTheme: AppBarTheme(
        backgroundColor       : t.bgPrimary,
        elevation             : 0,
        scrolledUnderElevation: 0,
        centerTitle           : false,
        titleTextStyle        : GoogleFonts.nunito(
          fontSize: 20, fontWeight: FontWeight.w900,
          color: t.textPrimary,
        ),
        iconTheme: IconThemeData(color: t.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: t.bgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: t.border, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: t.accent,
          foregroundColor: t.accentText,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: t.accent,
          side: BorderSide(color: t.accent, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.bgSurface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: t.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: t.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: t.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: t.error),
        ),
        hintStyle: GoogleFonts.nunito(color: t.textHint, fontWeight: FontWeight.w500),
        labelStyle: GoogleFonts.nunito(color: t.textSecondary, fontWeight: FontWeight.w600),
      ),
      dividerTheme: DividerThemeData(color: t.border, thickness: 1),
      iconTheme: IconThemeData(color: t.textSecondary),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: t.bgSurface,
        selectedItemColor: t.accent,
        unselectedItemColor: t.textHint,
      ),
    );
  }

  static TextTheme _buildTextTheme(BloomTheme t) => TextTheme(
    displayLarge : GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.w900, color: t.textPrimary),
    displayMedium: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w800, color: t.textPrimary),
    displaySmall : GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w800, color: t.textPrimary),
    headlineLarge: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: t.textPrimary),
    headlineMedium:GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w700, color: t.textPrimary),
    headlineSmall: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w700, color: t.textPrimary),
    titleLarge   : GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: t.textPrimary),
    titleMedium  : GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: t.textPrimary),
    titleSmall   : GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w600, color: t.textPrimary),
    bodyLarge    : GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w500, color: t.textPrimary),
    bodyMedium   : GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w500, color: t.textPrimary),
    bodySmall    : GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w400, color: t.textSecondary),
    labelLarge   : GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: t.textPrimary),
    labelMedium  : GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: t.textSecondary),
    labelSmall   : GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w600, color: t.textSecondary),
  );
}