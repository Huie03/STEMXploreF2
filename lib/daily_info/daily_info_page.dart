import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stemxploref2/widgets/gradient_background.dart';
import 'package:stemxploref2/widgets/language_toggle.dart';
import 'package:provider/provider.dart';
import 'package:stemxploref2/navigation_provider.dart';
import 'package:stemxploref2/theme_provider.dart';
import '../widgets/box_shadow.dart';

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
    final navProvider = Provider.of<NavigationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final bool isDark = themeProvider.isDarkMode;
    final bool isEnglish = navProvider.locale.languageCode == 'en';

    final int dayIndex = DateTime.now().day % _challenges.length;
    final currentChallenge = _challenges[dayIndex];
    final String title = isEnglish ? 'Daily Info' : 'Maklumat Harian';
    final Color titleColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: titleColor,
                      ),
                    ),
                    const LanguageToggle(),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Center(
                        // This centers the card vertically
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25.0,
                            ),
                            child: _buildChallengeCard(
                              currentChallenge,
                              isEnglish,
                              isDark,
                            ),
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

  Widget _buildChallengeCard(Info info, bool isEnglish, bool isDark) {
    final Color cardBg = Theme.of(context).colorScheme.surface;
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color subTextColor = isDark ? Colors.white70 : Colors.black87;
    const Color successGreen = Color(0xFF5DF162);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? [] : appBoxShadow,
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ensures card doesn't take full height
        children: [
          Text(
            isEnglish
                ? 'STEM Fact of the Day – ${info.titleEn}'
                : 'Fakta STEM Hari Ini – ${info.titleMs}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textColor,
            ),
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              info.imagePath,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isEnglish ? info.factEn : info.factMs,
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 15, height: 1.5, color: subTextColor),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _isCompleted ? null : _handleComplete,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isCompleted
                  ? successGreen.withOpacity(0.1)
                  : (isDark ? const Color(0xFFEFA638) : Colors.black),
              foregroundColor: _isCompleted
                  ? successGreen
                  : (isDark ? Colors.black : Colors.white),
              disabledBackgroundColor: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade100,
              disabledForegroundColor: _isCompleted
                  ? (isDark ? successGreen : Colors.green.shade700)
                  : Colors.grey,
              minimumSize: const Size(double.infinity, 56),
              elevation: _isCompleted ? 0 : 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isCompleted
                  ? Row(
                      key: const ValueKey('completed'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 22),
                        const SizedBox(width: 10),
                        Text(
                          isEnglish ? 'Great Job!' : 'Syabas!',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      key: const ValueKey('active'),
                      isEnglish ? 'Mark as Read' : 'Tanda sebagai Dibaca',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
