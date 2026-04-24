import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:stemxploref2/stem_highlights/highlight.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;
  Locale _locale = const Locale('en');
  Highlight? _selectedHighlight;

  int get currentIndex => _currentIndex;
  Locale get locale => _locale;
  Highlight? get selectedHighlight => _selectedHighlight;

  NavigationProvider() {
    _loadLocale();
  }

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void openHighlight(Highlight highlight) {
    _selectedHighlight = highlight;
    _currentIndex = 10;
    notifyListeners();
  }

  void setLocale(Locale newLocale) async {
    _locale = newLocale;

    FlutterLocalization.instance.translate(newLocale.languageCode);

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', newLocale.languageCode);
  }

  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String code = prefs.getString('language_code') ?? 'en';
    _locale = Locale(code);
    FlutterLocalization.instance.translate(code);
    notifyListeners();
  }
}
