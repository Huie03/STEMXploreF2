import 'package:flutter/material.dart';
import 'highlight.dart';
import '../widgets/gradient_background.dart';
import 'package:flutter_localization/flutter_localization.dart';
import '/widgets/language_toggle.dart';
import '../widgets/rawscrollbar.dart';
import '../widgets/box_shadow.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:provider/provider.dart';
import '../ipaddress.dart';

class HighlightDetailPage extends StatefulWidget {
  static const routeName = '/highlight-detail';
  final Highlight highlight;
  const HighlightDetailPage({super.key, required this.highlight});

  @override
  State<HighlightDetailPage> createState() => _HighlightDetailPageState();
}

class _HighlightDetailPageState extends State<HighlightDetailPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    final FlutterLocalization localization = FlutterLocalization.instance;
    final String currentLang = localization.currentLocale?.languageCode ?? 'en';
    final bool isEnglish = currentLang == 'en';

    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color cardBg = Theme.of(context).colorScheme.surface;
    final Color subTextColor = isDark ? Colors.white70 : Colors.black87;

    // Bilingual Data Logic
    final String displayTitle = isEnglish
        ? widget.highlight.titleEn
        : widget.highlight.titleMs;
    final String displaySubtitle = isEnglish
        ? widget.highlight.subtitleEn
        : widget.highlight.subtitleMs;
    final String displayDesc1 = isEnglish
        ? widget.highlight.desc1En
        : widget.highlight.desc1Ms;
    final String displayDesc2 = isEnglish
        ? widget.highlight.desc2En
        : widget.highlight.desc2Ms;
    final String displaySkillsImage = isEnglish
        ? widget.highlight.skillsImageEn
        : widget.highlight.skillsImageMs;
    final String displayCitation = isEnglish
        ? widget.highlight.citationEn
        : widget.highlight.citationMs;

    final String appBarTitle = isEnglish ? 'STEM Highlights' : 'Sorotan STEM';
    final String skillsHeader = isEnglish
        ? 'Skills Developed'
        : 'Kemahiran Dibangunkan';
    final String sourceHeader = isEnglish ? 'Source:' : 'Sumber:';

    // Add this right before return Scaffold(...)
    debugPrint("DEBUG: Language is: $currentLang");
    debugPrint("DEBUG: skillsImageEn: '${widget.highlight.skillsImageEn}'");
    debugPrint("DEBUG: skillsImageMs: '${widget.highlight.skillsImageMs}'");

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Custom Top Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        appBarTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: textColor,
                        ),
                      ),
                    ),
                    const LanguageToggle(),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AppRawScrollbar(
                    controller: _scrollController,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(28, 13, 18, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayTitle,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: isDark ? [] : appBoxShadow,
                              border: isDark
                                  ? Border.all(color: Colors.white10)
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              // ... inside your Column children:
                              children: [
                                // 1. Subtitle (Note: Assuming this is the title or subtitle text)
                                _buildBodyText(
                                  displaySubtitle,
                                  textColor,
                                  isBold: true,
                                ),

                                // 2. Divider
                                const Divider(height: 20),

                                // 3. Image 1 and Description 1
                                _buildNetworkImage(widget.highlight.image1Url),
                                const SizedBox(height: 12),
                                _buildBodyText(displayDesc1, subTextColor),

                                // 4. Divider (only show if Image 2 or Desc 2 exists)
                                if (widget.highlight.image2Url.isNotEmpty ||
                                    displayDesc2.isNotEmpty) ...[
                                  const Divider(height: 20),

                                  // 5. Image 2 (Conditional)
                                  if (widget
                                      .highlight
                                      .image2Url
                                      .isNotEmpty) ...[
                                    _buildNetworkImage(
                                      widget.highlight.image2Url,
                                    ),
                                    const SizedBox(height: 12),
                                  ],

                                  // 6. Desc 2 (Conditional)
                                  if (displayDesc2.isNotEmpty) ...[
                                    _buildBodyText(displayDesc2, subTextColor),
                                  ],
                                ],

                                // 7. Divider
                                const Divider(height: 30),

                                // 8. Skills Developed
                                _buildBodyText(
                                  skillsHeader,
                                  textColor,
                                  isBold: true,
                                ),
                                if (displaySkillsImage.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  _buildNetworkImage(displaySkillsImage),
                                  const SizedBox(height: 20),
                                ],

                                // 9. Source Section
                                Text(
                                  sourceHeader,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: subTextColor,
                                  ),
                                ),
                                Text(
                                  displayCitation,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subTextColor,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.highlight.sourceUrl,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
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

  Widget _buildNetworkImage(String imageName) {
    // If no URL exists, don't return anything
    if (imageName.isEmpty) return const SizedBox.shrink();

    String cleanPath = imageName.startsWith('/')
        ? imageName.substring(1)
        : imageName;
    final String fullImageUrl = "${ipadress.baseUrl}$cleanPath";

    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Image.network(
        fullImageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const SizedBox.shrink(), // Hide if load fails
      ),
    );
  }

  //Text styling
  Widget _buildBodyText(String text, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          height: 1.5,
          color: color,
        ),
      ),
    );
  }
}
