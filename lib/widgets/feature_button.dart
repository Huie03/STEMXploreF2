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

    final Size screenSize = MediaQuery.of(context).size;
    final double shortestSide = screenSize.shortestSide;
    final double screenHeight = screenSize.height;

    final bool isTablet = shortestSide >= 600;
    final bool isSmallPhone = screenHeight < 700;

    final Color buttonColor = const Color(0xFFEB9000);
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return LayoutBuilder(
      builder: (context, constraints) {
        double availableHeight = constraints.maxHeight;

        double imageMultiplier = isTablet ? 0.63 : 0.60;
        double imageSize = availableHeight * imageMultiplier;

        double dynamicFontSize;
        if (isTablet) {
          dynamicFontSize = 20.0;
        } else if (isSmallPhone) {
          dynamicFontSize = 14.0;
        } else {
          dynamicFontSize = 17.0;
        }

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
                  SizedBox(height: isSmallPhone ? 2 : 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: dynamicFontSize,
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
