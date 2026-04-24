import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:provider/provider.dart';
import 'package:stemxploref2/widgets/video_player.dart';
import 'package:stemxploref2/stem_highlights/highlight.dart';
import 'package:stemxploref2/widgets/gradient_background.dart';
import 'package:stemxploref2/widgets/language_toggle.dart';
import 'package:stemxploref2/widgets/rawscrollbar.dart';
import 'package:stemxploref2/widgets/box_shadow.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:stemxploref2/full_screen_image_page.dart';

class HighlightDetailPage extends StatefulWidget {
  static const routeName = '/highlight-detail';

  final Highlight highlight;
  const HighlightDetailPage({super.key, required this.highlight});

  @override
  State<HighlightDetailPage> createState() => _HighlightDetailPageState();
}

class _HighlightDetailPageState extends State<HighlightDetailPage> {
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;
    final bool isEnglish =
        FlutterLocalization.instance.currentLocale?.languageCode == 'en';

    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color cardBg = Theme.of(context).colorScheme.surface;
    final Color subTextColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEnglish ? 'STEM Highlights' : 'Sorotan STEM',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: textColor,
                      ),
                    ),
                    const LanguageToggle(),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 60),
                  child: AppRawScrollbar(
                    controller: _scrollController,
                    child: SingleChildScrollView(
                      key: UniqueKey(),
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEnglish
                                ? widget.highlight.titleEn
                                : widget.highlight.titleMs,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: isDark
                                  ? Border.all(
                                      color: Colors.white10,
                                      width: 0.5,
                                    )
                                  : null,
                              boxShadow: isDark ? [] : appBoxShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildBodyText(
                                  isEnglish
                                      ? widget.highlight.subtitleEn
                                      : widget.highlight.subtitleMs,
                                  textColor,
                                  isBold: true,
                                ),

                                //Image and Desc
                                _buildLocalImage(widget.highlight.image1Url),
                                const SizedBox(height: 12),
                                _buildBodyText(
                                  isEnglish
                                      ? widget.highlight.desc1En
                                      : widget.highlight.desc1Ms,
                                  subTextColor,
                                ),
                                const SizedBox(height: 12),
                                //Optional
                                if (widget.highlight.image2Url.isNotEmpty ||
                                    widget.highlight.desc2En.isNotEmpty) ...[
                                  if (widget.highlight.image2Url.isNotEmpty)
                                    _buildLocalImage(
                                      widget.highlight.image2Url,
                                    ),
                                  const SizedBox(height: 12),
                                  if (widget.highlight.desc2En.isNotEmpty)
                                    _buildBodyText(
                                      isEnglish
                                          ? widget.highlight.desc2En
                                          : widget.highlight.desc2Ms,
                                      subTextColor,
                                    ),
                                ],
                                const SizedBox(height: 12),
                                //Skills
                                _buildBodyText(
                                  isEnglish
                                      ? 'Skills Developed:'
                                      : 'Kemahiran Dibangunkan:',
                                  textColor,
                                  isBold: true,
                                ),
                                _buildLocalImage(
                                  isEnglish
                                      ? widget.highlight.skillsImageEn
                                      : widget.highlight.skillsImageMs,
                                ),
                                const SizedBox(height: 12),
                                //Video
                                if (widget.highlight.videoUrl != null &&
                                    widget.highlight.videoUrl!.isNotEmpty) ...[
                                  _buildBodyText(
                                    isEnglish ? 'Video:' : 'Video:',
                                    textColor,
                                    isBold: true,
                                  ),
                                  VideoPlayerWidget(
                                    assetPath: widget.highlight.videoUrl!,
                                  ),
                                ],
                                const SizedBox(height: 10),
                                //Sources
                                Text(
                                  isEnglish ? 'Source:' : 'Sumber:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: subTextColor,
                                  ),
                                ),
                                Text(
                                  isEnglish
                                      ? widget.highlight.citationEn
                                      : widget.highlight.citationMs,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: subTextColor,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.highlight.sourceUrl,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.blueAccent,
                                  ),
                                ),

                                //EXTRA SOURCES
                                if (widget
                                    .highlight
                                    .extraSources
                                    .isNotEmpty) ...[
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Divider(),
                                  ),
                                  Text(
                                    isEnglish
                                        ? 'Additional Highlights:'
                                        : 'Sorotan Tambahan:',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  ...widget.highlight.extraSources.map((extra) {
                                    final String? extraVid = extra['videoUrl']
                                        ?.toString();
                                    final String desc = isEnglish
                                        ? (extra['descEn']?.toString() ?? '')
                                        : (extra['descMs']?.toString() ?? '');
                                    final String citation = isEnglish
                                        ? (extra['citationEn']?.toString() ??
                                              '')
                                        : (extra['citationMs']?.toString() ??
                                              '');
                                    final String sUrl =
                                        extra['sourceUrl']?.toString() ?? '';

                                    final bool hasVideo =
                                        extraVid != null && extraVid.isNotEmpty;

                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 24.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildBodyText(desc, subTextColor),
                                          if (hasVideo) ...[
                                            VideoPlayerWidget(
                                              assetPath: extraVid,
                                            ),
                                            const SizedBox(height: 12),
                                          ],
                                          Text(
                                            isEnglish ? 'Source:' : 'Sumber:',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: subTextColor,
                                            ),
                                          ),
                                          Text(
                                            citation,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              height: 1,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            sUrl,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
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

  void _showFullScreenImage(BuildContext context, String assetPath) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, _, _) =>
            FullScreenImagePage(assetPath: assetPath),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Smooth fade transition as the image expands
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildLocalImage(String path) {
    if (path.isEmpty) return const SizedBox.shrink();

    // Remove leading slash if present to avoid asset load errors
    final String assetPath = path.startsWith('/') ? path.substring(1) : path;

    return GestureDetector(
      onTap: () => _showFullScreenImage(context, assetPath),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Hero(
          tag: assetPath,
          child: Image.asset(assetPath, fit: BoxFit.cover),
        ),
      ),
    );
  }

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
