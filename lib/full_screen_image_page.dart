import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullScreenImagePage extends StatelessWidget {
  final String assetPath;
  final bool isNetwork;

  const FullScreenImagePage({
    super.key,
    required this.assetPath,
    this.isNetwork = false, // Set to true if loading from a URL
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Stack allows us to place the close button on top of the image
      body: Stack(
        children: [
          // 1. The Zoomable Image
          Center(
            child: Hero(
              // The tag must match exactly the tag used in the previous page
              tag: assetPath,
              child: PhotoView(
                imageProvider: isNetwork
                    ? NetworkImage(assetPath) as ImageProvider
                    : AssetImage(assetPath) as ImageProvider,
                // Ensures the image starts fully visible
                initialScale: PhotoViewComputedScale.contained,
                // Allows zooming out slightly
                minScale: PhotoViewComputedScale.contained * 0.8,
                // Allows zooming in significantly
                maxScale: PhotoViewComputedScale.covered * 4.0,
                loadingBuilder: (context, event) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
          ),

          // 2. The Close Button
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
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
  }
}
