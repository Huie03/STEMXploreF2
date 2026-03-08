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
    notifyListeners(); //Tells the whole app to rebuild
  }

  void toggleSound(bool value) {
    _isSoundEnabled = value;
    notifyListeners();
  }

  //Light Theme
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFFD18A),
      primary: const Color(0xFFFFD18A),
    ),
    scaffoldBackgroundColor: const Color(0xFFFFD18A),

    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),
  );

  // Define your Dark Theme
  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFEFA638),
      brightness: Brightness.dark,
      primary: const Color(0xFFEFA638), //
      surface: const Color(0xFF535252), // dark card color
      onSurface: Colors.white, // Default text color on surface
    ),

    scaffoldBackgroundColor: const Color(0xFF121212),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF1E1E1E),
      indicatorColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
      iconTheme: WidgetStateProperty.all(
        const IconThemeData(color: Colors.white),
      ),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}
