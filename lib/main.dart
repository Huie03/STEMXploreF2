// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'l10n/languages.dart';
import '/navigation_provider.dart';
import 'pages/main_screen.dart';
import 'pages/splash_page.dart';
import 'pages/home_page.dart';
import 'stem_info/stem_info_page.dart';
import 'learning_materials/learning_materials_page.dart';
import 'quiz_game/quiz_game_page.dart';
import 'pages/stem_careers_page.dart';
import 'daily_info/daily_info_page.dart';
import 'pages/faq_page.dart';
import 'favorite/favorite_page.dart';
import 'pages/info_page.dart';
import 'pages/settings_page.dart';
import 'stem_highlights/highlight.dart';
import 'stem_highlights/highlight_detail_page.dart';
import 'favorite/favorite_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FlutterLocalization localization = FlutterLocalization.instance;
  await localization.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ],
      child: const STEMXploreApp(),
    ),
  );
}

class STEMXploreApp extends StatefulWidget {
  const STEMXploreApp({super.key});

  @override
  State<STEMXploreApp> createState() => _STEMXploreAppState();
}

class _STEMXploreAppState extends State<STEMXploreApp> {
  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  void initState() {
    super.initState();
    // 1. Initialize the localization
    localization.init(mapLocales: LOCALES, initLanguageCode: 'en');

    // 2. The critical listener: This tells the Root App to rebuild
    // whenever the language is changed from ANY page (including Bookmark).
    localization.onTranslatedLanguage = (Locale? locale) {
      if (mounted) {
        setState(() {});
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 3. Explicitly set the locale so the UI knows it must refresh
      locale: localization.currentLocale,
      supportedLocales: localization.supportedLocales,
      localizationsDelegates: localization.localizationsDelegates,

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEFA638),
          primary: const Color(0xFFEFA638),
        ),
        scaffoldBackgroundColor: const Color(0xFFEFA638),

        // ADD THIS SECTION TO REMOVE THE ICON BACKGROUND
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor:
              Colors.transparent, // This removes the peach "pill" background
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      initialRoute: SplashPage.routeName,
      routes: {
        SplashPage.routeName: (_) => const SplashPage(),
        MainScreen.routeName: (_) => MainScreen(),
        //HomePage.routeName: (_) => const HomePage(),
        StemInfoPage.routeName: (_) => const StemInfoPage(),
        LearningMaterialPage.routeName: (_) => const LearningMaterialPage(),
        QuizGamePage.routeName: (_) => const QuizGamePage(),
        StemCareersPage.routeName: (_) => const StemCareersPage(),
        DailyInfoPage.routeName: (_) => const DailyInfoPage(),
        FaqPage.routeName: (_) => const FaqPage(),
        FavoritePage.routeName: (_) => const FavoritePage(),
        InfoPage.routeName: (_) => const InfoPage(),
        SettingsPage.routeName: (_) => SettingsPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == HighlightDetailPage.routeName) {
          final args = settings.arguments as Highlight;
          return MaterialPageRoute(
            builder: (context) => HighlightDetailPage(highlight: args),
          );
        }
        return null;
      },
    );
  }
}
