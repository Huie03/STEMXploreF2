import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localization/flutter_localization.dart';
import '/navigation_provider.dart';
import '/widgets/gradient_background.dart';
import '/widgets/language_toggle.dart';
import '/stem_highlights/highlight.dart';
import '/widgets/feature_button.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';
  final Function(Highlight) onHighlightTap;

  const HomePage({super.key, required this.onHighlightTap});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Highlight> highlights = sampleHighlights;
  final ScrollController _scrollController = ScrollController();

  Timer? _autoScrollTimer;
  // Adjusted for standard card sizing
  final double _stepSize = 272.0;

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
    FlutterLocalization.instance.onTranslatedLanguage = _onLanguageChanged;
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_scrollController.hasClients) {
        double maxExtent = _scrollController.position.maxScrollExtent;
        double currentOffset = _scrollController.offset;

        if (currentOffset >= maxExtent - 10) {
          _scrollController.animateTo(
            0,
            duration: const Duration(seconds: 1),
            curve: Curves.easeOutQuart,
          );
        } else {
          _scrollController.animateTo(
            currentOffset + _stepSize,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _onLanguageChanged(Locale? locale) {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
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
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final bool isEnglish =
        FlutterLocalization.instance.currentLocale?.languageCode == 'en';

    // Check screen width
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Center(
                child: Container(
                  // KEY FIX: Limit width on Tablet so 2 columns don't stretch too much
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
                          crossAxisCount: 2, // Fixed at 2 columns as requested
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
                      const SizedBox(height: 20),
                      const Divider(thickness: 1, height: 20),
                      _buildHighlightsSection(isEnglish, isTablet),
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

  Widget _buildHighlightsSection(bool isEnglish, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 6.0, bottom: 12.0),
          child: Text(
            translate('highlights', isEnglish),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 20 : 18,
            ),
          ),
        ),
        SizedBox(
          height: 145,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                _autoScrollTimer?.cancel();
              } else if (notification is ScrollEndNotification) {
                _startAutoScroll();
              }
              setState(() {});
              return true;
            },
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: highlights.length,
              separatorBuilder: (_, __) => const SizedBox(width: 20),
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _scrollController,
                  builder: (context, child) {
                    double cardPosition = 0.0;
                    if (_scrollController.hasClients) {
                      cardPosition =
                          (index * _stepSize) - _scrollController.offset;
                    }
                    double rotation = cardPosition / 1000;
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(rotation),
                      child: child,
                    );
                  },
                  child: _buildHighlightCard(
                    context,
                    highlights[index],
                    isEnglish,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black,
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
                  color: Color(0xFFF2C458),
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
          ),
          LanguageToggle(onLanguageChanged: () => setState(() {})),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(
    BuildContext context,
    Highlight h,
    bool isEnglish,
  ) {
    return GestureDetector(
      onTap: () => widget.onHighlightTap(h),
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Image.asset(
                h.image,
                width: 100,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEnglish ? h.title : h.titleMs,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isEnglish ? h.subtitle : h.subtitleMs,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        translate('readMore', isEnglish),
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
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
