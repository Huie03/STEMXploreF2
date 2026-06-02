import 'package:flutter/material.dart';
import 'package:stemxploref2/widgets/box_shadow.dart';
import 'package:stemxploref2/quiz_game/quiz_options.dart';
import 'package:stemxploref2/widgets/rawscrollbar.dart';

class QuizReviewAnswer {
  static Widget buildReviewList({
    required BuildContext context,
    required List<dynamic> questions,
    required int score,
    required ScrollController scrollController,
    required bool isEnglish,
    required Widget exitButton,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 0, 20, 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${isEnglish ? "Score" : "Markah"}: $score/${questions.length}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: AppRawScrollbar(
            controller: scrollController,
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                final int correctIdx = "ABCD".indexOf(
                  q['correct_option'] ?? "A",
                );
                final int userIdx = q['user_choice'] ?? -1;

                final List<Map<String, String>> opts = [
                  {
                    't': isEnglish ? q['opt_a_en'] : q['opt_a_ms'],
                    'img': q['opt_a_image'] ?? "",
                  },
                  {
                    't': isEnglish ? q['opt_b_en'] : q['opt_b_ms'],
                    'img': q['opt_b_image'] ?? "",
                  },
                  {
                    't': isEnglish ? q['opt_c_en'] : q['opt_c_ms'],
                    'img': q['opt_c_image'] ?? "",
                  },
                  {
                    't': isEnglish ? q['opt_d_en'] : q['opt_d_ms'],
                    'img': q['opt_d_image'] ?? "",
                  },
                ];

                bool usesImages = opts.any((o) => o['img']!.isNotEmpty);

                return Column(
                  children: [
                    QuizReviewAnswer.buildReviewCard(
                      context: context,
                      index: index,
                      isEnglish: isEnglish,
                      isCorrect: userIdx == correctIdx,
                      question: isEnglish
                          ? q['question_text_en']
                          : q['question_text_ms'],
                      questionImageUrl: q['question_image'],
                      userAnswer: userIdx != -1 ? opts[userIdx]['t']! : "N/A",
                      correctAnswer: opts[correctIdx]['t']!,
                      explanation: isEnglish
                          ? q['explanation_en']
                          : q['explanation_ms'],
                      optionsWidget: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: usesImages ? 460 : 380,
                        ),
                        child: usesImages
                            ? GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      mainAxisExtent: 200,
                                    ),
                                itemCount: 4,
                                itemBuilder: (context, i) =>
                                    QuizOptions.buildOptionTile(
                                      context: context,
                                      index: i,
                                      text: opts[i]['t']!,
                                      imageUrl: opts[i]['img'],
                                      correctIndex: correctIdx,
                                      selectedIndex: userIdx,
                                      showFeedback: true,
                                      onTap: () {},
                                    ),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  4,
                                  (i) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: QuizOptions.buildOptionTile(
                                      context: context,
                                      index: i,
                                      text: opts[i]['t']!,
                                      imageUrl: opts[i]['img'],
                                      correctIndex: correctIdx,
                                      selectedIndex: userIdx,
                                      showFeedback: true,
                                      onTap: () {},
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    if (index == questions.length - 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30, top: 10),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: exitButton,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
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
    double fontSize = 16,
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
                    fontSize: 16,
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
            style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
          ),
          Text(
            "${isEnglish ? "Correct answer" : "Jawapan betul"}: $correctAnswer",
            style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
          ),
          if (explanation != null && explanation.trim().isNotEmpty) ...[
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
                    : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? colorScheme.outlineVariant
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
                      fontSize: 16,
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
