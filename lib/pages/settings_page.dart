import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:stemxploref2/widgets/gradient_background.dart';
import 'package:stemxploref2/widgets/language_toggle.dart';
import '../widgets/box_shadow.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/settings';
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FlutterLocalization localization = FlutterLocalization.instance;
  final Color allIconColor = const Color(0xFFEB9000);

  @override
  void initState() {
    super.initState();
    localization.onTranslatedLanguage = (locale) {
      if (mounted) setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;
    final bool isEnglish = localization.currentLocale?.languageCode == 'en';

    final String title = isEnglish ? 'Settings' : 'Tetapan';
    final Color cardBg = Theme.of(context).colorScheme.surface;
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomAppBar(title, isEnglish, textColor),
              const SizedBox(height: 20),

              _buildSettingsCard(
                cardBg: cardBg,
                icon: isDark ? Icons.dark_mode : Icons.light_mode,
                iconColor: isDark ? allIconColor : Colors.black,
                title: isEnglish ? "Theme Mode" : "Mod Tema",
                subtitle: isEnglish
                    ? (isDark ? "Dark Mode" : "Light Mode")
                    : (isDark ? "Mod Gelap" : "Mod Terang"),
                textColor: textColor,
                isDark: isDark,
                trailing: Switch(
                  value: isDark,
                  activeThumbColor: allIconColor,
                  onChanged: (value) => themeProvider.toggleTheme(),
                ),
              ),

              const SizedBox(height: 20), // Spacing between cards

              _buildSettingsCard(
                cardBg: cardBg,
                icon: themeProvider.isSoundEnabled
                    ? Icons.volume_up
                    : Icons.volume_off,
                iconColor: allIconColor,
                title: isEnglish ? "Sound" : "Suara",

                subtitle: isEnglish
                    ? (themeProvider.isSoundEnabled ? "On" : "Off")
                    : (themeProvider.isSoundEnabled ? "Buka" : "Tutup"),

                textColor: textColor,
                isDark: isDark,
                trailing: Switch(
                  value: themeProvider.isSoundEnabled,
                  activeThumbColor: allIconColor,
                  onChanged: (value) {
                    themeProvider.toggleSound(value);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required Color cardBg,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Color textColor,
    required bool isDark,
    required Widget trailing,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: appBoxShadow,
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        ),
        trailing: trailing,
      ),
    );
  }

  Widget _buildCustomAppBar(String title, bool isEnglish, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
}
