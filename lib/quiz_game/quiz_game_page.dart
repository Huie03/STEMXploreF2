import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:http/http.dart' as http;
//import 'package:provider/provider.dart';
import '../ipaddress.dart';
//import 'package:stemxploref2/theme_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/language_toggle.dart';
import '../widgets/box_shadow.dart';
import '../widgets/rawscrollbar.dart';

class QuizGamePage extends StatefulWidget {
  final Function(String, String) onQuizStart;
  final String initialSubject; // Add this line

  // Add initialSubject to the constructor with a default value
  const QuizGamePage({
    super.key,
    required this.onQuizStart,
    required this.initialSubject,
  });

  @override
  State<QuizGamePage> createState() => _QuizGamePageState();
}

class _QuizGamePageState extends State<QuizGamePage> {
  late String selectedCategory;
  List quizzes = [];
  bool isLoading = true;

  final ScrollController _filterScrollController = ScrollController();
  final ScrollController _quizListController = ScrollController();

  final List<String> subjectsEn = [
    "Science",
    "Mathematics",
    "Computer Science",
    "Design And Technology",
  ];

  @override
  void initState() {
    super.initState();
    // 1. Set the starting category
    selectedCategory = widget.initialSubject;
    fetchQuizzes(selectedCategory);

    // 2. Auto-scroll to the correct tab after the frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int index = subjectsEn.indexOf(selectedCategory);
      if (index != -1) {
        _scrollToIndex(index);
      }
    });
  }

  // 3. Handle updates if the parent changes the subject (like SubjectChaptersPage)
  @override
  void didUpdateWidget(covariant QuizGamePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSubject != widget.initialSubject) {
      setState(() {
        selectedCategory = widget.initialSubject;
      });
      fetchQuizzes(selectedCategory);
      int index = subjectsEn.indexOf(selectedCategory);
      if (index != -1) _scrollToIndex(index);
    }
  }

  void _scrollToIndex(int index) {
    if (!_filterScrollController.hasClients) return;
    double screenWidth = MediaQuery.of(context).size.width;
    double itemWidth = 180.0;
    double scrollTarget =
        (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);

    _filterScrollController.animateTo(
      scrollTarget.clamp(0.0, _filterScrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _filterScrollController.dispose();
    _quizListController.dispose();
    super.dispose();
  }

  Future<void> fetchQuizzes(String subject) async {
    setState(() => isLoading = true);
    try {
      // Logic to handle "Science" vs "Sains" depends on your PHP flexible search
      final response = await http.get(
        Uri.parse('${ipaddress.baseUrl}get_quiz_subject.php?subject=$subject'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          quizzes = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load quizzes');
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final FlutterLocalization localization = FlutterLocalization.instance;
    // FIX: Using localization instead of 'nav'
    final bool isEnglish = localization.currentLocale?.languageCode == 'en';
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color cardBg = Theme.of(context).colorScheme.surface;
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(isEnglish, isDark),
              const SizedBox(height: 10),
              _buildCategoryTabs(isEnglish, isDark, cardBg, textColor),
              const SizedBox(height: 10),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : quizzes.isEmpty
                    ? _buildEmptyState(isEnglish)
                    : _buildQuizList(isEnglish),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isEnglish, bool isDark) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 5, 16, 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isEnglish ? 'Quiz Game' : 'Permainan Kuiz',
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

  Widget _buildCategoryTabs(
    bool isEnglish,
    bool isDark,
    Color cardBg,
    Color textColor,
  ) {
    final List<String> displaySubjects = isEnglish
        ? subjectsEn
        : [
            "Sains",
            "Matematik",
            "Asas Sains Komputer",
            "Reka Bentuk Dan Teknologi",
          ];

    return SizedBox(
      height: 60, // Increased height to match SubjectChaptersPage
      child: ListView.builder(
        controller: _filterScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: displaySubjects.length,
        itemBuilder: (context, index) {
          // Compare using English list for logic consistency
          bool isSelected = selectedCategory == subjectsEn[index];

          return GestureDetector(
            onTap: () {
              setState(() => selectedCategory = subjectsEn[index]);
              fetchQuizzes(subjectsEn[index]);
              _scrollToIndex(index);
            },
            child: AnimatedScale(
              scale: isSelected ? 1.05 : 0.95,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                padding: const EdgeInsets.symmetric(horizontal: 25),
                decoration: BoxDecoration(
                  // Use your signature orange for selected
                  color: isSelected ? const Color(0xFFEB9000) : cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: isDark && !isSelected
                      ? Border.all(color: Colors.white10)
                      : null,
                ),
                child: Center(
                  child: Text(
                    displaySubjects[index],
                    style: TextStyle(
                      color: isSelected ? Colors.black : textColor,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuizList(bool isEnglish) {
    return AppRawScrollbar(
      controller: _quizListController, // Pass the controller to the scrollbar
      child: ListView.builder(
        controller: _quizListController, // MUST match the controller above
        padding: const EdgeInsets.all(20),
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return GestureDetector(
            onTap: () {
              // ... your existing onTap logic ...
              Map<String, String> subjectToId = {
                "Science": "1",
                "Mathematics": "2",
                "Computer Science": "3",
                "Design And Technology": "4",
              };
              String subjectId = subjectToId[selectedCategory] ?? "1";
              String tEn = quiz['title_en'] ?? "Quiz";
              String tMs = quiz['title_ms'] ?? "Kuiz";
              widget.onQuizStart("$subjectId | $tEn | $tMs", "start");
            },
            child: _quizCard(
              title: isEnglish ? quiz['title_en'] : quiz['title_ms'],
              sub:
                  "${quiz['total_questions']} ${isEnglish ? "Questions" : "Soalan"}",
              imgPath: quiz['image_url'] ?? "",
              isEnglish: isEnglish,
            ),
          );
        },
      ),
    );
  }

  Widget _quizCard({
    required String title,
    required String sub,
    required String imgPath,
    required bool isEnglish,
  }) {
    final Color cardBg = Theme.of(context).colorScheme.surface;
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: appBoxShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  sub,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEB9000),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isEnglish ? "Start Quiz" : "Mula Kuiz",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              "${ipaddress.baseUrl}$imgPath",
              width: 70,
              height: 85,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, size: 80, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isEnglish) {
    return Center(
      child: Text(
        isEnglish ? "No quizzes found." : "Tiada kuiz dijumpai.",
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
