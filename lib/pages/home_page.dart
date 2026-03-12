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

class _HomePageState extends State<HomePage> {
  final List<Highlight> highlights = sampleHighlights;
  final ScrollController _scrollController = ScrollController();
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_scrollController.hasClients) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final bool isTablet = screenWidth > 600;

        double dynamicStepSize = (isTablet ? 320.0 : 280.0) + 15.0;

        double maxExtent = _scrollController.position.maxScrollExtent;
        double currentOffset = _scrollController.offset;

        if (currentOffset >= maxExtent - 10) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutExpo,
          );
        } else {
          double nextTarget =
              ((currentOffset / dynamicStepSize).round() + 1) * dynamicStepSize;

          _scrollController.animateTo(
            nextTarget.clamp(0.0, maxExtent),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOutCubic,
          );
        }
      }
    });
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
                      _buildHighlightsSection(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 6.0, bottom: 4.0),
          child: Text(
            translate('highlights', isEnglish),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 20 : 18,
              color: textColor,
            ),
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 550 : double.infinity,
            ),
            child: SizedBox(
              height: 190,
              child: ListView.separated(
                clipBehavior: Clip.hardEdge,
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),

                padding: const EdgeInsets.symmetric(
                  horizontal: 20, //the space first card
                  vertical: 10,
                ),

                itemCount: highlights.length,
                separatorBuilder: (_, _) => const SizedBox(width: 15),
                itemBuilder: (context, index) => _buildHighlightCard(
                  context,
                  highlights[index],
                  isEnglish,
                  isDark,
                  isTablet,
                ),
              ),
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
      onTap: () => widget.onHighlightTap(h),
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
                h.image,
                width: 105,
                height: double.infinity,
                fit: BoxFit.cover,
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
                      isEnglish ? h.subtitleEn : h.subtitleMs,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontSize: 13,
                      ),
                      maxLines: 2,
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
