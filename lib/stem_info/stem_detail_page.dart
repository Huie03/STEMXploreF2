import 'package:flutter/material.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../widgets/gradient_background.dart';
import '/navigation_provider.dart';
import 'package:stemxploref2/widgets/curved_navigation_bar.dart';
import '/widgets/language_toggle.dart';
import '../widgets/box_shadow.dart';

class StemDetailPage extends StatefulWidget {
  final Map<String, dynamic> stemInfo;

  const StemDetailPage({required this.stemInfo, super.key});

  @override
  State<StemDetailPage> createState() => _StemDetailPageState();
}

class _StemDetailPageState extends State<StemDetailPage> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializeOfflinePlayer();
  }

  Future<void> _initializeOfflinePlayer() async {
    // Check for local asset path
    final String? localPath = widget.stemInfo['video'];

    if (localPath != null && localPath.isNotEmpty) {
      _videoController = VideoPlayerController.asset(localPath);

      try {
        await _videoController!.initialize();

        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: false,
          looping: false,
          aspectRatio: _videoController!.value.aspectRatio,
          materialProgressColors: ChewieProgressColors(
            playedColor: Colors.redAccent,
            handleColor: Colors.orange,
          ),
        );
        setState(() {});
      } catch (e) {
        debugPrint("Error initializing video: $e");
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
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

    String? getString(String keyPrefix) {
      final val = item['${keyPrefix}_$lang'] ?? item['${keyPrefix}_en'];
      return (val == null || val.toString().isEmpty) ? null : val.toString();
    }

    final String title = getString('title') ?? '';
    final String? description = getString('desc') ?? getString('preview');
    final String? detailImage = getString('detailImage');
    final String? sourceText = getString('source');

    final String appBarTitle = isEnglish ? 'STEM Info' : 'Maklumat STEM';

    // Handle sound sync for Chewie/VideoPlayer
    if (_videoController != null && _videoController!.value.isInitialized) {
      _videoController!.setVolume(isSoundEnabled ? 1.0 : 0.0);
    }

    return _buildScaffold(
      context,
      isDark,
      appBarTitle,
      title,
      description,
      detailImage,
      sourceText,
      isEnglish,
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    bool isDark,
    String appBarTitle,
    String title,
    String? description,
    String? detailImage,
    String? sourceText,
    bool isEnglish,
  ) {
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color cardBg = Theme.of(context).colorScheme.surface;
    final Color subTextColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
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
              // CONTENT
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white10
                                      : Colors.black26,
                                ),
                                boxShadow: isDark ? [] : appBoxShadow,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (description != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Text(
                                        description,
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                          fontSize: 15,
                                          height: 1.5,
                                          color: subTextColor,
                                        ),
                                      ),
                                    ),

                                  // Display Video Player if ready
                                  if (_chewieController != null &&
                                      _chewieController!
                                          .videoPlayerController
                                          .value
                                          .isInitialized)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: AspectRatio(
                                          aspectRatio:
                                              _chewieController!.aspectRatio ??
                                              16 / 9,
                                          child: Chewie(
                                            controller: _chewieController!,
                                          ),
                                        ),
                                      ),
                                    ),

                                  if (detailImage != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.asset(
                                        detailImage,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.broken_image,
                                                  size: 50,
                                                ),
                                      ),
                                    ),

                                  if (sourceText != null) ...[
                                    const SizedBox(height: 3),
                                    Divider(
                                      color: isDark
                                          ? Colors.white24
                                          : Colors.black12,
                                    ),
                                    const SizedBox(height: 5),
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: subTextColor.withValues(
                                            alpha: 0.7,
                                          ),
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
                                          TextSpan(text: "$sourceText\n"),
                                          if (widget.stemInfo['video_url'] !=
                                              null)
                                            TextSpan(
                                              text:
                                                  "${widget.stemInfo['video_url']}",
                                              style: const TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
}
