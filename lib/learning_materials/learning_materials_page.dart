import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import '../widgets/gradient_background.dart';
import '../widgets/language_toggle.dart';
import '../widgets/box_shadow.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/rawscrollbar.dart';

class LearningMaterialPage extends StatefulWidget {
  final Function(String) onSubjectTap;
  final VoidCallback? onBackOverride;

  const LearningMaterialPage({
    super.key,
    required this.onSubjectTap,
    this.onBackOverride,
  });

  @override
  State<LearningMaterialPage> createState() => _LearningMaterialPageState();
}

class _LearningMaterialPageState extends State<LearningMaterialPage> {
  final ScrollController _scrollController = ScrollController();
  bool _needsScrollReset = true;

  final List<Map<String, String>> materials = const [
    {"title": "Science", "image": 'assets/textbook/Science/BC_Science.jpg'},
    {
      "title": "Mathematics",
      "image": 'assets/textbook/Mathematics/BC_Mathematics.jpg',
    },
    {
      "title": "Computer Science (ASK)",
      "image": 'assets/textbook/ASK/BC_ASK.jpg',
    },
    {
      "title": "Design and Technology (RBT)",
      "image": 'assets/textbook/RBT/BC_RBT.jpg',
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Logic: Every time this page is built/pushed, reset the scroll to 0

    if (_needsScrollReset) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);

          _needsScrollReset = false;
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  String _translateTitle(String title, bool isEnglish) {
    if (isEnglish) return title;
    switch (title) {
      case "Science":
        return "Sains";
      case "Mathematics":
        return "Matematik";
      case "Computer Science (ASK)":
        return "Asas Sains Komputer (ASK)";
      case "Design and Technology (RBT)":
        return "Reka Bentuk dan Teknologi (RBT)";
      default:
        return title;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color cardBg = Theme.of(context).colorScheme.surface;

    final FlutterLocalization localization = FlutterLocalization.instance;
    final bool isEnglish =
        localization.currentLocale?.languageCode == 'en' ||
        localization.currentLocale == null;

    final String pageTitle = isEnglish
        ? 'Learning Material'
        : 'Bahan Pembelajaran';
    final String subjectHeader = isEnglish ? 'Subjects' : 'Subjek';

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomAppBar(pageTitle, textColor),
              Expanded(
                // 3. Wrap with AppRawScrollbar
                child: AppRawScrollbar(
                  key: UniqueKey(),
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    // 4. Assign the controller here
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            top: 10,
                            bottom: 10,
                          ),
                          child: Text(
                            subjectHeader,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: materials.length,
                          itemBuilder: (context, index) {
                            final item = materials[index];
                            return _buildMaterialCard(
                              context,
                              isDark: isDark,
                              cardBg: cardBg,
                              textColor: textColor,
                              title: _translateTitle(item['title']!, isEnglish),
                              imagePath: item['image']!,
                              onTap: () => widget.onSubjectTap(item['title']!),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 100,
                        ), // Bottom padding for better scroll feel
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: textColor,
            ),
          ),
          const LanguageToggle(),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(
    BuildContext context, {
    required String title,
    required bool isDark,
    required Color cardBg,
    required Color textColor,
    required String imagePath,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: isDark ? Border.all(color: Colors.white10, width: 0.5) : null,
          boxShadow: isDark ? [] : appBoxShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(width: 15),
            SizedBox(
              height: 85,
              width: 65,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) => Icon(
                  Icons.book,
                  size: 50,
                  color: isDark ? Colors.white54 : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
