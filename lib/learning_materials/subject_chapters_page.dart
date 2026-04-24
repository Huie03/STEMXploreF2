import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import '../widgets/gradient_background.dart';
import '../widgets/language_toggle.dart';
import '../widgets/rawscrollbar.dart';
import '../widgets/box_shadow.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:stemxploref2/database_helper.dart';
import 'package:provider/provider.dart';

class SubjectChaptersPage extends StatefulWidget {
  final String initialSubject;

  final Function(Map<String, dynamic>) onChapterTap;

  const SubjectChaptersPage({
    super.key,
    required this.initialSubject,
    required this.onChapterTap,
  });

  @override
  State<SubjectChaptersPage> createState() => _SubjectChaptersPageState();
}

class _SubjectChaptersPageState extends State<SubjectChaptersPage> {
  late String selectedSubject;
  final ScrollController _filterScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  final List<String> subjects = [
    "Science",
    "Mathematics",
    "Computer Science (ASK)",
    "Design and Technology (RBT)",
  ];

  @override
  void dispose() {
    _filterScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Ensure we start with the value passed from MainScreen (which is "Science")
    selectedSubject = widget.initialSubject;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncStateToSubject(selectedSubject);
    });
  }

  @override
  void didUpdateWidget(covariant SubjectChaptersPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // This triggers when the parent screen changes the 'initialSubject'
    if (oldWidget.initialSubject != widget.initialSubject) {
      setState(() {
        // 1. Update the local state to match the new subject from parent
        selectedSubject = widget.initialSubject;
      });

      // 2. Sync the UI (scroll to the new tab and reset the chapter list to top)
      _syncStateToSubject(selectedSubject);
    }
  }

  void _syncStateToSubject(String subject) {
    // Find the index of the subject in your internal list (the DB keys)
    int index = subjects.indexOf(subject);
    if (index != -1) {
      _scrollToIndex(index);
    }

    // Reset the vertical chapter list to the very top so the user
    // doesn't start halfway down a new subject's chapters
    if (_verticalScrollController.hasClients) {
      _verticalScrollController.jumpTo(0);
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

  String _translateSubject(String subject, bool isEnglish) {
    if (isEnglish) {
      // Logic for English display
      switch (subject) {
        case "Computer Science (ASK)":
          return "Fundamentals of Computer Science";
        case "Design and Technology (RBT)":
          return "Design and Technology";
        default:
          // For Science and Mathematics, or any others, just return the string
          return subject;
      }
    }

    // Logic for Malay display
    switch (subject) {
      case "Science":
        return "Sains";
      case "Mathematics":
        return "Matematik";
      case "Computer Science (ASK)":
        return "Asas Sains Komputer";
      case "Design and Technology (RBT)":
        return "Reka Bentuk dan Teknologi";
      default:
        return subject;
    }
  }

  // UPDATED: Now fetches from SQLite instead of PHP
  Future<List<Map<String, dynamic>>> _getChaptersFromDb(String subject) async {
    try {
      final List<Map<String, dynamic>> data = await _dbHelper.getChapters(
        subject,
      );

      // Sort chapters numerically
      List<Map<String, dynamic>> sortedData = List.from(data);
      sortedData.sort((a, b) {
        int numA = int.tryParse(a['chapter_number'].toString()) ?? 0;
        int numB = int.tryParse(b['chapter_number'].toString()) ?? 0;
        return numA.compareTo(numB);
      });
      return sortedData;
    } catch (e) {
      debugPrint("Database Error: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color cardBg = Theme.of(context).colorScheme.surface;
    final Color subTextColor = isDark ? Colors.white70 : Colors.black87;

    final FlutterLocalization localization = FlutterLocalization.instance;
    final bool isEnglish =
        localization.currentLocale?.languageCode == 'en' ||
        localization.currentLocale == null;

    final String pageTitle = isEnglish
        ? 'Learning Material'
        : 'Bahan Pembelajaran';
    final String chapterLabel = isEnglish ? 'Chapter' : 'Bab';

    return Material(
      color: Colors.transparent,
      child: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildCustomAppBar(pageTitle, textColor),
              const SizedBox(height: 15),
              _buildAnimatedFilter(isEnglish, isDark, cardBg, textColor),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _getChaptersFromDb(selectedSubject),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError ||
                        snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          isEnglish
                              ? "No chapters found"
                              : "Tiada bab dijumpai",
                          style: TextStyle(color: textColor),
                        ),
                      );
                    }

                    final chapters = snapshot.data!;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        double contentHeight = chapters.length * 115.0;

                        bool needsScroll =
                            contentHeight > constraints.maxHeight;

                        Widget listView = ListView.builder(
                          controller: _verticalScrollController,
                          padding: const EdgeInsets.fromLTRB(30, 5, 30, 30),
                          itemCount: chapters.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                final Map<String, dynamic> chapterData =
                                    Map.from(chapters[index]);
                                chapterData['subject'] = selectedSubject;
                                widget.onChapterTap(chapterData);
                              },
                              child: _buildChapterCard(
                                chapters[index],
                                isEnglish,
                                chapterLabel,
                                isDark,
                                cardBg,
                                textColor,
                                subTextColor,
                              ),
                            );
                          },
                        );

                        if (needsScroll) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 60),
                            child: AppRawScrollbar(
                              controller: _verticalScrollController,
                              child: listView,
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                            child: listView,
                          );
                        }
                      },
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

  Widget _buildCustomAppBar(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: textColor,
              ),
            ),
          ),
          const LanguageToggle(),
        ],
      ),
    );
  }

  Widget _buildAnimatedFilter(
    bool isEnglish,
    bool isDark,
    Color cardBg,
    Color textColor,
  ) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        controller: _filterScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedSubject == subjects[index];

          return GestureDetector(
            onTap: () {
              setState(() => selectedSubject = subjects[index]);
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
                  color: isSelected ? const Color(0xFFEB9000) : cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: isDark && !isSelected
                      ? Border.all(color: Colors.white10)
                      : null,
                  boxShadow: isDark ? [] : filterBoxShadow(isSelected),
                ),
                child: Center(
                  child: Text(
                    _translateSubject(subjects[index], isEnglish),
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

  Widget _buildChapterCard(
    Map<String, dynamic> data,
    bool isEnglish,
    String label,
    bool isDark,
    Color cardBg,
    Color textColor,
    Color subTextColor,
  ) {
    final String displayTitle = isEnglish
        ? (data['title_en'] ?? "No Title")
        : (data['title_ms'] ?? "Tiada Tajuk");

    final String assetPath = data['image_url'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: isDark ? Border.all(color: Colors.white10, width: 0.5) : null,
        boxShadow: isDark ? [] : appBoxShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$label ${data['chapter_number']}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayTitle,
                  style: TextStyle(color: subTextColor, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              assetPath,
              height: 85,
              width: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.book, size: 40, color: subTextColor),
            ),
          ),
        ],
      ),
    );
  }
}
