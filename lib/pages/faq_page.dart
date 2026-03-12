import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:stemxploref2/theme_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/language_toggle.dart';
import '../navigation_provider.dart';
import '../widgets/box_shadow.dart';
import '../widgets/rawscrollbar.dart';
import '../ipaddress.dart';

class FaqModel {
  final String questionEn, questionMs, answerEn, answerMs;

  FaqModel({
    required this.questionEn,
    required this.questionMs,
    required this.answerEn,
    required this.answerMs,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      questionEn: json['question_en'] ?? '',
      questionMs: json['question_ms'] ?? '',
      answerEn: json['answer_en'] ?? '',
      answerMs: json['answer_ms'] ?? '',
    );
  }
}

class FaqPage extends StatefulWidget {
  static const routeName = '/faq';
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final ScrollController _scrollController = ScrollController();
  int _expandedIndex = -1;
  late Future<List<FaqModel>> _faqFuture;

  @override
  void initState() {
    super.initState();
    _faqFuture = _fetchFaqs();
  }

  Future<List<FaqModel>> _fetchFaqs() async {
    final url = Uri.parse('${ipadress.baseUrl}get_faq.php');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => FaqModel.fromJson(data)).toList();
      } else {
        debugPrint("Server Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Network Error: $e");
      return [];
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
              _buildCustomAppBar(
                context,
                isEnglish ? 'Frequent Asked Questions' : 'Soalan Lazim',
                textColor,
              ),
              Expanded(
                child: FutureBuilder<List<FaqModel>>(
                  future: _faqFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Error: ${snapshot.error}",
                          style: TextStyle(color: textColor),
                        ),
                      );
                    }

                    final faqs = snapshot.data ?? [];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: AppRawScrollbar(
                        controller: _scrollController,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(28, 13, 18, 16),
                          itemCount: faqs.length,
                          itemBuilder: (context, index) {
                            final item = faqs[index];
                            return FaqItem(
                              question: isEnglish
                                  ? item.questionEn
                                  : item.questionMs,
                              answer: isEnglish ? item.answerEn : item.answerMs,
                              isExpanded: _expandedIndex == index,
                              isDark: isDark,
                              onTap: () => setState(
                                () => _expandedIndex = (_expandedIndex == index)
                                    ? -1
                                    : index,
                              ),
                            );
                          },
                        ),
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
}

class FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  final bool isExpanded;
  final bool isDark;
  final VoidCallback onTap;

  const FaqItem({
    super.key,
    required this.question,
    required this.answer,
    required this.isExpanded,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color questionBg = isDark ? const Color(0xFF3D3D3D) : Colors.white;
    final Color answerBg = isDark
        ? const Color.fromARGB(255, 111, 111, 111)
        : const Color.fromARGB(255, 255, 186, 74);
    final Color questionTextColor = isDark ? Colors.white : Colors.black;
    final Color answerTextColor = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: questionBg,
                boxShadow: isDark ? [] : appBoxShadow,
                border: isDark ? Border.all(color: Colors.white10) : null,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: questionTextColor,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: isDark ? Colors.redAccent : Colors.redAccent,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: answerBg,
                boxShadow: isDark ? [] : appBoxShadow,
                border: isDark ? Border.all(color: Colors.white10) : null,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                answer,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: answerTextColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Widget _buildCustomAppBar(BuildContext context, String title, Color textColor) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: textColor,
          ),
        ),
        const LanguageToggle(),
      ],
    ),
  );
}
