import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:stemxploref2/bookmark/bookmark_provider.dart';
import 'package:stemxploref2/widgets/gradient_background.dart';
import 'package:stemxploref2/widgets/language_toggle.dart';
import 'package:stemxploref2/widgets/box_shadow.dart';
import 'package:stemxploref2/full_screen_image_page.dart';

class MaterialDetailPage extends StatefulWidget {
  final Map<String, dynamic> chapterData;

  const MaterialDetailPage({super.key, required this.chapterData});

  @override
  State<MaterialDetailPage> createState() => _MaterialDetailPageState();
}

class _MaterialDetailPageState extends State<MaterialDetailPage> {
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

    final String rawSubject =
        widget.chapterData['subject'] ??
        widget.chapterData['title'] ??
        "Science";
    final String chapterNum =
        widget.chapterData['chapter_number']?.toString() ??
        widget.chapterData['chapter_num']?.toString() ??
        "1";

    final String titleEn = widget.chapterData['title_en'] ?? "";
    final String titleMs = widget.chapterData['title_ms'] ?? "";

    final String infographicPath = isEnglish
        ? (widget.chapterData['infographic_en'] ??
              'assets/textbook/default.jpg')
        : (widget.chapterData['infographic_ms'] ??
              'assets/textbook/default.jpg');

    final String subjectDisplay = _translateSubject(rawSubject, isEnglish);
    final String chapterTitle = isEnglish ? titleEn : titleMs;
    final String label = isEnglish ? "Chapter" : "Bab";
    final String fullChapterString = "$label $chapterNum - $chapterTitle";

    // Watch the provider for changes
    final favoriteProvider = context.watch<BookmarkProvider>();

    // This will now correctly trigger a rebuild when the list updates
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
              const SizedBox(height: 10),
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
    if (isEnglish) {
      switch (subject) {
        case "Computer Science (ASK)":
          return "Fundamentals of Computer Science";
        case "Design and Technology (RBT)":
          return "Design and Technology";
        default:
          return subject;
      }
    }

    switch (subject) {
      case "Science":
        return "Sains";
      case "Mathematics":
        return "Matematik";
      case "Computer Science (ASK)":
        return "Asas Sains Komputer";
      case "Design and Technology (RBT)":
        return "Reka Bentuk dan Teknologi (RBT)";
      default:
        return subject;
    }
  }

  Widget _buildCustomAppBar(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
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
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
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
              final Map<String, dynamic> dataToToggle = {
                // These keys must be identical to what you use in FavoriteProvider
                'title': rawSub,
                'chapter_num': num,
                'title_en': tEn,
                'title_ms': tMs,
                'infographic_en': widget.chapterData['infographic_en'] ?? '',
                'infographic_ms': widget.chapterData['infographic_ms'] ?? '',
                'image': widget.chapterData['image_url'] ?? '',
              };

              await Provider.of<BookmarkProvider>(
                context,
                listen: false,
              ).toggleFavorite(dataToToggle);

              if (mounted) {
                _showCenterPopup(
                  isEnglish,
                  isAdding: !isBookmarked,
                  isDark: isDark,
                );
              }
            },
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              size: 30,
              color: isBookmarked
                  ? (isDark ? const Color(0xFFEFA638) : Colors.black)
                  : (isDark ? Colors.white : Colors.black),
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
      barrierColor: Colors.black.withValues(alpha: 0.3),
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
                            ? "Added to bookmarks"
                            : "Ditambah ke penanda buku")
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GestureDetector(
          onTap: () => _showFullScreenImage(context, imagePath),
          child: Hero(
            tag: imagePath,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.broken_image,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Image not found",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String assetPath) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, _) =>
            FullScreenImagePage(assetPath: assetPath),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
