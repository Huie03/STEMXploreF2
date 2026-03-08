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

  void _scroll(double offset) {
    if (controller.hasClients) {
      controller.animateTo(
        (controller.offset + offset).clamp(
          0.0,
          controller.position.maxScrollExtent,
        ),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    const double barWidth = 12.0;

    final Color thumbColor = isDark ? Colors.white38 : Colors.black45;
    final Color trackColor = isDark ? Colors.white10 : Colors.black12;

    return Stack(
      children: [
        RawScrollbar(
          controller: controller,
          thumbVisibility: true,
          trackVisibility: true,
          thickness: barWidth,
          thumbColor: thumbColor,
          trackColor: trackColor,
          radius: const Radius.circular(10),
          child: child,
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: barWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ArrowButton(
                icon: Icons.arrow_drop_up,
                onTap: () => _scroll(-150),
                width: barWidth,
                isDark: isDark,
              ),
              _ArrowButton(
                icon: Icons.arrow_drop_down,
                onTap: () => _scroll(150),
                width: barWidth,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double width;
  final bool isDark;

  const _ArrowButton({
    required this.icon,
    required this.onTap,
    required this.width,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isDark
        ? const Color(0xFF3D3D3D)
        : const Color.fromARGB(187, 255, 255, 255);
    final Color iconColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 60,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.all(Radius.circular(4)),
          border: isDark ? Border.all(color: Colors.white10) : null,
        ),

        child: Center(
          child: OverflowBox(
            maxWidth: 40,
            maxHeight: 40,
            child: Icon(icon, size: 32, color: iconColor),
          ),
        ),
      ),
    );
  }
}
