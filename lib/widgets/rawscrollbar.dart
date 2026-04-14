import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stemxploref2/theme_provider.dart';

class AppRawScrollbar extends StatelessWidget {
  final ScrollController controller;
  final Widget child;

  const AppRawScrollbar({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    // A thin width (4.0 to 6.0) looks best for the edge-style scrollbar
    const double barWidth = 10.0;

    // Using a darker, semi-transparent color as seen in your screenshot
    final Color thumbColor = isDark
        ? Colors.white.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.5);

    return RawScrollbar(
      controller: controller,
      // 1. Set padding to zero to make it touch the screen edge
      padding: EdgeInsets.zero,

      // 2. This makes it appear only while scrolling
      thumbVisibility: false,
      trackVisibility: false,

      thickness: barWidth,
      thumbColor: thumbColor,

      // 3. Keep a small radius for a modern look, or set to zero for a square edge
      radius: const Radius.circular(5),

      minThumbLength: 40.0,

      // Controls the fade speed
      fadeDuration: const Duration(milliseconds: 300),
      timeToFade: const Duration(milliseconds: 600),

      child: child,
    );
  }
}
