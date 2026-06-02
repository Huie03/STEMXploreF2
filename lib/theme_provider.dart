import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  bool _isSoundEnabled = true;
  bool get isSoundEnabled => _isSoundEnabled;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void toggleSound(bool value) {
    _isSoundEnabled = value;
    notifyListeners();
  }

  // Light Theme
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: const ColorScheme.light(
      surface: Colors.white,
      onSurface: Colors.black,
    ),

    scaffoldBackgroundColor: const Color(0xFFFFD38F),
  );

  // Dark Theme
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF535252),
      onSurface: Colors.white,
    ),

    scaffoldBackgroundColor: Colors.transparent,
  );
}
