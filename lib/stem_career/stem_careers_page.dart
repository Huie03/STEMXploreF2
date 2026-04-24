import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/widgets/gradient_background.dart';
import '/widgets/language_toggle.dart';
import '/widgets/rawscrollbar.dart';
import '/theme_provider.dart';
import '/navigation_provider.dart';
import '/widgets/box_shadow.dart';
import '/stem_career/career_quiz.dart';
import '/stem_career/career_logic.dart';
import '/full_screen_image_page.dart';
import '/database_helper.dart';

class StemCareersPage extends StatefulWidget {
  static const routeName = '/stem-careers';
  const StemCareersPage({super.key});

  @override
  State<StemCareersPage> createState() => _StemCareersPageState();
}

class _StemCareersPageState extends State<StemCareersPage> with CareerLogic {
  bool _showQuiz = false,
      _showResults = false,
      _isExploreAllMode = false,
      _isLoading = true,
      _isAlreadyReset = false;
  String? _errorMessage;
  int _expandedIndex = -1;
  final ScrollController _scrollController = ScrollController(),
      _exploreScrollController = ScrollController();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void dispose() {
    _scrollController.dispose();
    _exploreScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Provider.of<NavigationProvider>(context).currentIndex == 7 &&
        !_isAlreadyReset) {
      _resetState();
      _isAlreadyReset = true;
    } else if (Provider.of<NavigationProvider>(context).currentIndex != 7) {
      _isAlreadyReset = false;
    }
  }

  void _resetState() => setState(() {
    _showQuiz = _showResults = _isExploreAllMode = false;
    _expandedIndex = -1;
    resetLogicState();
  });

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> rawQuestions = await db.query(
        'stem_questions',
      );
      final List<Map<String, dynamic>> rawOptions = await db.query(
        'stem_options',
      );

      final List<Map<String, dynamic>> structuredQuestions = rawQuestions.map((
        q,
      ) {
        return {
          'id': q['id'].toString(),
          'q_text_en': q['q_text_en'],
          'q_text_ms': q['q_text_ms'],
          'options': rawOptions
              .where(
                (opt) => opt['question_id'].toString() == q['id'].toString(),
              )
              .map(
                (opt) => {
                  'id': opt['id'].toString(),
                  'opt_text_en': opt['opt_text_en'],
                  'opt_text_ms': opt['opt_text_ms'],
                  'score_tag': opt['score_tag']?.toString(),
                },
              )
              .toList(),
        };
      }).toList();

      final List<Map<String, dynamic>> careers = await db.query('stem_careers');

      if (mounted) {
        setState(() {
          dbQuestions = structuredQuestions;
          allCareers = careers;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("SQLite Error: $e");
      _handleLoadError("Database Error!\nUnable to load offline career data.");
    }
  }

  void _handleLoadError(String msg) => setState(() {
    _errorMessage = msg;
    _isLoading = false;
  });

  Color _getStemColor(String? cat, BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return switch (cat) {
      'Science' => isDark ? Colors.greenAccent.shade400 : Colors.green.shade700,
      'Technology' =>
        isDark ? Colors.blueAccent.shade200 : Colors.blue.shade700,
      'Engineering' =>
        isDark ? Colors.orangeAccent.shade200 : Colors.orange.shade700,
      'Mathematics' =>
        isDark ? Colors.purpleAccent.shade100 : Colors.purple.shade700,
      _ => isDark ? Colors.grey.shade400 : Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final nav = Provider.of<NavigationProvider>(context);
    final bool isEn = nav.locale.languageCode == 'en',
        isDark = Theme.of(context).brightness == Brightness.dark;

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;
    final double verticalGap = isTablet ? 3 : 5;
    final double responsiveRatio = isTablet ? 10 : 10;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(isEn, isDark),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildBody(
                    isEn,
                    context,
                    isTablet,
                    verticalGap,
                    responsiveRatio,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isEn, bool isDark) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 5, 16, 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isEn ? 'STEM Career' : 'Kerjaya STEM',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const LanguageToggle(),
      ],
    ),
  );

  Widget _buildBody(
    bool isEn,
    BuildContext context,
    bool isTablet,
    double verticalGap,
    double responsiveRatio,
  ) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null && (_showQuiz || _isExploreAllMode)) {
      return _buildErrorState(isEn);
    }
    if (_isExploreAllMode) return _buildExploreAllView(isEn, context);
    if (_showResults) return _buildResultsView(isEn, context);
    return _showQuiz
        ? _buildFullQuiz(isEn, context, isTablet, verticalGap, responsiveRatio)
        : _buildStartCard(isEn, context);
  }

  Widget _buildErrorState(bool isEn) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_errorMessage!, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        StemQuizDesign.actionButton(
          context,
          isEn ? "Try Again" : "Cuba Lagi",
          _loadData,
        ),
      ],
    ),
  );

  Widget _buildStartCard(bool isEn, BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: StemQuizDesign.buildContainer(
        context: context,
        margin: const EdgeInsets.symmetric(horizontal: 35),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEn
                  ? "Discover Your STEM Skills & Explore Careers"
                  : "Temui Kemahiran STEM & Teroka Kerjaya",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isEn
                  ? "Answer questions to see which STEM\nfield fits you best."
                  : "Jawab soalan untuk melihat bidang STEM\nyang paling sesuai untuk anda.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 25),
            StemQuizDesign.actionButton(
              context,
              isEn ? "Start" : "Mula",
              () => setState(() => _showQuiz = true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullQuiz(
    bool isEn,
    BuildContext context,
    bool isTablet,
    double verticalGap,
    double responsiveRatio,
  ) {
    if (dbQuestions.length < 5) {
      return const Center(child: Text("Loading career questions..."));
    }

    final progress =
        (singleChoices.length + (multiChoicesQ5.isNotEmpty ? 1 : 0)) / 5;
    return StemQuizDesign.buildContainer(
      context: context,
      child: Column(
        children: [
          _buildProgressBar(isEn, progress, context),
          Expanded(
            child: AppRawScrollbar(
              controller: _scrollController,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...dbQuestions
                          .sublist(0, 4)
                          .map(
                            (q) => _buildQuestion(
                              q,
                              isEn,
                              context,
                              false,
                              isTablet,
                              verticalGap,
                              responsiveRatio,
                            ),
                          ),
                      _buildQuestion(
                        dbQuestions[4],
                        isEn,
                        context,
                        true,
                        isTablet,
                        verticalGap,
                        responsiveRatio,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: StemQuizDesign.actionButton(
              context,
              isEn ? "Done" : "Selesai",
              (singleChoices.length == 4 && multiChoicesQ5.isNotEmpty)
                  ? () => _handleCompletion(isEn)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(
    Map q,
    bool isEn,
    BuildContext context,
    bool isMulti,
    bool isTablet,
    double verticalGap,
    double responsiveRatio,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    int qId = int.parse(q['id'].toString());
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEn ? q['q_text_en'] : q['q_text_ms'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          if (isMulti)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 2 : 1,
                mainAxisSpacing: verticalGap,
                crossAxisSpacing: 15,
                childAspectRatio: responsiveRatio,
              ),
              itemCount: (q['options'] as List).length,
              itemBuilder: (c, i) => _optionRow(
                q['options'][i],
                isEn,
                context,
                multiChoicesQ5.contains(
                  int.parse(q['options'][i]['id'].toString()),
                ),
                () => setState(() {
                  int id = int.parse(q['options'][i]['id'].toString());
                  multiChoicesQ5.contains(id)
                      ? multiChoicesQ5.remove(id)
                      : multiChoicesQ5.add(id);
                }),
              ),
            )
          else
            ...(q['options'] as List).map(
              (opt) => _optionRow(
                opt,
                isEn,
                context,
                singleChoices[qId] == int.parse(opt['id'].toString()),
                () => setState(
                  () => singleChoices[qId] = int.parse(opt['id'].toString()),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _optionRow(
    Map opt,
    bool isEn,
    BuildContext context,
    bool selected,
    VoidCallback onTap,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color activeColor = const Color(0xFFF19100);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: selected
                  ? activeColor
                  : (isDark ? Colors.white38 : Colors.black54),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isEn ? opt['opt_text_en'] : opt['opt_text_ms'],
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.visible,
                style: TextStyle(
                  fontSize: 15,
                  color: selected
                      ? activeColor
                      : (isDark ? Colors.white : Colors.black),
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsView(bool isEn, BuildContext context) {
    final fieldEn = calculateSuggestedField();
    final filtered = allCareers
        .where((c) => c['category_en'] == fieldEn)
        .toList();
    return SingleChildScrollView(
      child: StemQuizDesign.buildContainer(
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
            _suggestedHeader(isEn, fieldEn, _getStemColor(fieldEn, context)),
            const SizedBox(height: 15),
            ...filtered.asMap().entries.map(
              (e) => _careerTile(e.value, e.key, isEn, context),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StemQuizDesign.actionButton(
                  context,
                  isEn ? "Explore All" : "Teroka Semua",
                  () => setState(() {
                    _isExploreAllMode = true;
                    _expandedIndex = -1;
                  }),
                ),
                StemQuizDesign.actionButton(
                  context,
                  isEn ? "Replay" : "Main Semula",
                  _resetState,
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
        StemQuizDesign.careerExpandableTile(
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

  Widget _buildExploreAllView(bool isEn, BuildContext context) {
    List sorted = List.from(allCareers)
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
    return StemQuizDesign.buildContainer(
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
            child: StemQuizDesign.actionButton(
              context,
              isEn ? "Exit" : "Keluar",
              () => setState(() {
                _isExploreAllMode = false;
                _expandedIndex = -1;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(bool isEn, double progress, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isEn ? "Progress" : "Kemajuan",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              "${(progress * 100).toInt()}%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          backgroundColor: isDark ? Colors.white10 : Colors.grey.shade300,
          color: Colors.green,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _catHeader(String name, String raw) {
    final color = _getStemColor(raw, context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1.2,
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
    String? assetPath = isEn ? career['image_en'] : career['image_ms'];
    if (assetPath == null || assetPath.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _showFullMindMap(context, assetPath),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFD9D9D9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Hero(
            tag: assetPath,
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.broken_image, color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  void _showFullMindMap(BuildContext context, String assetPath) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, _, _) =>
            FullScreenImagePage(assetPath: assetPath),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _handleCompletion(bool isEn) {
    if (multiChoicesQ5.length < 3) {
      final bool isDark = Provider.of<ThemeProvider>(
        context,
        listen: false,
      ).isDarkMode;
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF3D3D3D) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: isDark ? [] : appBoxShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, color: Colors.red, size: 40),
                const SizedBox(height: 15),
                Text(
                  isEn
                      ? "Please select at least 3 skills in question 5."
                      : "Sila pilih sekurang-kurangnya 3 kemahiran dalam soalan 5.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 25),
                StemQuizDesign.actionButton(
                  context,
                  "OK",
                  () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      setState(() {
        _showResults = true;
        _expandedIndex = -1;
      });
    }
  }
}
