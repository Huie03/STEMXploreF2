import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navigation_provider.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'box_shadow.dart';

class LanguageToggle extends StatelessWidget {
  final VoidCallback? onLanguageChanged;

  const LanguageToggle({super.key, this.onLanguageChanged});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final bool isDark = themeProvider.isDarkMode;
    final bool isEnglish = navProvider.locale.languageCode == 'en';

    final Color borderColor = isDark ? Colors.white : Colors.black;
    final Color circleBgColor = isDark ? Colors.grey[800]! : Colors.white;
    // Set text color based on theme
    final Color textColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: () {
        final Locale nextLocale = isEnglish
            ? const Locale('ms')
            : const Locale('en');
        navProvider.setLocale(nextLocale);

        if (onLanguageChanged != null) {
          onLanguageChanged!();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize
              .min, // Prevents column from taking full screen height
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleBgColor,
                border: Border.all(color: borderColor, width: 1.2),
                boxShadow: appBoxShadow,
              ),
              child: ClipOval(
                child: Image.asset(
                  key: ValueKey<String>(isEnglish ? 'en' : 'ms'),
                  isEnglish
                      ? 'assets/flag/language ms_flag.png'
                      : 'assets/flag/language uk_flag.png',
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 4), // Space between flag and text
            Text(
              isEnglish
                  ? 'MY'
                  : 'EN', // Logic: if current is EN, show MY (next option)
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
