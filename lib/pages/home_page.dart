import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stemxploref2/theme_provider.dart';
import '/navigation_provider.dart';
import '/widgets/gradient_background.dart';
import '/widgets/language_toggle.dart';
import '/stem_highlights/highlight.dart';
import '/widgets/feature_button.dart';
import '../widgets/box_shadow.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';
  final Function(Highlight) onHighlightTap;
  const HomePage({super.key, required this.onHighlightTap});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<Highlight> highlights = [];
  bool isLoading = true;
  late PageController _pageController;
  bool _isUserScrolling = false;
  Timer? _autoScrollTimer;

  final List<Map<String, dynamic>> _features = [
    {'key': 'stemInfo', 'icon': 'assets/icons/1.png', 'index': 4},
    {'key': 'learning', 'icon': 'assets/icons/2.png', 'index': 5},
    {'key': 'quiz', 'icon': 'assets/icons/3.png', 'index': 6},
    {'key': 'careers', 'icon': 'assets/icons/4.png', 'index': 7},
    {'key': 'info', 'icon': 'assets/icons/5.png', 'index': 8},
    {'key': 'faq', 'icon': 'assets/icons/6.png', 'index': 9},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final double? savedPage = PageStorage.of(context).readState(
      context,
      identifier: const PageStorageKey('home_page_controller'),
    );

    _pageController = PageController(
      viewportFraction: 0.9,
      initialPage: savedPage?.round() ?? 0,
    );

    _loadHardcodedHighlights(); // Changed from _fetchHighlights
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // REPLACED: Fetching from hardcoded data instead of API
  void _loadHardcodedHighlights() {
    setState(() {
      highlights = Highlight.getHardcodedHighlights();
      isLoading = false;
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted ||
          _isUserScrolling ||
          !_pageController.hasClients ||
          highlights.isEmpty)
        return;
      int nextIndex = (_pageController.page!.round() + 1) % highlights.length;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 900),
        curve: Curves.fastOutSlowIn,
      );
    });
  }

  String translate(String key, bool isEnglish) {
    final Map<String, Map<String, String>> localizedValues = {
      'stemInfo': {'en': 'STEM Info', 'ms': 'Info STEM'},
      'learning': {'en': 'Learning Material', 'ms': 'Bahan Pembelajaran'},
      'quiz': {'en': 'Quiz Game', 'ms': 'Permainan Kuiz'},
      'careers': {'en': 'STEM Careers', 'ms': 'Kerjaya STEM'},
      'info': {'en': 'Daily Info', 'ms': 'Maklumat Harian'},
      'faq': {'en': 'FAQ', 'ms': 'Soalan Lazim'},
      'highlights': {'en': 'STEM Highlights:', 'ms': 'Sorotan STEM:'},
      'readMore': {'en': 'Read more', 'ms': 'Baca lagi'},
    };
    return localizedValues[key]?[isEnglish ? 'en' : 'ms'] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;
    final bool isEnglish = navProvider.locale.languageCode == 'en';
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final bool isTablet = MediaQuery.of(context).size.shortestSide > 600;

    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(textColor),
            Expanded(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 550 : double.infinity,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      //60% for buttons, 40% for highlights
                      double totalHeight = constraints.maxHeight;
                      bool isSmallPhone = totalHeight < 650;

                      double gridMultiplier = isSmallPhone ? 0.62 : 0.65;
                      double highlightMultiplier = isSmallPhone ? 0.33 : 0.34;

                      double gridHeight = totalHeight * gridMultiplier;
                      double highlightHeight =
                          totalHeight * highlightMultiplier;

                      return Column(
                        children: [
                          //Feature Buttons Grid
                          SizedBox(
                            height: gridHeight,
                            child: GridView.count(
                              padding: const EdgeInsets.only(top: 10),
                              crossAxisCount: 2,
                              mainAxisSpacing: isSmallPhone ? 12 : 12,
                              crossAxisSpacing: 12,
                              //Ratio calculate based on available grid height
                              childAspectRatio:
                                  (constraints.maxWidth / 2) /
                                  (gridHeight / (isSmallPhone ? 3.3 : 3.20)),
                              physics: const NeverScrollableScrollPhysics(),
                              children: _features.map((feature) {
                                return FeatureButton(
                                  label: translate(feature['key'], isEnglish),
                                  imageAsset: feature['icon'],
                                  onTap: () =>
                                      navProvider.setIndex(feature['index']),
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: 5),

                          Divider(
                            thickness: 2,
                            height: 1,
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),

                          //Highlights Section
                          SizedBox(
                            height: highlightHeight,
                            child: isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : _buildHighlightsSection(
                                    isEnglish,
                                    isTablet,
                                    textColor,
                                    isDark,
                                    highlightHeight *
                                        0.71, // Pass dynamic height
                                  ),
                          ),
                          const SizedBox(height: 0),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [_buildLogo(textColor), const LanguageToggle()],
      ),
    );
  }

  Widget _buildLogo(Color textColor) {
    return Row(
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: textColor,
            ),
            children: const [
              TextSpan(text: "STEM"),
              TextSpan(text: "X", style: TextStyle(fontSize: 30)),
              TextSpan(text: "plore "),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Color(0xFFFF9E00),
            shape: BoxShape.circle,
          ),
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 16,
              ),
              children: [
                TextSpan(text: "F", style: TextStyle(fontSize: 22)),
                TextSpan(text: "2", style: TextStyle(fontSize: 30)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightsSection(
    bool isEnglish,
    bool isTablet,
    Color textColor,
    bool isDark,
    double cardHeight, // Add this parameter
  ) {
    if (highlights.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 3, top: 8),
          child: Text(
            translate('highlights', isEnglish),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: textColor,
            ),
          ),
        ),
        SizedBox(
          height: cardHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: highlights.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 5,
                ),
                child: _buildHighlightCard(
                  context,
                  highlights[index],
                  isEnglish,
                  isDark,
                  isTablet,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightCard(
    BuildContext context,
    Highlight h,
    bool isEnglish,
    bool isDark,
    bool isTablet,
  ) {
    return GestureDetector(
      onTap: () async {
        _autoScrollTimer?.cancel();
        await widget.onHighlightTap(h);
        if (mounted) _startAutoScroll();
      },
      child: Container(
        width: isTablet ? 320 : 280,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF535252) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? [] : appBoxShadow,
          border: isDark ? Border.all(color: Colors.white10) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Image.asset(
                h.image1Url.startsWith('/')
                    ? h.image1Url.substring(1)
                    : h.image1Url,
                width: isTablet ? 130 : 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 110,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnglish ? h.titleEn : h.titleMs,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 17 : 15,
                        height: 1.1,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Expanded(
                      child: Text(
                        isEnglish ? h.subtitleEn : h.subtitleMs,
                        style: TextStyle(
                          color: isDark ? Colors.white60 : Colors.black54,
                          fontSize: isTablet ? 14 : 13,
                        ),
                        maxLines: isTablet ? 4 : 2, //small phones
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        translate('readMore', isEnglish),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
