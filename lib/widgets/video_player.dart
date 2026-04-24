import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:visibility_detector/visibility_detector.dart';

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
    // Determine screen width
    double screenWidth = MediaQuery.of(context).size.width;

    // 420 Tablet. 200 Phone
    double responsiveHeight;
    if (screenWidth >= 800) {
      // Standard
      responsiveHeight = 400;
    } else if (screenWidth >= 600) {
      // SMALL TABLET
      responsiveHeight = 280;
    } else {
      // Phone
      responsiveHeight = 200;
    }

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
              height: responsiveHeight, // Dynamic height applied here
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.black,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Chewie(controller: _chewieController!),
              ),
            )
          : SizedBox(
              height: responsiveHeight, // Match height for the loader
              child: const Center(child: CircularProgressIndicator()),
            ),
    );
  }
}
