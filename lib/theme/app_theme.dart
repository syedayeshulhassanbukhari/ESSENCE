import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ===== NEO-BRUTALISM COLOR PALETTE =====
  // Matches tailwind primary "#facc15" from discover.html
  static const Color primaryYellow = Color(0xFFFACC15);
  static const Color accentPink = Color(0xFFFF00FF);
  static const Color accentCyan = Color(0xFF00F0FF);
  static const Color accentGreen = Color(0xFF00FF66);
  static const Color backgroundLight = Color(0xFFFFFFFF);
  // Matches "background-dark" #0a0a0a from discover.html
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc900 = Color(0xFF18181B);
  static const Color gray400 = Color(0xFFA3A3A3);

  // ===== SPACING SCALE =====
  static const double spacing2 = 8.0;
  static const double spacing4 = 16.0;
  static const double spacing6 = 24.0;
  static const double spacing8 = 32.0;
  static const double spacing12 = 48.0;

  // ===== BORDER SETTINGS =====
  static const double borderWidth = 4.0;
  static const double borderRadiusZero = 0.0;

  // ===== SHADOW OFFSETS =====
  static const double shadowLarge = 6.0;
  static const double shadowMedium = 4.0;
  static const double shadowSmall = 3.0;

  // Light theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      textTheme: _textTheme(Brightness.light),
      colorScheme: ColorScheme.light(
        primary: primaryYellow,
        secondary: accentPink,
        tertiary: accentCyan,
        surface: white,
        error: Colors.red,
      ),
    );
  }

  // Dark theme
  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      textTheme: _textTheme(Brightness.dark),
      colorScheme: ColorScheme.dark(
        primary: primaryYellow,
        secondary: accentPink,
        tertiary: accentCyan,
        surface: zinc900,
        error: Colors.red,
      ),
    );
  }

  // Typography
  static TextTheme _textTheme(Brightness brightness) {
    final color = brightness == Brightness.light ? black : white;
    return TextTheme(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 72,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: -1.5,
      ),
      displayMedium: GoogleFonts.spaceGrotesk(
        fontSize: 56,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      displaySmall: GoogleFonts.spaceGrotesk(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      headlineLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      headlineMedium: GoogleFonts.spaceGrotesk(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      headlineSmall: GoogleFonts.spaceGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleLarge: GoogleFonts.spaceGrotesk(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      titleMedium: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      bodyLarge: GoogleFonts.spaceGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      bodyMedium: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodySmall: GoogleFonts.spaceGrotesk(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        // Use a zinc-400 style gray in dark mode for subtitles
        color: brightness == Brightness.light ? Color(0xFF666666) : Color(0xFFA1A1AA),
      ),
      labelLarge: GoogleFonts.spaceGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    );
  }

  // Neo shadow helper
  static BoxShadow neoShadow(
    Brightness brightness, {
    double offset = shadowMedium,
  }) {
    return BoxShadow(
      // Discover.html: .neo-shadow is black; .dark .neo-shadow is primary yellow
      color: brightness == Brightness.light ? black : primaryYellow,
      offset: Offset(offset, offset),
      blurRadius: 0,
      spreadRadius: 0,
    );
  }

  // Neo border decoration
  static BoxDecoration neoBorder(
    Brightness brightness, {
    Color? backgroundColor,
    bool shadow = false,
    double shadowOffset = shadowMedium,
  }) {
    // Discover.html: .neo-border is black; .dark .neo-border is primary yellow
    final borderColor =
      brightness == Brightness.light ? black : primaryYellow;
    final bgColor = backgroundColor ??
        (brightness == Brightness.light ? white : zinc900);

    return BoxDecoration(
      color: bgColor,
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: shadow ? [neoShadow(brightness, offset: shadowOffset)] : [],
    );
  }
}
