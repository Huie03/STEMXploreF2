import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/box_shadow.dart';
import 'package:stemxploref2/theme_provider.dart';

class StemQuizDesign {
  static const double cardRadius = 35.0;

  static Widget buildContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    final bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Container(
      margin:
          margin ??
          const EdgeInsets.only(top: 2, left: 20, right: 20, bottom: 30),
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF3D3D3D)
            : const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: isDark ? [] : appBoxShadow,
        border: isDark ? Border.all(color: Colors.white10, width: 1) : null,
      ),
      child: child,
    );
  }

  static Widget actionButton(
    BuildContext context,
    String label,
    VoidCallback? onTap,
  ) {
    final bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    bool isEnabled = onTap != null;

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled
            ? (isDark ? const Color(0xFFEB9000) : const Color(0xFFEB9000))
            : (isDark ? Colors.grey.shade800 : Colors.grey.shade400),
        foregroundColor: isDark ? Colors.black : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  static Widget careerExpandableTile(
    BuildContext context,
    String title,
    bool isExpanded,
    VoidCallback onTap,
  ) {
    final bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? const Color.fromARGB(255, 76, 75, 75)
              : const Color(0xFFEBEBEB),
          borderRadius: BorderRadius.circular(12),
          border: isDark ? Border.all(color: Colors.white10) : null,
          boxShadow: isDark ? [] : appBoxShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 26,
              color: isDark
                  ? const Color.fromARGB(179, 255, 255, 255)
                  : Colors.black87,
            ),
          ],
        ),
      ),
    );
  }
}
