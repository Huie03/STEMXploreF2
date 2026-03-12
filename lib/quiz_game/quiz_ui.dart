import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class QuizUi {
  static Widget buildAppBar({
    required String title,
    required Widget languageToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black,
            ),
          ),
          languageToggle,
        ],
      ),
    );
  }

  static Widget buildProgressHeader({
    required String subject,
    required String difficulty,
    required double progress,
    required String counterText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$subject • $difficulty",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.black12,
                  color: Colors.green,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                counterText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildQuestionCard({
    required List<BoxShadow> boxShadow,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }

  static Widget buildOptionTile({
    required int index,
    required String text,
    required int correctIndex,
    required int? selectedIndex,
    required bool showFeedback,
    required VoidCallback onTap,
  }) {
    Color borderColor = Colors.black.withValues(alpha: 0.08);
    Color bgColor = Colors.transparent;

    if (showFeedback) {
      if (index == correctIndex) {
        borderColor = Colors.green;
        bgColor = Colors.green.withValues(alpha: 0.1);
      } else if (index == selectedIndex) {
        borderColor = Colors.red;
        bgColor = Colors.red.withValues(alpha: 0.1);
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: InkWell(
          onTap: showFeedback ? null : onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.orange.withValues(alpha: 0.15),
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (showFeedback && index == correctIndex)
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                if (showFeedback &&
                    index == selectedIndex &&
                    index != correctIndex)
                  const Icon(Icons.cancel, color: Colors.red, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildResultsDialog({
    required BuildContext context,
    required int score,
    required int total,
    required bool isEnglish,
    required ConfettiController confettiController,
    required VoidCallback onReplay,
    required VoidCallback onReview,
  }) {
    final bool isPerfect = score == total;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Column(
            children: [
              Icon(
                isPerfect ? Icons.stars : Icons.emoji_events,
                color: Colors.orange,
                size: 50,
              ),
              const SizedBox(height: 10),
              Text(
                isPerfect
                    ? (isEnglish ? "Outstanding!" : "Luar Biasa!")
                    : (isEnglish ? "Quiz Finished!" : "Kuiz Selesai!"),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEnglish ? "Your Score" : "Markah Anda",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "$score / $total",
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 30),
              _buildDialogBtn(
                isEnglish ? "REPLAY" : "MAIN SEMULA",
                Icons.replay,
                Colors.blue,
                onReplay,
                false,
              ),
              const SizedBox(height: 12),
              _buildDialogBtn(
                isEnglish ? "REVIEW ANSWERS" : "SEMAK JAWAPAN",
                Icons.visibility,
                Colors.orange,
                onReview,
                true,
              ),
            ],
          ),
        ),
        ConfettiWidget(
          confettiController: confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple,
            Colors.yellow,
          ],
          gravity: 0.2,
          numberOfParticles: 20,
        ),
      ],
    );
  }

  static Widget _buildDialogBtn(
    String label,
    IconData icon,
    Color color,
    VoidCallback pressed,
    bool outlined,
  ) {
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton.icon(
              icon: Icon(icon, color: color),
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
              icon: Icon(icon, color: Colors.white),
              label: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: pressed,
            ),
    );
  }
}
