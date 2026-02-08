import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Required for jsonEncode and jsonDecode

class FavoriteProvider with ChangeNotifier {
  List<Map<String, String>> _favorites = [];

  List<Map<String, String>> get bookmarks => _favorites;

  FavoriteProvider() {
    _loadFavorites(); // Load saved data as soon as the app starts
  }

  // Save to local storage
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert the List of Maps into a JSON string
    String encodedData = jsonEncode(_favorites);
    await prefs.setString('user_favorites', encodedData);
  }

  // Load from local storage
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('user_favorites');

    if (savedData != null) {
      // Decode the JSON string back into a List of Maps
      List<dynamic> decodedData = jsonDecode(savedData);
      _favorites = decodedData
          .map((item) => Map<String, String>.from(item))
          .toList();
      notifyListeners();
    }
  }

  void toggleFavorite(Map<String, String> material) {
    final index = _favorites.indexWhere(
      (m) =>
          m['title'] == material['title'] &&
          m['chapter'] == material['chapter'],
    );

    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(material);
    }

    _saveToPrefs(); // Save changes to the phone's memory
    notifyListeners();
  }

  bool isFavorited(String title, String chapter) {
    return _favorites.any(
      (m) => m['title'] == title && m['chapter'] == chapter,
    );
  }
}
