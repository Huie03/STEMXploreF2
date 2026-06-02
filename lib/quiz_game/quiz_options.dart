import 'package:flutter/material.dart';
import 'package:stemxploref2/widgets/box_shadow.dart';

class QuizOptions {
  static Widget buildOptionTile({
    required BuildContext context,
    required int index,
    required String text,
    String? imageUrl,
    required int correctIndex,
    int? selectedIndex,
    required bool showFeedback,
    required VoidCallback onTap,
  }) {
    final bool isCorrect = index == correctIndex;
    final bool isWrong = index == selectedIndex && index != correctIndex;

    final Color themeSurface = Theme.of(context).colorScheme.surface;
    Color backgroundColor = themeSurface;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2);
    double borderWidth = 1.0;

    if (showFeedback) {
      if (isCorrect) {
        backgroundColor = const Color.fromARGB(243, 12, 206, 18);
      } else if (isWrong) {
        backgroundColor = const Color.fromARGB(255, 255, 0, 0);
      }
    }

    Color contentColor = (showFeedback && (isCorrect || isWrong))
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    Widget? feedbackIcon;
    if (showFeedback && (isCorrect || isWrong)) {
      feedbackIcon = Icon(
        isCorrect ? Icons.check_circle : Icons.cancel,
        color: isCorrect
            ? const Color.fromARGB(243, 12, 206, 18)
            : const Color.fromARGB(255, 255, 0, 0),
        size: imageUrl != null ? 30 : 24,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: imageUrl == null || imageUrl.isEmpty
          ? const EdgeInsets.symmetric(vertical: 6)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: showFeedback ? [] : appBoxShadow,
      ),
      child: InkWell(
        onTap: showFeedback ? null : onTap,
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(
                imageUrl != null && imageUrl.isNotEmpty ? 8.0 : 16.0,
              ),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? _buildImageLayout(imageUrl, text, contentColor)
                  : _buildTextLayout(text, feedbackIcon, contentColor),
            ),
            if (imageUrl != null && imageUrl.isNotEmpty && feedbackIcon != null)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: appBoxShadow,
                  ),
                  child: feedbackIcon,
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Widget _buildTextLayout(String text, Widget? icon, Color textColor) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        if (icon != null) icon,
      ],
    );
  }

  static Widget _buildImageLayout(String path, String text, Color textColor) {
    final bool hasText = text.trim().isNotEmpty;

    Widget imageWidget = Image.asset(
      path,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) =>
          const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
    );

    if (!hasText) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: imageWidget,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              color: Colors.grey[50],
              child: imageWidget,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
