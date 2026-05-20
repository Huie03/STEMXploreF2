import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:stemxploref2/widgets/box_shadow.dart';

class QuizUi {
  static Widget buildAppBar({
    required BuildContext context,
    required String title,
    required Widget languageToggle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: colorScheme.onSurface,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
          languageToggle,
        ],
      ),
    );
  }

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
        ? Colors.white.withValues(alpha: 0.5)
        : Theme.of(context).colorScheme.outlineVariant;
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
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildResultsView({
    required BuildContext context,
    required int score,
    required int total,
    required bool isEnglish,
    required ConfettiController confettiController,
    required VoidCallback onReplay,
    required VoidCallback onReview,
    required VoidCallback onExit,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final adaptiveGold = isDark
        ? Colors.orange.shade300
        : const Color(0xFFEB9000);
    final bool isPerfect = score == total;
    final bool shouldCelebrate = total > 0 && (score / total) >= 0.7;

    return Container(
      color: Colors.transparent,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: appBoxShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPerfect ? Icons.stars : Icons.emoji_events,
                      color: const Color(0xFFEB9000),
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPerfect
                          ? (isEnglish ? "Outstanding!" : "Luar Biasa!")
                          : (isEnglish ? "Quiz Completed!" : "Kuiz Selesai!"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isEnglish ? "Your Score" : "Markah Anda",
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$score / $total",
                      style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w900,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildDialogBtn(
                      label: isEnglish ? "RETRY" : "CUBA SEMULA",
                      icon: Icons.replay,
                      color: adaptiveGold,
                      pressed: onReplay,
                      outlined: true,
                    ),
                    const SizedBox(height: 12),
                    _buildDialogBtn(
                      label: isEnglish ? "REVIEW ANSWERS" : "SEMAK JAWAPAN",
                      icon: Icons.visibility,
                      color: adaptiveGold,
                      pressed: onReview,
                      outlined: true,
                    ),
                    const SizedBox(height: 12),
                    _buildDialogBtn(
                      label: isEnglish ? "EXIT" : "KELUAR",
                      icon: Icons.exit_to_app,
                      color: adaptiveGold,
                      pressed: onExit,
                      outlined: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (shouldCelebrate)
            ConfettiWidget(
              confettiController: confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.orange,
                Colors.pink,
                Colors.purple,
              ],
              gravity: 0.25,
              numberOfParticles: 20,
            ),
        ],
      ),
    );
  }

  static Widget _buildDialogBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback pressed,
    required bool outlined,
  }) {
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton.icon(
              icon: Icon(icon, color: color, size: 20),
              label: Text(
                label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: pressed,
            )
          : ElevatedButton.icon(
              icon: Icon(icon, color: Colors.white, size: 20),
              label: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: pressed,
            ),
    );
  }

  static Widget buildQuestionCard({
    required BuildContext context,
    required Widget child,
    List<BoxShadow>? boxShadow,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: boxShadow,
      ),
      padding: padding ?? const EdgeInsets.fromLTRB(30, 13, 30, 16),
      child: child,
    );
  }

  static Widget buildReviewCard({
    required BuildContext context,
    required int index,
    required String question,
    String? questionImageUrl,
    required Widget optionsWidget,
    required String userAnswer,
    required String correctAnswer,
    required String? explanation,
    required bool isCorrect,
    required bool isEnglish,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(25),
        boxShadow: isDark ? [] : appBoxShadow,
        border: isDark ? Border.all(color: colorScheme.outlineVariant) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  "Q${index + 1}. $question",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: isCorrect ? Colors.green : Colors.redAccent,
              ),
            ],
          ),
          if (questionImageUrl != null && questionImageUrl.isNotEmpty) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                questionImageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
          ],
          const SizedBox(height: 5),
          optionsWidget,
          const SizedBox(height: 10),
          Text(
            "${isEnglish ? "Your answer" : "Jawapan anda"}: $userAnswer",
            style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
          ),
          Text(
            "${isEnglish ? "Correct answer" : "Jawapan betul"}: $correctAnswer",
            style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
          ),
          if (explanation != null && explanation.trim().isNotEmpty) ...[
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // ADAPTIVE EXPLANATION BOX
                color: isDark ? colorScheme.surface : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.orange.shade200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEnglish ? "Explanation:" : "Penerangan:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    explanation,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
