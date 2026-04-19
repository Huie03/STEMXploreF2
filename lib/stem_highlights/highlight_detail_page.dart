import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:visibility_detector/visibility_detector.dart'; // Added for stop handling
import 'highlight.dart';
import '../widgets/gradient_background.dart';
import 'package:flutter_localization/flutter_localization.dart';
import '/widgets/language_toggle.dart';
import '../widgets/rawscrollbar.dart';
import '../widgets/box_shadow.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:photo_view/photo_view.dart';

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
                                    final String? extraVid = extra['videoUrl'];
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
                                          //Description
                                          _buildBodyText(
                                            isEnglish
                                                ? (extra['descEn'] ?? '')
                                                : (extra['descMs'] ?? ''),
                                            subTextColor,
                                          ),
                                          //Video Player
                                          if (hasVideo) ...[
                                            VideoPlayerWidget(
                                              assetPath: extraVid,
                                            ),
                                            const SizedBox(height: 12),
                                          ],

                                          //Citation
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
                                                ? (extra['citationEn'] ?? '')
                                                : (extra['citationMs'] ?? ''),
                                            style: TextStyle(
                                              fontSize: 11,
                                              height: 1,
                                            ),
                                          ),

                                          //Source URL
                                          const SizedBox(height: 4),
                                          Text(
                                            extra['sourceUrl'] ?? '',
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
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              PhotoView(
                imageProvider: AssetImage(assetPath),
                loadingBuilder: (context, event) =>
                    const Center(child: CircularProgressIndicator()),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2.0,
              ),

              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
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

  Widget _buildLocalImage(String path) {
    if (path.isEmpty) return const SizedBox.shrink();

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

class VideoPlayerWidget extends StatefulWidget {
  final String assetPath;
  const VideoPlayerWidget({super.key, required this.assetPath});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with WidgetsBindingObserver {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.asset(widget.assetPath);

    try {
      await _videoPlayerController!.initialize();

      if (_isDisposed || !mounted) {
        _videoPlayerController?.dispose();
        return;
      }

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        autoPlay: false,
        looping: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.redAccent,
          handleColor: Colors.orange,
        ),
      );

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Video Error: $e");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _videoPlayerController?.pause();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);

    _chewieController?.dispose();
    _videoPlayerController?.pause();
    _videoPlayerController?.dispose();

    debugPrint("CLEANUP: Video resources released for ${widget.assetPath}");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.assetPath),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction < 0.1 && mounted) {
          _videoPlayerController?.pause();
        }
      },
      child:
          _chewieController != null &&
              _chewieController!.videoPlayerController.value.isInitialized
          ? Container(
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.black,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Chewie(controller: _chewieController!),
              ),
            )
          : const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
    );
  }
}
