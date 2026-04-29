
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/theme_provider.dart';

class AppTheme {

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

  // ===== NAVBAR TOKENS (GLOBAL REUSABLE) =====
  static const double navBarVerticalPadding = 12.0;
  static const double navBrandFontSmall = 19.2;
  static const double navBrandFontLarge = 25.6;
  static const double navBarBorderWidth = 2.0;
  static const double navButtonShadowOffset = 3.0;
  static const double navButtonHorizontalPadding = 12.0;
  static const double navButtonVerticalPadding = 8.0;
  static const double navButtonLetterSpacing = 0.72;
  static const double navButtonFontSize = 12.8;
  static const double navButtonGap = 10.0;
  static const double navMenuIconSize = 26.0;
  static const double navAvatarSize = 48.0;
  static const double navAvatarInnerSize = 40.0;
  static const double navAvatarIconSize = 24.0;

  // Light theme
  static ThemeData lightTheme(ThemeColors colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.backgroundLight,
      textTheme: _textTheme(colors, Brightness.light),
      colorScheme: ColorScheme.light(
        primary: colors.primaryYellow,
        secondary: colors.accentPink,
        tertiary: colors.accentCyan,
        surface: colors.white,
        error: Colors.red,
      ),
    );
  }

  // Dark theme
  static ThemeData darkTheme(ThemeColors colors) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.backgroundDark,
      textTheme: _textTheme(colors, Brightness.dark),
      colorScheme: ColorScheme.dark(
        primary: colors.primaryYellow,
        secondary: colors.accentPink,
        tertiary: colors.accentCyan,
        surface: colors.zinc900,
        error: Colors.red,
      ),
    );
  }

  // Typography
  static TextTheme _textTheme(ThemeColors colors, Brightness brightness) {
    final color = brightness == Brightness.light ? colors.black : colors.white;
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
        color: brightness == Brightness.light
            ? const Color(0xFF666666)
            : const Color(0xFFA1A1AA),
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
    ThemeColors colors,
    Brightness brightness, {
    double offset = shadowMedium,
  }) {
    return BoxShadow(
      // Discover.html: .neo-shadow is black; .dark .neo-shadow is primary yellow
      color:
          brightness == Brightness.light ? colors.black : colors.primaryYellow,
      offset: Offset(offset, offset),
      blurRadius: 0,
      spreadRadius: 0,
    );
  }

  // Neo border decoration
  static BoxDecoration neoBorder(
    ThemeColors colors,
    Brightness brightness, {
    Color? backgroundColor,
    bool shadow = false,
    double shadowOffset = shadowMedium,
  }) {
    // Discover.html: .neo-border is black; .dark .neo-border is primary yellow
    final borderColor =
        brightness == Brightness.light ? colors.black : colors.primaryYellow;
    final bgColor = backgroundColor ??
        (brightness == Brightness.light ? colors.white : colors.zinc900);

    return BoxDecoration(
      color: bgColor,
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: shadow
          ? [neoShadow(colors, brightness, offset: shadowOffset)]
          : [],
    );
  }
}
