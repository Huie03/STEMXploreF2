import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/gradient_background.dart';
import '/navigation_provider.dart';
import 'package:stemxploref2/favorite/favorite_provider.dart';
import 'package:stemxploref2/widgets/curved_navigation_bar.dart';

class MaterialDetailPage extends StatefulWidget {
  const MaterialDetailPage({super.key});

  @override
  State<MaterialDetailPage> createState() => _MaterialDetailPageState();
}

class _MaterialDetailPageState extends State<MaterialDetailPage> {
  bool _showPopup = false;
  final String _currentTitle = "Science";
  final String _currentChapter = "Chapter 3 - Nutrition";

  void _handleBookmark() {
    final bookmarkProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );

    final materialData = {
      "title": _currentTitle,
      "chapter": _currentChapter,
      "image": 'assets/images/science_book_cover.png',
    };

    bookmarkProvider.toggleFavorite(materialData);

    // Show popup only if we just added the bookmark
    if (bookmarkProvider.isFavorited(_currentTitle, _currentChapter)) {
      setState(() => _showPopup = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showPopup = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBookmarked = context.watch<FavoriteProvider>().isFavorited(
      _currentTitle,
      _currentChapter,
    );

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                children: [
                  AppBar(
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: Text(
                      _currentTitle,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: true,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _currentChapter,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _handleBookmark,
                                  child: Icon(
                                    isBookmarked
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    size: 28,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Content Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(color: Colors.black, width: 1),
                            ),
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/Science.png',
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F4FD),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Nutrition is the process by which living organisms take in food...',
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Image.asset(
                                  'assets/images/food_pyramid_image.webp',
                                  height: 250,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (_showPopup)
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.45,
                  child: _buildBookmarkPopup(),
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
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }

  Widget _buildBookmarkPopup() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)],
      ),
      child: const Text(
        'You can continue reading at bookmark',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}
