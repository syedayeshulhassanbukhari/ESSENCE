import 'package:flutter/material.dart';

class ThemeColors {
  const ThemeColors();

  Color get primaryYellow => const Color(0xFFFACC15);
  Color get accentPink => const Color(0xFFFF00FF);
  Color get accentCyan => const Color(0xFF00F0FF);
  Color get accentGreen => const Color(0xFF00FF66);
  Color get backgroundLight => const Color(0xFFFFFFFF);
  Color get backgroundDark => const Color(0xFF0A0A0A);
  Color get black => const Color(0xFF000000);
  Color get white => const Color(0xFFFFFFFF);
  Color get zinc800 => const Color(0xFF27272A);
  Color get zinc900 => const Color(0xFF18181B);
  Color get gray400 => const Color(0xFFA3A3A3);
}

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  final ThemeColors colors = const ThemeColors();

  bool get isDarkMode => _isDarkMode;
  Brightness get brightness =>
      _isDarkMode ? Brightness.dark : Brightness.light;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
