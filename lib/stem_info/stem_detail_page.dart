import 'package:flutter/material.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:photo_view/photo_view.dart';

import '../widgets/gradient_background.dart';
import '/navigation_provider.dart';
import 'package:stemxploref2/widgets/curved_navigation_bar.dart';
import '/widgets/language_toggle.dart';
import '../widgets/box_shadow.dart';
import '../widgets/rawscrollbar.dart';

class StemDetailPage extends StatefulWidget {
  final Map<String, dynamic> stemInfo;

  const StemDetailPage({required this.stemInfo, super.key});

  @override
  State<StemDetailPage> createState() => _StemDetailPageState();
}

class _StemDetailPageState extends State<StemDetailPage> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  final ScrollController _scrollController = ScrollController();
  bool _needsScrollReset = true;

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
    _videoController?.pause();
    _videoController?.dispose();
    _chewieController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      // 'useRootNavigator: true' ensures the image overlays everything,
      // including bottom nav and app bars.
      useRootNavigator: true,
      builder: (context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black, // Classic dark backdrop for photos
          child: Stack(
            children: [
              // 1. The Zoomable Image
              PhotoView(
                imageProvider: AssetImage(imagePath),
                loadingBuilder: (context, event) =>
                    const Center(child: CircularProgressIndicator()),
                // Allow some minor bouncing at the edges
                tightMode: false,
                // Define how the image fits (contain is usually best)
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale:
                    PhotoViewComputedScale.covered * 2.0, // Significant zoom
              ),

              // 2. The Close Button (Top Left/Right)
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () =>
                            Navigator.of(context).pop(), // Close the dialog
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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

    if (_videoController != null && _videoController!.value.isInitialized) {
      _videoController!.setVolume(isSoundEnabled ? 1.0 : 0.0);
    }

    return VisibilityDetector(
      key: const Key('stem-detail-page-key'),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction * 100 < 1) {
          _videoController?.pause();
        }
      },
      child: _buildScaffold(
        context,
        isDark,
        appBarTitle,
        title,
        description,
        detailImage,
        sourceText,
        isEnglish,
      ),
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
                padding: const EdgeInsets.fromLTRB(20, 5, 16, 0),
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
                child: Padding(
                  // 1. Matches the scrollbar offset from the right edge
                  padding: const EdgeInsets.only(right: 0),
                  child: AppRawScrollbar(
                    key: UniqueKey(),
                    controller: _scrollController,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          // 2. Exact padding from your StemInfoPage
                          padding: const EdgeInsets.fromLTRB(30, 13, 30, 16),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              // Subtract vertical padding to calculate available space
                              minHeight: constraints.maxHeight - 29,
                            ),
                            child: Center(
                              // THIS ensures the card is always at the middle center
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title
                                  Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  // THE CARD
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: cardBg,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: isDark ? [] : appBoxShadow,
                                      border: isDark
                                          ? Border.all(
                                              color: Colors.white10,
                                              width: 0.5,
                                            )
                                          : null,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (description != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 15,
                                            ),
                                            child: Text(
                                              description,
                                              textAlign: TextAlign.justify,
                                              style: TextStyle(
                                                fontSize: 15,
                                                height: 1.6,
                                                color: subTextColor,
                                              ),
                                            ),
                                          ),

                                        // Video Section
                                        if (_chewieController != null &&
                                            _chewieController!
                                                .videoPlayerController
                                                .value
                                                .isInitialized)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 15,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: AspectRatio(
                                                aspectRatio:
                                                    _chewieController!
                                                        .aspectRatio ??
                                                    16 / 9,
                                                child: Chewie(
                                                  controller:
                                                      _chewieController!,
                                                ),
                                              ),
                                            ),
                                          ),

                                        // Image Section
                                        if (detailImage != null)
                                          GestureDetector(
                                            onTap: () => _showFullScreenImage(
                                              context,
                                              detailImage,
                                            ),
                                            child: Hero(
                                              tag:
                                                  'stem_detail_image_$detailImage',
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: Image.asset(
                                                  detailImage,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                          ),

                                        // Source Section
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
                                              color: subTextColor.withOpacity(
                                                0.7,
                                              ),
                                            ),
                                          ),

                                          // Changed 'item' to 'widget.stemInfo' to fix the Undefined Name error
                                          if (widget.stemInfo['video_url'] !=
                                                  null &&
                                              widget.stemInfo['video_url']
                                                  .toString()
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              widget.stemInfo['video_url']
                                                  .toString(),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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
          _videoController?.pause();
          Provider.of<NavigationProvider>(
            context,
            listen: false,
          ).setIndex(index);
        },
      ),
    );
  }
}
