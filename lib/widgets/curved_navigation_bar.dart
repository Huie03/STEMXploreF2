import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import '/theme_provider.dart';

class AppCurvedNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppCurvedNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    final Color iconColor = isDark ? Colors.black : Colors.black;
    final Color navBarColor = isDark
        ? const Color(0xFFEB9000)
        : const Color(0xFFEB9000);
    final Color backgroundColor = isDark
        ? const Color.fromARGB(0, 18, 18, 18)
        : const Color.fromARGB(255, 255, 255, 255);

    return CurvedNavigationBar(
      index: currentIndex,
      height: 60,
      backgroundColor: backgroundColor,
      color: navBarColor,
      buttonBackgroundColor: navBarColor,
      animationDuration: const Duration(milliseconds: 300),
      items: [
        Icon(Icons.home, size: 30, color: iconColor),
        Icon(Icons.bookmark_border, size: 30, color: iconColor),

        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,

            border: Border.all(color: iconColor, width: 2.5),
          ),
          alignment: Alignment.center,
          child: Text(
            'i',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              fontFamily: 'serif',

              color: iconColor,
            ),
          ),
        ),

        Icon(Icons.settings, size: 30, color: iconColor),
      ],
      onTap: onTap,
    );
  }
}
