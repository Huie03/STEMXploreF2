import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stemxploref2/theme_provider.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.50, 1.0],
          colors: isDark
              ? [
                  const Color.fromARGB(0, 18, 18, 18),
                  const Color.fromARGB(0, 18, 18, 18),
                ]
              : [const Color(0xFFFFD38F), const Color(0xFFFFFFFF)],
        ),
      ),
      child: child,
    );
  }
}
