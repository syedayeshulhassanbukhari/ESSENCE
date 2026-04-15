import 'package:flutter/material.dart';

import '../models/discover_color_token.dart';
import '../providers/theme_provider.dart';

class DiscoverPalette {
  const DiscoverPalette._();

  static const Color primary = Color(0xFFFAC638);
  static const Color bgLight = Color(0xFFF8F8F5);
  static const Color bgDark = Color(0xFF231E0F);
  static const Color neoLime = Color(0xFFBEF264);
  static const Color neoOrange = Color(0xFFFB923C);
  static const Color neoPink = Color(0xFFF472B6);
  static const Color neoBlue = Color(0xFF60A5FA);

  static Color colorForToken(ThemeColors colors, DiscoverColorToken token) {
    switch (token) {
      case DiscoverColorToken.lime:
        return neoLime;
      case DiscoverColorToken.orange:
        return neoOrange;
      case DiscoverColorToken.pink:
        return neoPink;
      case DiscoverColorToken.blue:
        return neoBlue;
      case DiscoverColorToken.black:
        return colors.black;
      case DiscoverColorToken.white:
        return colors.white;
    }
  }
}