import 'package:flutter/material.dart';
import 'package:stemxploref2/database_helper.dart';

class BookmarkProvider with ChangeNotifier {
  List<Map<String, dynamic>> _favorites = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Static ID for local use as per your previous logic
  final int _currentUserId = 1;

  List<Map<String, dynamic>> get bookmarks => _favorites;

  BookmarkProvider() {
    refreshBookmarks();
  }

  // Fetch list from local SQLite instead of MySQL
  Future<void> refreshBookmarks() async {
    try {
      final data = await _dbHelper
          .getBookmarks(); // Uses the method in your DatabaseHelper

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
    } catch (e) {
      debugPrint("Database Error fetching bookmarks: $e");
    }
  }

  // Toggle bookmark logic for SQLite
  Future<void> toggleFavorite(Map<String, dynamic> material) async {
    try {
      final db = await _dbHelper.database;

      String subject = material['title'] ?? material['subject'] ?? '';
      String chapter =
          material['chapter_num'] ?? material['chapter_number'] ?? '';

      // Check if already exists in local DB
      List<Map<String, dynamic>> existing = await db.query(
        'user_bookmarks',
        where: 'subject = ? AND chapter_number = ?',
        whereArgs: [subject, chapter],
      );

      if (existing.isNotEmpty) {
        // Delete if exists
        await db.delete(
          'user_bookmarks',
          where: 'id = ?',
          whereArgs: [existing.first['id']],
        );
      } else {
        // Insert new bookmark
        await _dbHelper.insertBookmark({
          'user_id': _currentUserId,
          'subject': subject,
          'chapter_number': chapter,
          'title_en': material['title_en'] ?? '',
          'title_ms': material['title_ms'] ?? '',
          'infographic_en': material['infographic_en'] ?? '',
          'infographic_ms': material['infographic_ms'] ?? '',
          'image_url': material['image'] ?? material['image_url'] ?? '',
        });
      }

      // Refresh the local list to update UI
      await refreshBookmarks();
    } catch (e) {
      debugPrint("Database Toggle Error: $e");
    }
  }

  // Local check if item is favorited
  bool isFavorited(String subject, String chapterNum) {
    return _favorites.any((m) {
      final mSubject = m['title']?.toString().trim() ?? '';
      final mChapter = m['chapter_num']?.toString().trim() ?? '';
      return mSubject == subject.trim() && mChapter == chapterNum.trim();
    });
  }
}
