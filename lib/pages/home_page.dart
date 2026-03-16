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
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../ipaddress.dart';

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

  //final double _stepSize = 320.0;

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

    _fetchHighlights();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final navProvider = Provider.of<NavigationProvider>(context);
    if (navProvider.currentIndex == 0) {
      _startAutoScroll();
    } else {
      _autoScrollTimer?.cancel();
    }
  }

  Future<void> _fetchHighlights() async {
    try {
      final response = await http.get(
        Uri.parse("${ipadress.baseUrl}get_highlights.php"),
      );
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        setState(() {
          highlights = body
              .map((dynamic item) => Highlight.fromJson(item))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching highlights: $e");
      setState(() => isLoading = false);
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || _isUserScrolling || !_pageController.hasClients) return;
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
    final themeProvider = Provider.of<ThemeProvider>(context); // ADDED
    final bool isDark = themeProvider.isDarkMode;
    final bool isEnglish = navProvider.locale.languageCode == 'en';
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      Flexible(
                        flex: 3,
                        child: GridView.count(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                          childAspectRatio: 1.2,
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
                      const SizedBox(height: 25),
                      Divider(
                        thickness: 2,
                        height: 1,
                        color: isDark ? Colors.white : Colors.black12,
                      ),
                      isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            )
                          : _buildHighlightsSection(
                              isEnglish,
                              isTablet,
                              textColor,
                              isDark,
                            ),
                    ],
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
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
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
            children: [
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
  ) {
    if (highlights.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 6, bottom: 4),
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
          height: 190,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification)
                _isUserScrolling = true;
              if (notification is ScrollEndNotification)
                _isUserScrolling = false;
              return false;
            },
            child: PageView.builder(
              key: const PageStorageKey('home_highlights_pageview'),
              controller: _pageController,
              onPageChanged: (index) {
                // Save the page index whenever it changes
                PageStorage.of(context).writeState(
                  context,
                  index.toDouble(),
                  identifier: const PageStorageKey('home_page_controller'),
                );
              },
              itemCount: highlights.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 10,
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
        // 1. Stop the timer so it doesn't try to scroll while the page is hidden
        _autoScrollTimer?.cancel();

        // 2. Trigger the navigation and WAIT for the user to come back
        // (Assuming onHighlightTap performs a Navigator.push)
        await widget.onHighlightTap(h);

        // 3. This line will ONLY run once the user returns to the HomePage
        if (mounted) {
          _startAutoScroll();
        }
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
              child: Builder(
                builder: (context) {
                  final String base = ipadress.baseUrl;
                  final String imageUrl = base.endsWith('/')
                      ? '$base${h.image1Url}'
                      : '$base/${h.image1Url}';
                  // 3. Remove accidental double-slashes if they exist
                  final String finalUrl = imageUrl.replaceFirst(
                    '//assets',
                    '/assets',
                  );
                  debugPrint("DEBUG: Final Cleaned URL: $finalUrl");
                  return Image.network(
                    finalUrl,
                    width: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 130,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      );
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnglish ? h.titleEn : h.titleMs,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        height: 1.2,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnglish
                          ? h.subtitleEn
                          : h.subtitleMs, // <--- Add this ternary check
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 13,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        translate('readMore', isEnglish),
                        style: TextStyle(
                          color: isDark ? Colors.red : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
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
