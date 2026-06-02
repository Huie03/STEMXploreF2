import 'package:flutter/material.dart';
import 'package:stemxploref2/widgets/box_shadow.dart';
import 'package:stemxploref2/widgets/rawscrollbar.dart';
import 'package:stemxploref2/quiz_game/quiz_options.dart';

class QuizContent extends StatelessWidget {
  final List<dynamic> questions;
  final int currentQuestionIndex;
  final int? selectedOptionIndex;
  final bool isLocked;
  final bool isReviewMode;
  final bool isEnglish;
  final ScrollController scrollController;
  final Function(int index, int correctIndex) onOptionTap;
  final Function(BuildContext context, String imagePath) onImageTap;
  final Widget navButtons;

  const QuizContent({
    super.key,
    required this.questions,
    required this.currentQuestionIndex,
    required this.selectedOptionIndex,
    required this.isLocked,
    required this.isReviewMode,
    required this.isEnglish,
    required this.scrollController,
    required this.onOptionTap,
    required this.onImageTap,
    required this.navButtons,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardBg = Theme.of(context).colorScheme.surface;
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    final q = questions[currentQuestionIndex];

    final List<Map<String, String>> optionData = [
      {
        'text': isEnglish ? (q['opt_a_en'] ?? "") : (q['opt_a_ms'] ?? ""),
        'image': q['opt_a_image']?.toString() ?? "",
      },
      {
        'text': isEnglish ? (q['opt_b_en'] ?? "") : (q['opt_b_ms'] ?? ""),
        'image': q['opt_b_image']?.toString() ?? "",
      },
      {
        'text': isEnglish ? (q['opt_c_en'] ?? "") : (q['opt_c_ms'] ?? ""),
        'image': q['opt_c_image']?.toString() ?? "",
      },
      {
        'text': isEnglish ? (q['opt_d_en'] ?? "") : (q['opt_d_ms'] ?? ""),
        'image': q['opt_d_image']?.toString() ?? "",
      },
    ];

    bool usesImageOptions = optionData.any((opt) => opt['image']!.isNotEmpty);
    final int? activeSelection = isReviewMode
        ? q['user_choice']
        : selectedOptionIndex;
    final bool showFeedback = isLocked || isReviewMode;

    String rawLetter =
        q['correct_option']?.toString().trim().toUpperCase() ?? "";
    int correctIndex = "ABCD".indexOf(rawLetter);
    if (correctIndex == -1) correctIndex = 0;

    return AppRawScrollbar(
      controller: scrollController,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: appBoxShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${isEnglish ? "Question" : "Soalan"} ${currentQuestionIndex + 1}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                "${currentQuestionIndex + 1} / ${questions.length}",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isEnglish
                                ? (q['question_text_en'] ?? "")
                                : (q['question_text_ms'] ?? ""),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                              height: 1.4,
                            ),
                          ),
                          if (q['question_image'] != null &&
                              q['question_image'].isNotEmpty) ...[
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () =>
                                  onImageTap(context, q['question_image']),
                              child: Center(
                                child: Hero(
                                  tag: q['question_image'],
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      q['question_image'],
                                      height: 150,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.broken_image,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (usesImageOptions)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 180,
                            ),
                        itemCount: 4,
                        itemBuilder: (context, i) =>
                            QuizOptions.buildOptionTile(
                              context: context,
                              index: i,
                              text: optionData[i]['text']!,
                              imageUrl: optionData[i]['image']!,
                              correctIndex: correctIndex,
                              selectedIndex: activeSelection,
                              showFeedback: showFeedback,
                              onTap: () => onOptionTap(i, correctIndex),
                            ),
                      )
                    else
                      ...List.generate(
                        4,
                        (i) => QuizOptions.buildOptionTile(
                          context: context,
                          index: i,
                          text: optionData[i]['text']!,
                          correctIndex: correctIndex,
                          selectedIndex: activeSelection,
                          showFeedback: showFeedback,
                          onTap: () => onOptionTap(i, correctIndex),
                        ),
                      ),
                    const SizedBox(height: 25),
                    navButtons,
                    if (showFeedback) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: appBoxShadow,
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEnglish ? "Explanation:" : "Penerangan:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isEnglish
                                  ? (q['explanation_en'] ??
                                        "No explanation available.")
                                  : (q['explanation_ms'] ??
                                        "Tiada penerangan tersedia."),
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
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
}
