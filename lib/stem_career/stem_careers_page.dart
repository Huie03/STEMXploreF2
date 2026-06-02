import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stemxploref2/widgets/gradient_background.dart';
import 'package:stemxploref2/widgets/language_toggle.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:stemxploref2/navigation_provider.dart';
import 'package:stemxploref2/widgets/box_shadow.dart';
import 'package:stemxploref2/stem_career/career_logic.dart';
import 'package:stemxploref2/stem_career/career_content.dart';
import 'package:stemxploref2/stem_career/career_result.dart';
import 'package:stemxploref2/database_helper.dart';

class StemCareersPage extends StatefulWidget {
  static const routeName = '/stem-careers';
  final VoidCallback? onExit;

  const StemCareersPage({super.key, this.onExit});

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

  final ScrollController _scrollController = ScrollController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void dispose() {
    _scrollController.dispose();
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

  Widget _buildStartCard(bool isEn, BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: CareerQuizContent.buildContainer(
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
                fontSize: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 25),
            CareerQuizContent.actionButton(
              context,
              isEn ? "Start" : "Mula",
              () => setState(() => _showQuiz = true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(bool isEn) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_errorMessage!, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        CareerQuizContent.actionButton(
          context,
          isEn ? "Try Again" : "Cuba Lagi",
          _loadData,
        ),
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

    if (_showResults || _isExploreAllMode) {
      return CareerResultView(
        isEn: isEn,
        allCareers: List<Map<String, dynamic>>.from(allCareers),
        suggestedField: calculateSuggestedField(),
        isExploreAllMode: _isExploreAllMode,
        getStemColor: _getStemColor,
        onExploreAllPressed: () => setState(() => _isExploreAllMode = true),
        onRetryPressed: _resetState,
        onExitPressed: () => widget.onExit?.call(),
      );
    }

    return _showQuiz
        ? CareerQuizContent(
            dbQuestions: dbQuestions,
            isEn: isEn,
            isTablet: isTablet,
            verticalGap: verticalGap,
            responsiveRatio: responsiveRatio,
            singleChoices: singleChoices,
            multiChoicesQ5: multiChoicesQ5,
            scrollController: _scrollController,
            onCompletionPressed: () => _handleCompletion(isEn),
            onSingleChoiceSelected: (qId, optId) {
              setState(() => singleChoices[qId] = optId);
            },
            onMultiChoiceToggled: (optId) {
              setState(() {
                if (multiChoicesQ5.contains(optId)) {
                  multiChoicesQ5.remove(optId);
                } else {
                  multiChoicesQ5.add(optId);
                }
              });
            },
          )
        : _buildStartCard(isEn, context);
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
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 25),
                CareerQuizContent.actionButton(
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
      });
    }
  }
}
