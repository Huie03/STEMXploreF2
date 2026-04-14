// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; //App in portrait, no rotate to landscape
import 'package:provider/provider.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'l10n/languages.dart';
import '/navigation_provider.dart';
import 'pages/main_screen.dart';
import 'pages/splash_page.dart';
//import 'pages/home_page.dart';
//import 'stem_info/stem_info_page.dart';
//import 'learning_materials/learning_materials_page.dart';
//import 'quiz_game/quiz_game_page.dart';
import '/stem_career/stem_careers_page.dart';
import 'daily_info/daily_info_page.dart';
import 'pages/faq_page.dart';
//import 'favorite/favorite_page.dart';
import 'pages/info_page.dart';
import 'pages/settings_page.dart';
import 'stem_highlights/highlight.dart';
import 'stem_highlights/highlight_detail_page.dart';
import 'favorite/favorite_provider.dart';
import 'package:stemxploref2/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Lock the orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final FlutterLocalization localization = FlutterLocalization.instance;
  await localization.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
    localization.init(mapLocales: LOCALES, initLanguageCode: 'en');

    localization.onTranslatedLanguage = (Locale? locale) {
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      locale: localization.currentLocale,
      supportedLocales: localization.supportedLocales,
      localizationsDelegates: localization.localizationsDelegates,

      debugShowCheckedModeBanner: false,

      // THEME SETTINGS
      theme: ThemeProvider.lightTheme,
      darkTheme: ThemeProvider.darkTheme,
      themeMode: themeProvider.themeMode,

      initialRoute: SplashPage.routeName,
      routes: {
        SplashPage.routeName: (_) => const SplashPage(),
        MainScreen.routeName: (_) => MainScreen(),
        //HomePage.routeName: (_) => const HomePage(),
        //StemInfoPage.routeName: (_) => const StemInfoPage(),
        //LearningMaterialPage.routeName: (_) => const LearningMaterialPage(),
        //QuizGamePage.routeName: (_) => const QuizGamePage(),
        StemCareersPage.routeName: (_) => const StemCareersPage(),
        DailyInfoPage.routeName: (_) => const DailyInfoPage(),
        FaqPage.routeName: (_) => const FaqPage(),
        //FavoritePage.routeName: (_) => const FavoritePage(),
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
