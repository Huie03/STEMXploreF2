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
                        fontSize: 20,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEnglish ? "Your Score" : "Markah Anda",
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$score / $total",
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
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
}
