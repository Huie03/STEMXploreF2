import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stemxploref2/widgets/rawscrollbar.dart';
import 'package:stemxploref2/widgets/box_shadow.dart';
import 'package:stemxploref2/theme_provider.dart';

class CareerQuizContent extends StatelessWidget {
  final List dbQuestions;
  final bool isEn;
  final bool isTablet;
  final double verticalGap;
  final double responsiveRatio;
  final Map<int, int> singleChoices;
  final Set<int> multiChoicesQ5;
  final ScrollController scrollController;
  final VoidCallback onCompletionPressed;
  final Function(int qId, int optId) onSingleChoiceSelected;
  final Function(int optId) onMultiChoiceToggled;

  const CareerQuizContent({
    super.key,
    required this.dbQuestions,
    required this.isEn,
    required this.isTablet,
    required this.verticalGap,
    required this.responsiveRatio,
    required this.singleChoices,
    required this.multiChoicesQ5,
    required this.scrollController,
    required this.onCompletionPressed,
    required this.onSingleChoiceSelected,
    required this.onMultiChoiceToggled,
  });

  static Widget buildContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsets? margin,
    EdgeInsets? padding,
  }) {
    final bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    const double cardRadius = 35.0;

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

  @override
  Widget build(BuildContext context) {
    if (dbQuestions.isEmpty) {
      return const Center(child: Text("Loading career questions..."));
    }

    final totalQuestions = dbQuestions.length;
    final progress =
        (singleChoices.length + (multiChoicesQ5.isNotEmpty ? 1 : 0)) /
        totalQuestions;

    return buildContainer(
      context: context,
      child: Column(
        children: [
          _buildProgressBar(isEn, progress, context),
          Expanded(
            child: AppRawScrollbar(
              controller: scrollController,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(totalQuestions, (index) {
                      final bool isLastQuestion = index == totalQuestions - 1;
                      return _buildQuestion(
                        dbQuestions[index],
                        context,
                        isLastQuestion,
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: actionButton(
              context,
              isEn ? "Done" : "Selesai",
              (singleChoices.length == totalQuestions - 1 &&
                      multiChoicesQ5.isNotEmpty)
                  ? onCompletionPressed
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(bool isEn, double progress, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isEn ? "Progress" : "Kemajuan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              "${(progress * 100).toInt()}%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          backgroundColor: isDark ? Colors.white10 : Colors.grey.shade300,
          color: Colors.green,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildQuestion(Map q, BuildContext context, bool isMulti) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final int qId = int.parse(q['id'].toString());
    final List optionsList = q['options'] as List;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? q['q_text_en'] : q['q_text_ms'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          if (isMulti)
            Column(
              children: List.generate(optionsList.length, (i) {
                final int optId = int.parse(optionsList[i]['id'].toString());
                return _optionRow(
                  optionsList[i],
                  context,
                  multiChoicesQ5.contains(optId),
                  () => onMultiChoiceToggled(optId),
                );
              }),
            )
          else
            Column(
              children: optionsList.map((opt) {
                final int optId = int.parse(opt['id'].toString());
                return _optionRow(
                  opt,
                  context,
                  singleChoices[qId] == optId,
                  () => onSingleChoiceSelected(qId, optId),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _optionRow(
    Map opt,
    BuildContext context,
    bool selected,
    VoidCallback onTap,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    const Color activeColor = Color(0xFFF19100);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: selected
                  ? activeColor
                  : (isDark ? Colors.white38 : Colors.black54),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isEn ? opt['opt_text_en'] : opt['opt_text_ms'],
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: 15,
                  color: selected
                      ? activeColor
                      : (isDark ? Colors.white : Colors.black),
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
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
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}
