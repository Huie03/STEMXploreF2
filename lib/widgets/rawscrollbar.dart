import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/theme_provider.dart';

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

    const double barWidth = 10.0;

    final Color thumbColor = isDark
        ? Colors.white.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.5);

    return RawScrollbar(
      controller: controller,
      padding: EdgeInsets.zero,

      thumbVisibility: false,
      trackVisibility: false,

      thickness: barWidth,
      thumbColor: thumbColor,

      radius: const Radius.circular(5),

      minThumbLength: 40.0,

      // Controls the fade speed
      fadeDuration: const Duration(milliseconds: 300),
      timeToFade: const Duration(milliseconds: 600),

      child: child,
    );
  }
}
