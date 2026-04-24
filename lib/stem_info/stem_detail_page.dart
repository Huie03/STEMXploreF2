import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localization/flutter_localization.dart';
import '/theme_provider.dart';
import '/widgets/video_player.dart';
import '/full_screen_image_page.dart';
import '/widgets/gradient_background.dart';
import '/navigation_provider.dart';
import '/widgets/curved_navigation_bar.dart';
import '/widgets/language_toggle.dart';
import '/widgets/box_shadow.dart';
import '/widgets/rawscrollbar.dart';

class StemDetailPage extends StatefulWidget {
  final Map<String, dynamic> stemInfo;

  const StemDetailPage({required this.stemInfo, super.key});

  @override
  State<StemDetailPage> createState() => _StemDetailPageState();
}

class _StemDetailPageState extends State<StemDetailPage> {
  final ScrollController _scrollController = ScrollController();
  bool _needsScrollReset = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  void _showFullScreenImage(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, _, _) =>
            FullScreenImagePage(assetPath: imagePath),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;

    final String lang =
        FlutterLocalization.instance.currentLocale?.languageCode ?? 'en';
    final bool isEnglish = lang == 'en';
    final item = widget.stemInfo;

    String? getString(String keyPrefix) {
      final val = item['${keyPrefix}_$lang'] ?? item['${keyPrefix}_en'];
      if (val == null) return null;
      final str = val.toString().trim();
      return str.isEmpty ? null : str;
    }

    final String title = getString('title') ?? '';
    final String? description = getString('desc') ?? getString('preview');
    final String? detailImage = getString('detailImage');
    final String? sourceText = getString('source');

    // Extract video path from the data map
    final String? videoPath = item['video']?.toString();
    final bool hasVideo = videoPath != null && videoPath.trim().isNotEmpty;

    final String appBarTitle = isEnglish ? 'STEM Info' : 'Maklumat STEM';

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appBarTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const LanguageToggle(),
                  ],
                ),
              ),
              Expanded(
                child: AppRawScrollbar(
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(30, 13, 30, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: isDark ? [] : appBoxShadow,
                            border: isDark
                                ? Border.all(color: Colors.white10, width: 0.5)
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (description != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: Text(
                                    description,
                                    textAlign: TextAlign.justify,
                                    style: TextStyle(
                                      fontSize: 15,
                                      height: 1.6,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),

                              if (hasVideo)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: VideoPlayerWidget(
                                    assetPath: videoPath,
                                  ),
                                ),

                              if (detailImage != null &&
                                  detailImage.trim().isNotEmpty)
                                GestureDetector(
                                  onTap: () => _showFullScreenImage(
                                    context,
                                    detailImage,
                                  ),
                                  child: Hero(
                                    tag: detailImage,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.asset(
                                        detailImage,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                height: 150,
                                                width: double.infinity,
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.broken_image,
                                                  size: 40,
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                ),

                              if (sourceText != null) ...[
                                const SizedBox(height: 10),
                                Divider(
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.black12,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  isEnglish ? "Source:" : "Sumber:",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  sourceText,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        (isDark ? Colors.white : Colors.black87)
                                            .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppCurvedNavBar(
        currentIndex: 0,
        onTap: (index) {
          Provider.of<NavigationProvider>(
            context,
            listen: false,
          ).setIndex(index);
        },
      ),
    );
  }
}
