import 'package:flutter/material.dart';
import '../widgets/box_shadow.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:provider/provider.dart';

class FeatureButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final String imageAsset;

  const FeatureButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.imageAsset,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    final Color buttonColor = isDark
        ? const Color(0xFFEB9000)
        : const Color(0xFFEB9000);
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return LayoutBuilder(
      builder: (context, constraints) {
        double availableHeight = constraints.maxHeight;
        double imageSize = availableHeight * 0.60;

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark ? [] : appBoxShadow,
            border: isDark ? Border.all(color: Colors.white10, width: 1) : null,
          ),
          child: Material(
            color: buttonColor,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    imageAsset,
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
