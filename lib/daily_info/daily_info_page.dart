import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stemxploref2/widgets/gradient_background.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localization/flutter_localization.dart';
import '/navigation_provider.dart';
import 'package:stemxploref2/widgets/curved_navigation_bar.dart';
import 'package:stemxploref2/widgets/language_toggle.dart'; // Import the toggle

class Info {
  final String titleEn;
  final String titleMs;
  final String factEn;
  final String factMs;
  final String imagePath;

  Info({
    required this.titleEn,
    required this.titleMs,
    required this.factEn,
    required this.factMs,
    required this.imagePath,
  });
}

class DailyInfoPage extends StatefulWidget {
  static const routeName = '/daily-info';
  const DailyInfoPage({super.key});

  @override
  State<DailyInfoPage> createState() => _DailyChallengePageState();
}

class _DailyChallengePageState extends State<DailyInfoPage> {
  bool _isCompleted = false;
  bool _isLoading = true;

  final List<Info> _challenges = [
    Info(
      titleEn: 'Nutrition',
      titleMs: 'Nutrisi',
      factEn:
          'Carbohydrates are the main source of energy for our body and help us stay active. Foods like rice, bread, and fruits contain carbohydrates. Eating a balanced diet helps our body grow strong and stay healthy.',
      factMs:
          'Karbohidrat adalah sumber tenaga utama bagi tubuh kita dan membantu kita kekal aktif. Makanan seperti nasi, roti dan buah-buahan mengandungi karbohidrat. Pengambilan makanan seimbang membantu tubuh kita membesar dengan sihat dan kuat.',
      imagePath: 'assets/images/nutrition.png',
    ),
    Info(
      titleEn: 'Biodiversity',
      titleMs: 'Kepelbagaian Biologi',
      factEn:
          'Biodiversity refers to the variety of living organisms, such as plants and animals, in a habitat and helps keep ecosystems stable. Forests with many different species are usually healthier.',
      factMs:
          'Kepelbagaian biologi merujuk kepada kepelbagaian organisma hidup seperti tumbuhan dan haiwan dalam sesuatu habitat dan membantu mengekalkan kestabilan ekosistem. Hutan yang mempunyai pelbagai spesies biasanya lebih sihat.',
      imagePath: 'assets/images/biodiversity.png',
    ),
    Info(
      titleEn: 'Ecosystem',
      titleMs: 'Ekosistem',
      factEn:
          'An ecosystem is a community of living organisms interacting with each other and with non-living components like water, air, and soil. Examples of ecosystems include forests, rivers, and oceans.',
      factMs:
          'Ekosistem ialah komuniti organisma hidup yang berinteraksi antara satu sama lain dan dengan komponen bukan hidup seperti air, udara dan tanah. Contoh ekosistem termasuk hutan, sungai dan lautan.',
      imagePath: 'assets/images/ecosystem.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkTodayStatus();
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return "challenge_${now.year}_${now.month}_${now.day}";
  }

  Future<void> _checkTodayStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _isCompleted = prefs.getBool(_getTodayKey()) ?? false;
      _isLoading = false;
    });
  }

  Future<void> _handleComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_getTodayKey(), true);
    if (!mounted) return;
    setState(() {
      _isCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final FlutterLocalization localization = FlutterLocalization.instance;
    final bool isEnglish =
        localization.currentLocale?.languageCode == 'en' ||
        localization.currentLocale == null;

    final int dayIndex = DateTime.now().day % _challenges.length;
    final currentChallenge = _challenges[dayIndex];
    final String title = isEnglish ? 'Daily Info' : 'Maklumat Harian';

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // --- CUSTOM APP BAR ---
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                    // Updated to use shared widget with callback
                    LanguageToggle(
                      onLanguageChanged: () {
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              // --- CONTENT ---
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 25),
                              _buildChallengeCard(currentChallenge, isEnglish),
                              const SizedBox(height: 28),
                              if (_isCompleted) _buildSuccessMessage(isEnglish),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeCard(Info info, bool isEnglish) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isEnglish
                ? 'STEM Fact of the Day – ${info.titleEn}'
                : 'Fakta STEM Hari Ini – ${info.titleMs}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              info.imagePath,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              isEnglish ? 'Did you know?' : 'Tahukah anda?',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            isEnglish ? info.factEn : info.factMs,
            textAlign: TextAlign.justify,
            style: const TextStyle(fontSize: 15, height: 1.4),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: _isCompleted ? null : _handleComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _isCompleted
                  ? (isEnglish ? 'Challenge Finished' : 'Cabaran Selesai')
                  : (isEnglish ? 'Complete Challenge' : 'Selesaikan Cabaran'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage(bool isEnglish) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF5DF162), size: 40),
          const SizedBox(height: 10),
          Text(
            isEnglish ? 'Well done!' : 'Syabas!',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 5),
          Text(
            isEnglish
                ? 'You completed today\'s challenge.'
                : 'Anda telah menyelesaikan cabaran hari ini.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
