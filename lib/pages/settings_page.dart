import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:stemxploref2/widgets/gradient_background.dart';
import '/widgets/language_toggle.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/settings';
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FlutterLocalization localization = FlutterLocalization.instance;
  bool _isDarkMode = false; // Local state for the theme toggle

  @override
  void initState() {
    super.initState();
    // Add this listener
    FlutterLocalization.instance.onTranslatedLanguage = _onLanguageChanged;
  }

  // This function will be called whenever translate() is called anywhere in the app
  void _onLanguageChanged(Locale? locale) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sync with the global language state
    final bool isEnglish = localization.currentLocale?.languageCode == 'en';
    final String title = isEnglish ? 'Settings' : 'Tetapan';

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Consistent AppBar and Flag Toggle
              _buildCustomAppBar(title, isEnglish),

              const SizedBox(height: 20),

              // 2. Theme Mode Toggle (Replaces Language)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Icon(
                    _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: Colors.black,
                  ),
                  title: Text(
                    isEnglish ? "Theme Mode" : "Mod Tema",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    isEnglish
                        ? (_isDarkMode ? "Dark Mode" : "Light Mode")
                        : (_isDarkMode ? "Mod Gelap" : "Mod Terang"),
                  ),
                  trailing: Switch(
                    value: _isDarkMode,
                    activeColor: Colors.orange,
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value;
                        // Add your theme switching logic here if you have a ThemeProvider
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Optional: Add more settings items here
            ],
          ),
        ),
      ),
    );
  }

  // Consistent AppBar Logic used in FAQ and Bookmark pages
  Widget _buildCustomAppBar(String title, bool isEnglish) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.black,
              ),
            ),
          ),
          LanguageToggle(
            onLanguageChanged: () {
              setState(
                () {},
              ); // This forces InfoPage to update its text strings
            },
          ),
        ],
      ),
    );
  }
}
