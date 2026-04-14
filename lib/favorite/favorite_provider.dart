import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../ipaddress.dart';

class FavoriteProvider with ChangeNotifier {
  List<Map<String, dynamic>> _favorites = [];
  final String _currentUserId = "1"; // Replace with your Auth logic
  List<Map<String, dynamic>> get bookmarks => _favorites;

  FavoriteProvider() {
    fetchBookmarksFromServer();
  }

  // Fetch list from MySQL
  Future<void> fetchBookmarksFromServer() async {
    final url = Uri.parse(
      '${ipaddress.baseUrl}get_bookmarks.php?user_id=$_currentUserId',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        _favorites = data.map((item) {
          return {
            'title': item['subject'] ?? '',
            'chapter_num': item['chapter_number'] ?? '',
            'title_en': item['title_en'] ?? '',
            'title_ms': item['title_ms'] ?? '',
            'image': item['image_url'] ?? '',
            'infographic_en': item['infographic_en'] ?? '',
            'infographic_ms': item['infographic_ms'] ?? '',
          };
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error fetching: $e");
    }
  }

  // Toggle bookmark in MySQL
  // Inside FavoriteProvider
  Future<void> toggleFavorite(Map<String, dynamic> material) async {
    final url = Uri.parse('${ipaddress.baseUrl}toggle_bookmark.php');
    try {
      final response = await http.post(
        url,
        body: {
          'user_id': _currentUserId,
          'subject': material['title'] ?? '',
          'chapter_number': material['chapter_num'] ?? '',
          'title_en': material['title_en'] ?? '',
          'title_ms': material['title_ms'] ?? '',
          'infographic_en': material['infographic_en'] ?? '',
          'infographic_ms': material['infographic_ms'] ?? '',
          'image_url': material['image'] ?? '',
        },
      );

      if (response.statusCode == 200) {
        // Refresh local list from server to get accurate state
        await fetchBookmarksFromServer();
        // notifyListeners() is called inside fetchBookmarksFromServer
      }
    } catch (e) {
      debugPrint("Network Error: $e");
    }
  }

  // Inside FavoriteProvider
  bool isFavorited(String subject, String chapterNum) {
    return _favorites.any((m) {
      // Convert both to string and trim to avoid whitespace issues
      final mSubject = m['title']?.toString().trim() ?? '';
      final mChapter = m['chapter_num']?.toString().trim() ?? '';
      final targetSubject = subject.toString().trim();
      final targetChapter = chapterNum.toString().trim();

      return mSubject == targetSubject && mChapter == targetChapter;
    });
  }
}
