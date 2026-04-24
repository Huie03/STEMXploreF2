import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:stemxploref2/widgets/gradient_background.dart';
import 'package:stemxploref2/widgets/language_toggle.dart';
import 'package:stemxploref2/navigation_provider.dart';
import 'package:stemxploref2/widgets/box_shadow.dart';
import 'package:stemxploref2/widgets/rawscrollbar.dart';
import 'package:stemxploref2/database_helper.dart';
import 'package:stemxploref2/full_screen_image_page.dart';

class FaqPage extends StatefulWidget {
  static const routeName = '/faq';
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final ScrollController _scrollController = ScrollController();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  int _expandedIndex = -1; // -1 means everything is closed
  late Future<List<Map<String, dynamic>>> _faqFuture;

  // 1. Keep initState as is - it ensures boxes are closed on fresh entry
  @override
  void initState() {
    super.initState();
    _expandedIndex = -1;
    _faqFuture = _fetchFaqs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _expandedIndex == -1) {
        _scrollController.jumpTo(0);
      }
    });
  }

  Future<List<Map<String, dynamic>>> _fetchFaqs() async {
    try {
      final List<Map<String, dynamic>> data = await _dbHelper.getFaqs();
      return data;
    } catch (e) {
      debugPrint("SQLite Fetch Error: $e");
      return [];
    }
  }

  void _showFullScreenImage(BuildContext context, String assetPath) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
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
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(
                context,
                isEnglish ? 'Frequently Asked Question' : 'Soalan Lazim',
                textColor,
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _faqFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final faqs = snapshot.data ?? [];

                    return AppRawScrollbar(
                      controller: _scrollController,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(30, 13, 30, 16),
                        itemCount: faqs.length,
                        itemBuilder: (context, index) {
                          final item = faqs[index];
                          return _buildFaqItem(
                            index,
                            isEnglish
                                ? (item['question_en'] ?? '')
                                : (item['question_ms'] ?? ''),
                            isEnglish
                                ? (item['answer_en'] ?? '')
                                : (item['answer_ms'] ?? ''),
                            isDark,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 21,
              color: textColor,
            ),
          ),
          const LanguageToggle(),
        ],
      ),
    );
  }

  Widget _buildFaqItem(int index, String question, String answer, bool isDark) {
    final bool isExpanded = _expandedIndex == index;
    final Color questionBg = isDark ? const Color(0xFF535252) : Colors.white;
    final Color answerBg = isDark
        ? const Color.fromARGB(255, 111, 111, 111)
        : const Color.fromARGB(255, 235, 145, 0);

    bool isImagePath =
        answer.contains('assets/') &&
        (answer.endsWith('.png') || answer.endsWith('.jpg'));

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => _expandedIndex = isExpanded ? -1 : index),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: questionBg,
                boxShadow: isDark ? [] : appBoxShadow,
                borderRadius: BorderRadius.circular(15),
                border: isDark ? Border.all(color: Colors.white10) : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: answerBg,
                  boxShadow: isDark ? [] : appBoxShadow,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: isImagePath
                    ? GestureDetector(
                        onTap: () => _showFullScreenImage(context, answer),
                        child: Hero(
                          tag: answer,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              answer,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Text(
                                  'Image not found',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      )
                    : Text(
                        answer,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
