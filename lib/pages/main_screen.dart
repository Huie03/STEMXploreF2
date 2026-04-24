import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stemxploref2/navigation_provider.dart';
import 'package:stemxploref2/widgets/curved_navigation_bar.dart';

import 'package:stemxploref2/pages/home_page.dart';
import 'package:stemxploref2/bookmark/bookmark_page.dart';
import 'package:stemxploref2/pages/info_page.dart';
import 'package:stemxploref2/pages/settings_page.dart';
import 'package:stemxploref2/stem_info/stem_info_page.dart';
import 'package:stemxploref2/quiz_game/quiz_game_page.dart';
import 'package:stemxploref2/quiz_game/play_quiz_page.dart';
import 'package:stemxploref2/stem_career/stem_careers_page.dart';
import 'package:stemxploref2/daily_info/daily_info_page.dart';
import 'package:stemxploref2/pages/faq_page.dart';
import 'package:stemxploref2/stem_highlights/highlight_detail_page.dart';
import 'package:stemxploref2/learning_materials/subject_chapters_page.dart';
import 'package:stemxploref2/learning_materials/material_details_page.dart';
import 'package:stemxploref2/stem_info/stem_detail_page.dart';
import 'package:stemxploref2/stem_highlights/highlight.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  dynamic selectedHighlight;
  dynamic selectedStemInfo;
  String selectedSubjectName = "Science";
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
      _lastIndexBeforeDetail = 5;
    });
    Provider.of<NavigationProvider>(context, listen: false).setIndex(13);
  }

  // When coming from Favorites
  void onFavoriteChapterSelected(Map<String, dynamic> chapterData) {
    setState(() {
      selectedChapterData = chapterData;
      _lastIndexBeforeDetail = 1;
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

  void updateSubjectState(String newSubject) {
    selectedSubjectName = newSubject;
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    final int activeNavIconIndex = (navProvider.currentIndex > 3)
        ? 0
        : navProvider.currentIndex;

    final List<Widget> pages = [
      HomePage(
        onHighlightTap: (Highlight h) {
          setState(() => selectedHighlight = h);
          Provider.of<NavigationProvider>(context, listen: false).setIndex(10);
          return Future.value();
        },
      ), // 0
      BookmarkPage(
        onChapterTap: (chapterData) {
          setState(() {
            selectedChapterData = chapterData;
            _lastIndexBeforeDetail = 1;
          });
          navProvider.setIndex(13); // Navigate to Details
        },
      ),
      const InfoPage(), // 2
      const SettingsPage(), // 3
      StemInfoPage(onSelect: onStemSelect), // 4
      SubjectChaptersPage(
        key: navProvider.currentIndex == 5
            ? const ValueKey('learning_active')
            : UniqueKey(),
        initialSubject: selectedSubjectName,
        onChapterTap: onChapterSelected,
      ), // 5
      QuizGamePage(
        key: navProvider.currentIndex == 6
            ? const ValueKey('quiz_menu')
            : UniqueKey(),
        initialSubject: selectedQuizCategory,
        onQuizStart: (quizData, mode) {
          final String subjectId = quizData.split('|')[0].trim();

          setState(() {
            if (subjectId == "1" || subjectId == "Science") {
              selectedQuizCategory = "Science";
            } else if (subjectId == "2" || subjectId == "Mathematics") {
              selectedQuizCategory = "Mathematics";
            } else if (subjectId == "3" ||
                subjectId == "ASK" ||
                subjectId == "Computer Science") {
              selectedQuizCategory = "Computer Science";
            } else if (subjectId == "4" ||
                subjectId == "RBT" ||
                subjectId == "Design And Technology") {
              selectedQuizCategory = "Design And Technology";
            }
          });

          onQuizSubjectSelected(quizData);
        },
      ), // 6

      const StemCareersPage(), // 7
      const DailyInfoPage(), // 8
      // 9
      FaqPage(
        key: navProvider.currentIndex == 9
            ? const ValueKey('faq_active')
            : UniqueKey(),
      ), // 9

      selectedHighlight != null
          ? HighlightDetailPage(highlight: selectedHighlight)
          : const SizedBox.shrink(), // 10

      selectedStemInfo != null
          ? StemDetailPage(
              key: ValueKey(selectedStemInfo['title_en'] ?? 'stem_detail'),
              stemInfo: selectedStemInfo,
            )
          : const SizedBox.shrink(), // 11

      const SizedBox.shrink(), // 12

      selectedChapterData != null
          ? MaterialDetailPage(chapterData: selectedChapterData!)
          : const SizedBox.shrink(), // 13
      selectedQuizData != null
          ? PlayQuizPage(
              key: ValueKey(selectedQuizData),
              subjectAndMode: selectedQuizData!,
              onFinish: () {
                setState(() => selectedQuizData = null);
                navProvider.setIndex(6);
              },
            )
          : const SizedBox.shrink(), // 14
    ];

    return PopScope(
      canPop: navProvider.currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (navProvider.currentIndex == 14) {
          setState(() => selectedQuizData = null);
          navProvider.setIndex(6); // Back to Quiz List from the Game
        } else if (navProvider.currentIndex == 13) {
          navProvider.setIndex(_lastIndexBeforeDetail);
        } else if (navProvider.currentIndex == 5 ||
            navProvider.currentIndex == 6) {
          navProvider.setIndex(0);
        } else if (navProvider.currentIndex == 10 ||
            navProvider.currentIndex == 11) {
          navProvider.setIndex(navProvider.currentIndex == 10 ? 0 : 4);
        } else {
          navProvider.setIndex(0);
        }
      },
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: AppCurvedNavBar(
          currentIndex: activeNavIconIndex,
          onTap: (index) {
            if (index == 5) {
              setState(() {
                selectedSubjectName = "Science"; // Reset to Science
              });
            }

            // Clear quiz if switching tabs
            if (selectedQuizData != null) {
              setState(() => selectedQuizData = null);
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
