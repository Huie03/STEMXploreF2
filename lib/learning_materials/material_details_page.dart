import 'package:flutter/material.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:stemxploref2/favorite/favorite_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/language_toggle.dart';
import '../widgets/box_shadow.dart';
import 'package:stemxploref2/navigation_provider.dart';

class MaterialDetailPage extends StatefulWidget {
  final Map<String, dynamic> chapterData;

  const MaterialDetailPage({super.key, required this.chapterData});

  @override
  State<MaterialDetailPage> createState() => _MaterialDetailPageState();
}

class _MaterialDetailPageState extends State<MaterialDetailPage> {
  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color cardBg = Theme.of(context).colorScheme.surface;

    final FlutterLocalization localization = FlutterLocalization.instance;

    final bool isEnglish =
        localization.currentLocale?.languageCode == 'en' ||
        localization.currentLocale == null;

    final String rawSubject = widget.chapterData['subject'] ?? "Science";
    final String titleEn = widget.chapterData['title_en'] ?? "";
    final String titleMs = widget.chapterData['title_ms'] ?? "";
    final String chapterNum =
        widget.chapterData['chapter_number']?.toString() ?? "1";

    final String infographicPath = isEnglish
        ? (widget.chapterData['infographic_en'] ??
              'assets/textbook/default.jpg')
        : (widget.chapterData['infographic_ms'] ??
              'assets/textbook/default.jpg');

    final String subjectDisplay = _translateSubject(rawSubject, isEnglish);
    final String chapterTitle = isEnglish ? titleEn : titleMs;
    final String label = isEnglish ? "Chapter" : "Bab";
    final String fullChapterString = "$label $chapterNum - $chapterTitle";

    final favoriteProvider = context.watch<FavoriteProvider>();

    final bool isBookmarked = favoriteProvider.isFavorited(
      rawSubject,
      chapterNum,
    );

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomAppBar(subjectDisplay, textColor),
              _buildSubHeader(
                rawSubject,
                chapterNum,
                titleEn,
                titleMs,
                fullChapterString,
                isBookmarked,
                isEnglish,
                textColor,
                isDark,
              ),
              Expanded(
                child: _buildMainContent(infographicPath, cardBg, isDark),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _translateSubject(String subject, bool isEnglish) {
    if (isEnglish) return subject;
    switch (subject) {
      case "Science":
        return "Sains";
      case "Mathematics":
        return "Matematik";
      case "Computer Science (ASK)":
        return "Asas Sains Komputer (ASK)";
      case "Design and Technology (RBT)":
        return "Reka Bentuk dan Teknologi (RBT)";
      default:
        return subject;
    }
  }

  Widget _buildCustomAppBar(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 10, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
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
    );
  }

  Widget _buildSubHeader(
    String rawSub,
    String num,
    String tEn,
    String tMs,
    String display,
    bool isBookmarked,
    bool isEnglish,
    Color textColor,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              display,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              // Make this async
              final Map<String, String> dataToToggle = {
                'title': rawSub,
                'chapter_num': num,
                'title_en': tEn,
                'title_ms': tMs,
                'infographic_en':
                    widget.chapterData['infographic_en']?.toString() ?? '',
                'infographic_ms':
                    widget.chapterData['infographic_ms']?.toString() ?? '',
                'image':
                    widget.chapterData['image_url'] ??
                    '', // Ensure this key matches
              };

              // Store the state BEFORE toggling to know if we are adding or removing
              final bool willBeAdded = !isBookmarked;

              // Await the toggle so the UI waits for the server
              await Provider.of<FavoriteProvider>(
                context,
                listen: false,
              ).toggleFavorite(dataToToggle);

              // Now show the popup
              if (mounted) {
                _showCenterPopup(
                  isEnglish,
                  isAdding: willBeAdded,
                  isDark: isDark,
                );
              }
            },
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              size: 30,
              // Ensure the color logic correctly reflects the boolean state
              color: isBookmarked
                  ? (isDark
                        ? const Color(0xFFEFA638)
                        : Colors.black) // Filled color
                  : (isDark ? Colors.white : Colors.black), // Border color
            ),
          ),
        ],
      ),
    );
  }

  void _showCenterPopup(
    bool isEnglish, {
    required bool isAdding,
    required bool isDark,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3D3D3D) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: appBoxShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAdding ? Icons.bookmark_added : Icons.bookmark_remove,
                  size: 50,
                  color: const Color(0xFFEFA638),
                ),
                const SizedBox(height: 16),
                Text(
                  isAdding
                      ? (isEnglish
                            ? "You can continue reading at bookmark"
                            : "Anda boleh teruskan membaca di penanda buku")
                      : (isEnglish
                            ? "Bookmark removed"
                            : "Penanda buku telah dialih keluar"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEFA638),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "OK",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent(String imagePath, Color cardBg, bool isDark) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(0),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Image.asset(
              imagePath,
              fit: BoxFit.fitWidth,
              alignment: Alignment.topCenter,
              errorBuilder: (context, error, stack) => Padding(
                padding: const EdgeInsets.all(40.0),
                child: Icon(
                  Icons.broken_image,
                  size: 80,
                  color: isDark ? Colors.white24 : Colors.grey,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
