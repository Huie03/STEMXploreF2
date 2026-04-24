import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  // Getter to provide global access to the database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  // Initializes the database by copying the asset to local storage
  Future<Database> _initDb() async {
    var databasesPath = await getDatabasesPath();
    // Name of the file on the user's phone
    String path = join(databasesPath, "stemxploref2_local.db");

    bool exists = await databaseExists(path);

    if (!exists) {
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Load the file from your pubspec.yaml assets
      ByteData data = await rootBundle.load("assets/database/stemxploref2.db");
      List<int> bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      // Save to local documents folder so sqflite can read/write
      await File(path).writeAsBytes(bytes, flush: true);
    }
    return await openDatabase(path);
  }

  //Get Daily Info Facts
  Future<List<Map<String, dynamic>>> getDailyInfo() async {
    final db = await database;
    return await db.query('daily_info');
  }

  //Get All Chapters for a specific subject
  Future<List<Map<String, dynamic>>> getChapters(String subject) async {
    final db = await database;
    return await db.query(
      'chapters',
      where: 'subject_name = ?',
      whereArgs: [subject],
    );
  }

  //Get Quiz Questions for a specific subject and chapter
  Future<List<Map<String, dynamic>>> getQuizQuestions(
    String subject,
    int chapterId,
  ) async {
    final db = await database;
    return await db.query(
      'quiz_questions',
      where: 'subject = ? AND chapter_id = ?',
      whereArgs: [subject, chapterId],
    );
  }

  // Get STEM Career Categories
  Future<List<Map<String, dynamic>>> getStemCareers() async {
    final db = await database;
    return await db.query('stem_careers');
  }

  // Get Frequently Asked Questions
  Future<List<Map<String, dynamic>>> getFaqs() async {
    final db = await database;
    return await db.query('faqs');
  }

  //Get Subject Info for Quizzes
  Future<List<Map<String, dynamic>>> getQuizSubjects() async {
    final db = await database;
    return await db.query('quiz_subject');
  }

  // Save or Retrieve Bookmarks
  Future<int> insertBookmark(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('user_bookmarks', row);
  }

  //Fet Bookmarks
  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final db = await database;
    return await db.query('user_bookmarks');
  }

  //Get Stem Info
  Future<List<Map<String, dynamic>>> getStemInfo() async {
    final db = await database;
    return await db.query('stem_info');
  }

  //Get STEM Highlights
  Future<List<Map<String, dynamic>>> getStemHighlights() async {
    final db = await database;
    return await db.query('stem_highlights');
  }
}
