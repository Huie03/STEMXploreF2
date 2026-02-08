import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/navigation_provider.dart';
import '/widgets/curved_navigation_bar.dart';

// Page Imports
import 'home_page.dart';
import '../favorite/favorite_page.dart';
import 'info_page.dart';
import 'settings_page.dart';
import '/stem_info/stem_info_page.dart';
import '/learning_materials/learning_materials_page.dart';
import '/quiz_game/quiz_game_page.dart';
import '/pages/stem_careers_page.dart';
import '../daily_info/daily_info_page.dart';
import '/pages/faq_page.dart';
import '/stem_highlights/highlight_detail_page.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main';
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  dynamic selectedHighlight;

  void onHighlightSelected(dynamic highlight) {
    setState(() {
      selectedHighlight = highlight;
    });
    Provider.of<NavigationProvider>(context, listen: false).setIndex(10);
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    final List<Widget> pages = [
      HomePage(onHighlightTap: onHighlightSelected), // 0
      const FavoritePage(), // 1
      const InfoPage(), // 2
      const SettingsPage(), // 3
      const StemInfoPage(), // 4
      const LearningMaterialPage(), // 5
      const QuizGamePage(), // 6
      const StemCareersPage(), // 7
      const DailyInfoPage(), // 8
      const FaqPage(), // 9

      selectedHighlight != null
          ? HighlightDetailPage(highlight: selectedHighlight)
          : const SizedBox(), // 10
    ];

    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      // The navigation bar stays here, so it's always visible
      bottomNavigationBar: AppCurvedNavBar(
        currentIndex: (navProvider.currentIndex > 3)
            ? 0
            : navProvider.currentIndex,
        onTap: (index) {
          navProvider.setIndex(index);
        },
      ),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: navProvider.currentIndex, children: pages),
      ),
    );
  }
}
