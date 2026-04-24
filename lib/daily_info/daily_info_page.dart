import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '/full_screen_image_page.dart';
import '/widgets/gradient_background.dart';
import '/widgets/language_toggle.dart';
import '/navigation_provider.dart';
import '/theme_provider.dart';
import '/widgets/box_shadow.dart';
import '/database_helper.dart';

class DailyInfoPage extends StatefulWidget {
  static const routeName = '/daily-info';
  const DailyInfoPage({super.key});

  @override
  State<DailyInfoPage> createState() => _DailyInfoPageState();
}

class _DailyInfoPageState extends State<DailyInfoPage> {
  bool _isCompleted = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _challenges = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final dbHelper = DatabaseHelper();
      final data = await dbHelper.getDailyInfo();

      if (mounted) {
        setState(() {
          _challenges = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Offline Database Error: $e";
          _isLoading = false;
        });
      }
    }
    _checkTodayStatus();
  }

  Future<void> _checkTodayStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final key = "challenge_${now.year}_${now.month}_${now.day}";
    if (mounted) setState(() => _isCompleted = prefs.getBool(key) ?? false);
  }

  Future<void> _handleComplete() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setBool("challenge_${now.year}_${now.month}_${now.day}", true);
    if (mounted) setState(() => _isCompleted = true);
  }

  void _showFullScreenImage(BuildContext context, String assetPath) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false, // Allows seeing the background during transition
        barrierColor: Colors.black,
        pageBuilder: (context, _, _) =>
            FullScreenImagePage(assetPath: assetPath),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;
    final bool isEnglish = navProvider.locale.languageCode == 'en';
    final String title = isEnglish ? 'Daily Info' : 'Maklumat Harian';

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(title, isDark),
              Expanded(child: _buildBody(isEnglish, isDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const LanguageToggle(),
        ],
      ),
    );
  }

  Widget _buildBody(bool isEnglish, bool isDark) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage.isNotEmpty) return Center(child: Text(_errorMessage));

    final now = DateTime.now();

    // Map weekday to category (1=Mon, 7=Sun)
    final categories = [
      "Science",
      "Mathematics",
      "ASK",
      "RBT",
      "Science",
      "Mathematics",
      "Mixed",
    ];
    final target = categories[now.weekday - 1];

    //Filter list
    final items = _challenges.where((i) {
      final cat = (i['category'] ?? '').toString().toLowerCase();
      return target == "Mixed"
          ? (cat == "ask" || cat == "rbt")
          : cat == target.toLowerCase();
    }).toList();

    if (items.isEmpty) return const Center(child: Text("No items available"));

    //Optimized Occurrence Logic
    final start = DateTime(now.year, 1, 1);
    int occurrences = 0;

    //Count how many times this category's scheduled days have passed since Jan 1st
    for (int i = 0; i <= now.difference(start).inDays; i++) {
      int wd = start.add(Duration(days: i)).weekday;
      bool isMatch =
          (target == "Science" && (wd == 1 || wd == 5)) ||
          (target == "Mathematics" && (wd == 2 || wd == 6)) ||
          (target == "Mixed" && wd == 7) ||
          (wd == now.weekday &&
              !["Science", "Mathematics", "Mixed"].contains(target));
      if (isMatch) occurrences++;
    }

    final current =
        items[(occurrences > 0 ? occurrences - 1 : 0) % items.length];

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(30, 13, 30, 16),
        child: Column(
          children: [_buildChallengeCard(current, isEnglish, isDark)],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(
    Map<String, dynamic> info,
    bool isEnglish,
    bool isDark,
  ) {
    final Color cardBg = Theme.of(context).colorScheme.surface;
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final String assetPath = info['image_path'] ?? '';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? [] : appBoxShadow,
        border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isEnglish ? (info['title_en'] ?? '') : (info['title_ms'] ?? ''),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textColor,
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () => _showFullScreenImage(context, assetPath),
            child: Hero(
              tag: assetPath,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 450,
                    maxWidth: double.infinity,
                  ),
                  child: Image.asset(
                    assetPath,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 50),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isEnglish ? (info['desc_en'] ?? '') : (info['desc_ms'] ?? ''),
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 25),
          _buildCompleteButton(isEnglish, isDark),
        ],
      ),
    );
  }

  Widget _buildCompleteButton(bool isEnglish, bool isDark) {
    const Color successGreen = Color.fromARGB(255, 39, 190, 44);
    const Color completedBg = Color.fromARGB(255, 230, 230, 230);
    return ElevatedButton(
      onPressed: _isCompleted ? null : _handleComplete,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isCompleted
            ? completedBg
            : (isDark ? const Color(0xFFEFA638) : const Color(0xFFEB9000)),
        disabledBackgroundColor: completedBg,
        foregroundColor: _isCompleted
            ? successGreen
            : (isDark ? Colors.black : Colors.black),
        disabledForegroundColor: successGreen,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: _isCompleted ? 0 : 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isCompleted) ...[
            const Icon(Icons.check_circle_outline, size: 22),
            const SizedBox(width: 8),
          ],
          Text(
            _isCompleted
                ? (isEnglish ? 'Great Job!' : 'Syabas!')
                : (isEnglish ? 'Mark as Read' : 'Tanda sebagai Dibaca'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
