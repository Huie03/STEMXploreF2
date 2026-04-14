import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/navigation_provider.dart';
import '/widgets/curved_navigation_bar.dart';

import 'home_page.dart';
import '../favorite/favorite_page.dart';
import 'info_page.dart';
import 'settings_page.dart';
import '/stem_info/stem_info_page.dart';
import '/learning_materials/learning_materials_page.dart';
import '/quiz_game/quiz_game_page.dart';
import '../quiz_game/play_quiz_page.dart';
import '/stem_career/stem_careers_page.dart';
import '../daily_info/daily_info_page.dart';
import '/pages/faq_page.dart';
import '/stem_highlights/highlight_detail_page.dart';
import 'package:stemxploref2/learning_materials/subject_chapters_page.dart';
import 'package:stemxploref2/learning_materials/material_details_page.dart'; // Add this
import '/stem_info/stem_detail_page.dart';
import '../stem_highlights/highlight.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  dynamic selectedHighlight;
  dynamic selectedStemInfo;
  String? selectedSubjectName;
  String selectedQuizCategory = "Science";
  Map<String, dynamic>? selectedChapterData;
  String? selectedQuizData;
  int _lastIndexBeforeDetail = 12;

  void onSubjectSelected(String subjectName) {
    setState(() => selectedSubjectName = subjectName);
    Provider.of<NavigationProvider>(context, listen: false).setIndex(12);
  }

  // When coming from Learning Materials (SubjectChapters)
  void onChapterSelected(Map<String, dynamic> chapterData) {
    setState(() {
      selectedChapterData = chapterData;
      _lastIndexBeforeDetail = 12; // User came from Subjects/Chapters
    });
    Provider.of<NavigationProvider>(context, listen: false).setIndex(13);
  }

  // When coming from Favorites
  void onFavoriteChapterSelected(Map<String, dynamic> chapterData) {
    setState(() {
      selectedChapterData = chapterData;
      _lastIndexBeforeDetail = 1; // User came from Favorites
    });
    Provider.of<NavigationProvider>(context, listen: false).setIndex(13);
  }

  void onQuizSubjectSelected(String subjectAndMode) {
    setState(() {
      selectedQuizData = subjectAndMode;
    });
    Provider.of<NavigationProvider>(context, listen: false).setIndex(14);
  }

  void onHighlightSelected(dynamic highlight) {
    setState(() => selectedHighlight = highlight);
    Provider.of<NavigationProvider>(context, listen: false).setIndex(10);
  }

  void onStemSelect(dynamic stemInfo) {
    setState(() => selectedStemInfo = stemInfo);
    Provider.of<NavigationProvider>(context, listen: false).setIndex(11);
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    final int activeNavIconIndex = (navProvider.currentIndex > 3)
        ? 0
        : navProvider.currentIndex;

    final List<Widget> pages = [
      // Inside pages/main_screen.dart
      // Change this block in your MainScreen:
      HomePage(
        onHighlightTap: (Highlight h) {
          // 1. Update the state so the IndexedStack builds the Detail page
          setState(() => selectedHighlight = h);

          // 2. Switch to the index that holds the detail page
          Provider.of<NavigationProvider>(context, listen: false).setIndex(10);

          // 3. Return a dummy Future so your existing 'await' in HomePage doesn't crash
          return Future.value();
        },
      ), // 0
      FavoritePage(
        onChapterTap: (chapterData) {
          setState(() {
            selectedChapterData = chapterData;
            _lastIndexBeforeDetail = 1; // Explicitly set to Favorites index
          });
          navProvider.setIndex(13); // Navigate to Details
        },
      ),
      const InfoPage(), // 2
      const SettingsPage(), // 3
      StemInfoPage(onSelect: onStemSelect), // 4
      LearningMaterialPage(
        onSubjectTap: onSubjectSelected,
        onBackOverride: () => navProvider.setIndex(0),
      ), // 5
      // Index 6: Updated QuizGamePage
      QuizGamePage(
        key: navProvider.currentIndex == 6
            ? const ValueKey('quiz_menu')
            : UniqueKey(),
        initialSubject: selectedQuizCategory, // Pass the tracked variable
        onQuizStart: (quizData, mode) {
          // Update the tracked variable whenever a user starts a quiz
          // This ensures if they come back, it's set to the one they just played
          final String subjectId = quizData.split('|')[0].trim();
          setState(() {
            if (subjectId == "1") selectedQuizCategory = "Science";
            if (subjectId == "2") selectedQuizCategory = "Mathematics";
            if (subjectId == "3") selectedQuizCategory = "Computer Science";
            if (subjectId == "4")
              selectedQuizCategory = "Design And Technology";
          });

          onQuizSubjectSelected(quizData);
        },
      ),
      const StemCareersPage(), // 7
      const DailyInfoPage(), // 8
      // 9
      FaqPage(
        // The key changes ONLY when the index is 9.
        // This forces the FAQ page to REBUILD (resetting _expandedIndex)
        // ONLY when the user navigates TO this page from another tab.
        key: navProvider.currentIndex == 9
            ? const ValueKey('faq_active')
            : UniqueKey(),
      ),

      selectedHighlight != null
          ? HighlightDetailPage(highlight: selectedHighlight)
          : const SizedBox.shrink(), // 10

      selectedStemInfo != null
          ? StemDetailPage(
              key: ValueKey(selectedStemInfo['title_en'] ?? 'stem_detail'),
              stemInfo: selectedStemInfo,
            )
          : const SizedBox.shrink(), // 11

      selectedSubjectName != null
          ? SubjectChaptersPage(
              initialSubject: selectedSubjectName!,
              onChapterTap: onChapterSelected,
            )
          : const SizedBox.shrink(), // 12

      selectedChapterData != null
          ? MaterialDetailPage(chapterData: selectedChapterData!)
          : const SizedBox.shrink(), // 13
      // Inside MainScreen pages list
      selectedQuizData != null
          ? PlayQuizPage(
              // IMPORTANT: The key MUST be here.
              // When selectedQuizData changes from "ASK|Easy" to "Science|Easy",
              // Flutter sees the key is different and runs initState() again.
              key: ValueKey(selectedQuizData),
              subjectAndMode: selectedQuizData!,
              onFinish: () {
                setState(() => selectedQuizData = null);
                navProvider.setIndex(6);
              },
            )
          : const SizedBox.shrink(), // Index 14
    ];

    return PopScope(
      canPop: navProvider.currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (navProvider.currentIndex == 14) {
          setState(() => selectedQuizData = null);
          navProvider.setIndex(6); // Back to Quiz List from the Game
        } else if (navProvider.currentIndex == 13) {
          // Use the stored variable to return to the correct index
          navProvider.setIndex(_lastIndexBeforeDetail);
        } else if (navProvider.currentIndex == 12) {
          navProvider.setIndex(5); // Back to Subjects from Chapters
        } else if (navProvider.currentIndex == 10 ||
            navProvider.currentIndex == 11) {
          navProvider.setIndex(navProvider.currentIndex == 10 ? 0 : 4);
        } else if (navProvider.currentIndex == 6) {
          // If user is on the Quiz List and goes back to Home
          setState(() => selectedQuizCategory = "Science");
          navProvider.setIndex(0);
        } else {
          navProvider.setIndex(0);
        }
      },
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: AppCurvedNavBar(
          currentIndex: activeNavIconIndex,
          onTap: (index) {
            // If the user clicks the Quiz Game tab (index 6)
            if (index == 6) {
              selectedQuizCategory = "Science";
            }

            // RESTART LOGIC: If user clicks Home (0), Bookmark (1), etc.
            // we clear the quiz data so it's fresh for next time.
            if (selectedQuizData != null) {
              setState(() {
                selectedQuizData = null;
              });
            }
            navProvider.setIndex(index);
          },
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(index: navProvider.currentIndex, children: pages),
        ),
      ),
    );
  }
}
