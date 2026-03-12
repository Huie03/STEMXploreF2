import 'package:flutter/material.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../widgets/gradient_background.dart';
import '/navigation_provider.dart';
import 'package:stemxploref2/widgets/curved_navigation_bar.dart';
import '/widgets/language_toggle.dart';
import '../widgets/box_shadow.dart';
import '../ipaddress.dart';

class StemDetailPage extends StatefulWidget {
  final Map<String, String> stemInfo;

  const StemDetailPage({required this.stemInfo, super.key});

  @override
  State<StemDetailPage> createState() => _StemDetailPageState();
}

class _StemDetailPageState extends State<StemDetailPage> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    // Matches your DB column: 'type'
    if (widget.stemInfo['type'] == 'video') {
      // Matches your DB column: 'video_url'
      final String? videoUrl = widget.stemInfo['video_url'];
      final String? videoId = videoUrl != null
          ? YoutubePlayer.convertUrlToId(videoUrl)
          : null;

      if (videoId != null) {
        _controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            useHybridComposition: true,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;
    final bool isSoundEnabled = themeProvider.isSoundEnabled;

    final String lang =
        FlutterLocalization.instance.currentLocale?.languageCode ?? 'en';
    final bool isEnglish = lang == 'en';
    final item = widget.stemInfo;

    String? getSanitizedValue(String? value) {
      if (value == null ||
          value.toLowerCase() == 'null' ||
          value.trim().isEmpty) {
        return null;
      }
      return value;
    }

    final String title = item['title_$lang'] ?? item['title_en'] ?? '';
    final String? preview = getSanitizedValue(
      item['preview_$lang'] ?? item['preview_en'],
    );
    final String? detailImage = getSanitizedValue(
      item['detail_image_$lang'] ?? item['detail_image_en'],
    );
    final String? sourceText = getSanitizedValue(
      item['source_$lang'] ?? item['source_en'],
    );
    final String? videoUrl = getSanitizedValue(item['video_url']);

    final String appBarTitle = isEnglish ? 'STEM Info' : 'Maklumat STEM';
    bool isVideo = item['type'] == 'video';

    if (_controller != null) {
      isSoundEnabled ? _controller!.unMute() : _controller!.mute();
    }

    if (isVideo && _controller != null) {
      return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller!,
          showVideoProgressIndicator: true,
        ),
        builder: (context, player) => _buildScaffold(
          context,
          isDark,
          appBarTitle,
          title,
          preview,
          null,
          sourceText,
          isEnglish,
          item,
          videoPlayer: player,
          videoUrl: videoUrl,
        ),
      );
    } else {
      return _buildScaffold(
        context,
        isDark,
        appBarTitle,
        title,
        preview,
        detailImage,
        sourceText,
        isEnglish,
        item,
        videoUrl: videoUrl,
      );
    }
  }

  Widget _buildScaffold(
    BuildContext context,
    bool isDark,
    String appBarTitle,
    String title,
    String? preview,
    String? detailImage,
    String? sourceText,
    bool isEnglish,
    Map<String, String> item, {
    Widget? videoPlayer,
    String? videoUrl,
  }) {
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color cardBg = Theme.of(context).colorScheme.surface;
    final Color subTextColor = isDark ? Colors.white : Colors.black87;
    final Color linkColor = isDark ? Colors.blue.shade300 : Colors.blueAccent;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appBarTitle,
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black26,
                          ),
                          boxShadow: isDark ? [] : appBoxShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (preview != null && preview.isNotEmpty)
                              Text(
                                preview,
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.4,
                                  color: subTextColor,
                                ),
                              ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child:
                                  videoPlayer ?? _buildImageWidget(detailImage),
                            ),
                            // Source Section
                            if (sourceText != null) ...[
                              const SizedBox(height: 10),
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: subTextColor,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: isEnglish
                                          ? "Source:\n"
                                          : "Sumber:\n",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(text: sourceText),
                                  ],
                                ),
                              ),
                            ],
                            // Video URL Section
                            if (videoUrl != null) ...[
                              Text(
                                videoUrl,
                                style: TextStyle(
                                  color: linkColor,
                                  fontSize: 12,
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppCurvedNavBar(
        currentIndex: 0,
        onTap: (index) => Provider.of<NavigationProvider>(
          context,
          listen: false,
        ).setIndex(index),
      ),
    );
  }

  // Helper to handle Network vs Local images
  Widget _buildImageWidget(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty || imagePath == 'null') {
      return const SizedBox.shrink();
    }

    // Check if the image path is a full URL or a relative path from your database
    if (imagePath.startsWith('http')) {
      return Image.network(imagePath, fit: BoxFit.contain);
    } else {
      // Construct the full URL using your baseUrl
      final String fullUrl = '${ipadress.baseUrl}$imagePath';
      return Image.network(
        fullUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
        },
      );
    }
  }
}
