import 'package:flutter/material.dart';
import 'package:stemxploref2/widgets/rawscrollbar.dart';
import 'package:stemxploref2/full_screen_image.dart';
import 'package:provider/provider.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:stemxploref2/widgets/box_shadow.dart';
import 'package:stemxploref2/stem_career/career_content.dart';

class CareerResultView extends StatefulWidget {
  final bool isEn;
  final List<Map<String, dynamic>> allCareers;
  final String suggestedField;
  final bool isExploreAllMode;
  final VoidCallback onExploreAllPressed;
  final VoidCallback onRetryPressed;
  final VoidCallback onExitPressed;
  final Color Function(String?, BuildContext) getStemColor;

  const CareerResultView({
    super.key,
    required this.isEn,
    required this.allCareers,
    required this.suggestedField,
    required this.isExploreAllMode,
    required this.onExploreAllPressed,
    required this.onRetryPressed,
    required this.onExitPressed,
    required this.getStemColor,
  });

  @override
  State<CareerResultView> createState() => _CareerResultViewState();
}

class _CareerResultViewState extends State<CareerResultView> {
  int _expandedIndex = -1;
  final ScrollController _exploreScrollController = ScrollController();

  @override
  void dispose() {
    _exploreScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isExploreAllMode) {
      return _buildExploreAllView(widget.isEn, context);
    }
    return _buildResultsView(widget.isEn, context);
  }

  Widget _buildResultsView(bool isEn, BuildContext context) {
    final fieldEn = widget.suggestedField;
    final filtered = widget.allCareers
        .where((c) => c['category_en'] == fieldEn)
        .toList();
    return SingleChildScrollView(
      child: CareerQuizContent.buildContainer(
        context: context,
        child: Column(
          children: [
            Text(
              isEn
                  ? "You’ve Finished Your\nCareer Discovery!"
                  : "Anda Telah Menamatkan\nPenemuan Kerjaya Anda!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
            const SizedBox(height: 25),
            _suggestedHeader(
              isEn,
              fieldEn,
              widget.getStemColor(fieldEn, context),
            ),
            const SizedBox(height: 15),
            ...filtered.asMap().entries.map(
              (e) => _careerTile(e.value, e.key, isEn, context),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CareerQuizContent.actionButton(
                  context,
                  isEn ? "Explore All" : "Teroka Semua",
                  () {
                    setState(() => _expandedIndex = -1);
                    widget.onExploreAllPressed();
                  },
                ),
                CareerQuizContent.actionButton(
                  context,
                  isEn ? "Retry" : "Cuba Semula",
                  widget.onRetryPressed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _careerTile(Map career, int index, bool isEn, BuildContext context) {
    final bool isExpanded = _expandedIndex == index;
    return Column(
      children: [
        _buildExpandableTile(
          context,
          isEn ? career['career_en'] : career['career_ms'],
          isExpanded,
          () => setState(() => _expandedIndex = isExpanded ? -1 : index),
        ),
        if (isExpanded) _mindMap(career, isEn),
        const SizedBox(height: 12),
      ],
    );
  }

  static Widget _buildExpandableTile(
    BuildContext context,
    String title,
    bool isExpanded,
    VoidCallback onTap,
  ) {
    final bool isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? const Color.fromARGB(255, 76, 75, 75)
              : const Color(0xFFEBEBEB),
          borderRadius: BorderRadius.circular(12),
          border: isDark ? Border.all(color: Colors.white10) : null,
          boxShadow: isDark ? [] : appBoxShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 26,
              color: isDark
                  ? const Color.fromARGB(179, 255, 255, 255)
                  : Colors.black87,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreAllView(bool isEn, BuildContext context) {
    List sorted = List.from(widget.allCareers)
      ..sort(
        (a, b) => ['Science', 'Technology', 'Engineering', 'Mathematics']
            .indexOf(a['category_en'])
            .compareTo(
              [
                'Science',
                'Technology',
                'Engineering',
                'Mathematics',
              ].indexOf(b['category_en']),
            ),
      );
    return CareerQuizContent.buildContainer(
      context: context,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      child: Column(
        children: [
          Expanded(
            child: AppRawScrollbar(
              controller: _exploreScrollController,
              child: ListView.builder(
                controller: _exploreScrollController,
                padding: const EdgeInsets.only(right: 5),
                itemCount: sorted.length,
                itemBuilder: (c, i) {
                  final career = sorted[i];
                  final String catEn = career['category_en'] ?? '';
                  final String catMs = career['category_ms'] ?? catEn;
                  bool showHeader =
                      i == 0 || catEn != sorted[i - 1]['category_en'];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showHeader) _catHeader(isEn ? catEn : catMs, catEn),
                      _careerTile(career, i, isEn, context),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.bottomRight,
            child: CareerQuizContent.actionButton(
              context,
              isEn ? "Exit" : "Keluar",
              widget.onExitPressed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _catHeader(String name, String raw) {
    final color = widget.getStemColor(raw, context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name.toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 3,
            width: 35,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _suggestedHeader(bool isEn, String field, Color color) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            fontSize: 18,
          ),
          children: [
            TextSpan(text: isEn ? "Suggest field: " : "Bidang dicadangkan: "),
            TextSpan(
              text: field,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mindMap(Map career, bool isEn) {
    String? imagePath = isEn ? career['image_en'] : career['image_ms'];
    if (imagePath == null || imagePath.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _showFullScreenImage(context, imagePath),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Hero(
                tag: imagePath,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, color: Colors.red),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.zoom_out_map,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, _, _) => FullScreenImage(assetPath: imagePath),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}
