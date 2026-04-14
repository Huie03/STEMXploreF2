import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class QuizUi {
  /// Standard App Bar for Quiz
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
        crossAxisAlignment: CrossAxisAlignment
            .center, // Keeps flag centered with the first line or middle
        children: [
          // 1. Wrap the title in Expanded so it wraps text instead of pushing the flag
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: colorScheme.onSurface,
              ),
              softWrap: true, // Allows wrapping
              overflow:
                  TextOverflow.visible, // Ensures text isn't cut off with "..."
            ),
          ),

          //const SizedBox(width: 3), // Add a small gap between text and flag
          // 2. The flag/toggle stays on the right
          languageToggle,
        ],
      ),
    );
  }

  /// Updated Option Tile: White box, Green/Red solid feedback, colored icons for images
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

    // 1. Get the surface color from the current theme (white in light, dark grey in dark)
    final Color themeSurface = Theme.of(context).colorScheme.surface;

    // 2. Default to theme surface, then apply feedback colors
    Color backgroundColor = themeSurface;

    if (showFeedback) {
      if (isCorrect) {
        backgroundColor = const Color.fromARGB(243, 12, 206, 18); // Solid Green
      } else if (isWrong) {
        backgroundColor = const Color.fromARGB(255, 255, 0, 0); // Solid Red
      }
    }

    // If feedback is shown, text is white. Otherwise, use theme's onSurface.
    Color contentColor = (showFeedback && (isCorrect || isWrong))
        ? Colors.white
        : Theme.of(context).colorScheme.onSurface;

    // Icon logic with specific colors
    Widget? feedbackIcon;
    if (showFeedback && (isCorrect || isWrong)) {
      feedbackIcon = Icon(
        isCorrect ? Icons.check_circle : Icons.cancel,
        // Using distinct colors for the icon itself
        color: isCorrect
            ? Color.fromARGB(243, 12, 206, 18)
            : Color.fromARGB(255, 255, 0, 0),
        size: imageUrl != null ? 30 : 24,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: imageUrl == null
          ? const EdgeInsets.symmetric(vertical: 6)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: showFeedback ? null : onTap,
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(imageUrl != null ? 8.0 : 16.0),
              child: imageUrl != null
                  ? _buildImageLayout(imageUrl, text, contentColor)
                  : _buildTextLayout(text, feedbackIcon, contentColor),
            ),

            // For Image Options: Feedback icon with a white circular background for visibility
            if (imageUrl != null && feedbackIcon != null)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
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
              color:
                  textColor, // Switches to white when background is green/red
            ),
          ),
        ),
        if (icon != null) icon,
      ],
    );
  }

  // Updated Image Layout to accept the dynamic text color
  static Widget _buildImageLayout(String url, String text, Color textColor) {
    // Check if there is valid text to display
    final bool hasText = text.trim().isNotEmpty;

    Widget imageWidget = Image.network(
      url,
      // CHANGE: Use BoxFit.contain to see the full image without cropping
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity, // Ensures it tries to fill the available space
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );

    // If there is no text, let the image take 100% of the space
    if (!hasText) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: imageWidget,
      );
    }

    // If there is text, use the split layout (75% image, 25% text)
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              color: Colors
                  .grey[50], // Light background helps 'contain' look cleaner
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
                fontSize: 16, // Slightly smaller to ensure fit
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
  }) {
    final bool isPerfect = score == total;
    final bool shouldCelebrate = score >= 7;

    return Container(
      // CHANGE THIS LINE: Set color to transparent
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
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
                          : (isEnglish ? "Quiz Finished!" : "Kuiz Selesai!"),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isEnglish ? "Your Score" : "Markah Anda",
                      style: TextStyle(color: Colors.grey[600], fontSize: 18),
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
                      label: isEnglish ? "REPLAY" : "MAIN SEMULA",
                      icon: Icons.replay,
                      color: const Color(0xFFEB9000),
                      pressed: onReplay,
                      outlined: false,
                    ),
                    const SizedBox(height: 12),
                    _buildDialogBtn(
                      label: isEnglish ? "REVIEW ANSWERS" : "SEMAK JAWAPAN",
                      icon: Icons.visibility,
                      color: const Color(0xFFEB9000),
                      pressed: onReview,
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

  /// Private helper for dialog buttons
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
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}
