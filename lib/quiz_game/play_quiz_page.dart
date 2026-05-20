import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:stemxploref2/widgets/gradient_background.dart';
import 'package:stemxploref2/widgets/box_shadow.dart';
import 'package:stemxploref2/widgets/language_toggle.dart';
import 'package:stemxploref2/navigation_provider.dart';
import 'package:stemxploref2/quiz_game/quiz_ui.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:stemxploref2/widgets/rawscrollbar.dart';
import 'package:stemxploref2/full_screen_image_page.dart';
import 'package:stemxploref2/database_helper.dart';

class PlayQuizPage extends StatefulWidget {
  final String subjectAndMode;
  final VoidCallback onFinish;

  const PlayQuizPage({
    super.key,
    required this.subjectAndMode,
    required this.onFinish,
  });

  @override
  State<PlayQuizPage> createState() => _PlayQuizPageState();
}

class _PlayQuizPageState extends State<PlayQuizPage> {
  late ConfettiController _confettiController;
  final ScrollController _quizScrollController = ScrollController();
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Initialize DB Helper

  List<dynamic> _questions = [];
  bool _isLoading = true;
  bool _showResults = false;
  String? _errorMessage;

  int _currentQuestionIndex = 0;
  int _score = 0;
  late String _subject;
  late String _chapterId;
  late String _titleEn;
  late String _titleMs;

  int? _selectedOptionIndex;
  bool _isLocked = false;
  bool _isReviewMode = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.setVolume(1.0);
    _resetAndStartQuiz();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    _quizScrollController.dispose();
    super.dispose();
  }

  void _resetAndStartQuiz() {
    setState(() {
      _showResults = false;
      _questions = [];
      _isLoading = true;
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedOptionIndex = null;
      _isLocked = false;
      _isReviewMode = false;
      _errorMessage = null;
    });
    _parseParams();
    _fetchQuestions();
  }

  void _parseParams() {
    final parts = widget.subjectAndMode.split('|');

    if (parts.length >= 3) {
      String rawSubject = parts[0].trim();

      if (rawSubject == "4" || rawSubject.contains("Design And Technology")) {
        _subject = "RBT";
      } else if (rawSubject == "3" || rawSubject.contains("Computer Science")) {
        _subject = "ASK";
      } else if (rawSubject == "2") {
        _subject = "Mathematics";
      } else if (rawSubject == "1") {
        _subject = "Science";
      } else {
        _subject = rawSubject;
      }

      _titleEn = parts[1].trim();
      _titleMs = parts[2].trim();

      final RegExp numRegex = RegExp(r'\d+');
      final match = numRegex.firstMatch(_titleEn);

      if (match != null) {
        _chapterId = match.group(0)!;
      } else {
        _chapterId = "1";
      }
    } else {
      _titleEn = "Quiz Game";
      _titleMs = "Permainan Kuiz";
      _subject = "Science";
      _chapterId = "1";
    }

    debugPrint(
      "Fixed Query Params -> Subject: $_subject, Chapter: $_chapterId",
    );
  }

  Future<void> _fetchQuestions() async {
    try {
      if (_chapterId.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Invalid Chapter ID";
        });
        return;
      }

      final int id = int.parse(_chapterId);

      final List<Map<String, dynamic>> results = await _dbHelper
          .getQuizQuestions(_subject, id);

      if (mounted) {
        setState(() {
          _questions = List.from(results);
          _questions.shuffle();
          _isLoading = false;
        });

        if (_questions.isNotEmpty) {
          _startBackgroundMusic();
        } else {
          setState(
            () => _errorMessage =
                "No questions found locally for $_subject Chapter $id.",
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Database Error: ${e.toString()}";
        });
      }
    }
  }

  Future<void> _startBackgroundMusic() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    if (!themeProvider.isSoundEnabled) return;
    if (_audioPlayer.state == PlayerState.playing) return;

    try {
      // Setting the Global Audio Context for Android Focus
      await AudioPlayer.global.setAudioContext(
        const AudioContext(
          android: AudioContextAndroid(
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gain,
          ),
        ),
      );

      await _audioPlayer.setReleaseMode(ReleaseMode.loop);

      // Play using AssetSource
      await _audioPlayer.play(AssetSource('audio/quiz_bm.music.mp3'));

      debugPrint("Android Audio started.");
    } catch (e) {
      debugPrint("Android Audio Error: $e");
    }
  }

  void _stopMusic() {
    _audioPlayer.stop();
  }

  void _handleAnswer(int selectedIndex, int correctIndex) {
    if (_isLocked || _isReviewMode) return;
    setState(() {
      _selectedOptionIndex = selectedIndex;
      _isLocked = true;
      if (selectedIndex == correctIndex) _score++;
      _questions[_currentQuestionIndex] = Map<String, dynamic>.from(
        _questions[_currentQuestionIndex],
      );
      _questions[_currentQuestionIndex]['user_choice'] = selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final bool isEnglish = navProvider.locale.languageCode == 'en';
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (!themeProvider.isSoundEnabled) {
      _stopMusic();
    } else if (_questions.isNotEmpty &&
        _audioPlayer.state != PlayerState.playing &&
        !_isLoading) {
      _startBackgroundMusic();
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _stopMusic();
          widget.onFinish();
        }
      },
      child: Scaffold(
        body: GradientBackground(
          child: SafeArea(
            child: Column(
              children: [
                QuizUi.buildAppBar(
                  context: context,
                  title: isEnglish ? _titleEn : _titleMs,
                  languageToggle: const LanguageToggle(),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : _isReviewMode // Add this check!
                      ? _buildReviewList(isEnglish)
                      : _showResults
                      ? QuizUi.buildResultsView(
                          context: context,
                          score: _score,
                          total: _questions.length,
                          isEnglish: isEnglish,
                          confettiController: _confettiController,
                          onReplay: _resetAndStartQuiz,
                          onReview: _viewReview,
                          onExit: () {
                            _stopMusic();
                            widget.onFinish();
                          },
                        )
                      : (_errorMessage != null
                            ? _buildError()
                            : AppRawScrollbar(
                                controller: _quizScrollController,
                                child: _buildQuizContent(isEnglish),
                              )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizContent(bool isEnglish) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color cardBg = Theme.of(context).colorScheme.surface;
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    final q = _questions[_currentQuestionIndex];

    final List<Map<String, String>> optionData = [
      {
        'text': isEnglish ? (q['opt_a_en'] ?? "") : (q['opt_a_ms'] ?? ""),
        'image': q['opt_a_image']?.toString() ?? "",
      },
      {
        'text': isEnglish ? (q['opt_b_en'] ?? "") : (q['opt_b_ms'] ?? ""),
        'image': q['opt_b_image']?.toString() ?? "",
      },
      {
        'text': isEnglish ? (q['opt_c_en'] ?? "") : (q['opt_c_ms'] ?? ""),
        'image': q['opt_c_image']?.toString() ?? "",
      },
      {
        'text': isEnglish ? (q['opt_d_en'] ?? "") : (q['opt_d_ms'] ?? ""),
        'image': q['opt_d_image']?.toString() ?? "",
      },
    ];

    bool usesImageOptions = optionData.any((opt) => opt['image']!.isNotEmpty);
    final int? activeSelection = _isReviewMode
        ? q['user_choice']
        : _selectedOptionIndex;
    final bool showFeedback = _isLocked || _isReviewMode;

    String rawLetter =
        q['correct_option']?.toString().trim().toUpperCase() ?? "";
    int correctIndex = "ABCD".indexOf(rawLetter);
    if (correctIndex == -1) correctIndex = 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          controller: _quizScrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: appBoxShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${isEnglish ? "Question" : "Soalan"} ${_currentQuestionIndex + 1}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              "${_currentQuestionIndex + 1} / ${_questions.length}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isEnglish
                              ? (q['question_text_en'] ?? "")
                              : (q['question_text_ms'] ?? ""),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            height: 1.4,
                          ),
                        ),
                        if (q['question_image'] != null &&
                            q['question_image'].isNotEmpty) ...[
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => _showFullScreenImage(
                              context,
                              q['question_image'],
                            ),
                            child: Center(
                              child: Hero(
                                tag: q['question_image'],
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    q['question_image'],
                                    height: 150,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.broken_image,
                                      size: 50,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (usesImageOptions)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 180,
                          ),
                      itemCount: 4,
                      itemBuilder: (context, i) => QuizUi.buildOptionTile(
                        context: context,
                        index: i,
                        text: optionData[i]['text']!,
                        imageUrl: optionData[i]['image']!,
                        correctIndex: correctIndex,
                        selectedIndex: activeSelection,
                        showFeedback: showFeedback,
                        onTap: () => _handleAnswer(i, correctIndex),
                      ),
                    )
                  else
                    ...List.generate(
                      4,
                      (i) => QuizUi.buildOptionTile(
                        context: context,
                        index: i,
                        text: optionData[i]['text']!,
                        correctIndex: correctIndex,
                        selectedIndex: activeSelection,
                        showFeedback: showFeedback,
                        onTap: () => _handleAnswer(i, correctIndex),
                      ),
                    ),
                  const SizedBox(height: 25),
                  _buildNavButtons(isEnglish),
                  if (showFeedback) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.5)
                              : Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            isEnglish ? "Explanation:" : "Penerangan:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isEnglish
                                ? (q['explanation_en'] ??
                                      "No explanation available.")
                                : (q['explanation_ms'] ??
                                      "Tiada penerangan tersedia."),
                            style: TextStyle(
                              fontSize: 15,
                              color: textColor,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavButtons(bool isEng) {
    // Check if we are at the very first question
    bool isFirstQuestion = _currentQuestionIndex == 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _btn(isEng ? "Back" : "Kembali", () {
          if (isFirstQuestion) {
            _audioPlayer.stop();
            widget.onFinish();

            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              debugPrint(
                "No history to pop, staying on page or triggering onFinish.",
              );
            }
          } else {
            setState(() {
              _currentQuestionIndex--;
              _selectedOptionIndex =
                  _questions[_currentQuestionIndex]['user_choice'];
              _isLocked = true;
            });
          }
        }),

        _btn(
          _currentQuestionIndex < _questions.length - 1
              ? (isEng ? "Next" : "Seterusnya")
              : (isEng ? "Finish" : "Selesai"),
          () {
            if (_currentQuestionIndex < _questions.length - 1) {
              setState(() {
                _currentQuestionIndex++;
                _selectedOptionIndex =
                    _questions[_currentQuestionIndex]['user_choice'];
                _isLocked = _selectedOptionIndex != null;
              });
              _quizScrollController.jumpTo(0);
            } else {
              _triggerResults();
            }
          },
          enabled: _isLocked,
        ),
      ],
    );
  }

  Widget _btn(String label, VoidCallback onTap, {bool enabled = true}) {
    return SizedBox(
      width: 120,
      height: 45,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEB9000),
          disabledBackgroundColor: const Color.fromARGB(255, 201, 201, 201),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _triggerResults() {
    _stopMusic();
    setState(() => _showResults = true);
    _confettiController.play();
  }

  void _viewReview() {
    setState(() {
      _showResults = false;
      _isReviewMode = true;
      _currentQuestionIndex = 0;
      _selectedOptionIndex = _questions[0]['user_choice'];
    });
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, _, _) =>
            FullScreenImagePage(assetPath: imagePath),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Widget _buildError() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 60, color: Colors.white),
        Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        ElevatedButton(
          onPressed: _resetAndStartQuiz,
          child: const Text("Try Again"),
        ),
      ],
    ),
  );

  Widget _buildReviewList(bool isEng) {
    return Column(
      children: [
        // Stats Header
        Padding(
          padding: const EdgeInsets.fromLTRB(25, 0, 20, 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${isEng ? "Score" : "Markah"}: $_score/${_questions.length}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final q = _questions[index];
              final int correctIdx = "ABCD".indexOf(q['correct_option'] ?? "A");
              final int userIdx = q['user_choice'] ?? -1;

              final List<Map<String, String>> opts = [
                {
                  't': isEng ? q['opt_a_en'] : q['opt_a_ms'],
                  'img': q['opt_a_image'] ?? "",
                },
                {
                  't': isEng ? q['opt_b_en'] : q['opt_b_ms'],
                  'img': q['opt_b_image'] ?? "",
                },
                {
                  't': isEng ? q['opt_c_en'] : q['opt_c_ms'],
                  'img': q['opt_c_image'] ?? "",
                },
                {
                  't': isEng ? q['opt_d_en'] : q['opt_d_ms'],
                  'img': q['opt_d_image'] ?? "",
                },
              ];

              bool usesImages = opts.any((o) => o['img']!.isNotEmpty);

              return Column(
                children: [
                  QuizUi.buildReviewCard(
                    context: context,
                    index: index,
                    isEnglish: isEng,
                    isCorrect: userIdx == correctIdx,
                    question: isEng
                        ? q['question_text_en']
                        : q['question_text_ms'],
                    questionImageUrl: q['question_image'],
                    userAnswer: userIdx != -1 ? opts[userIdx]['t']! : "N/A",
                    correctAnswer: opts[correctIdx]['t']!,
                    explanation: isEng
                        ? q['explanation_en']
                        : q['explanation_ms'],
                    optionsWidget: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: usesImages ? 460 : 380,
                      ),
                      child: usesImages
                          ? GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    mainAxisExtent: 200,
                                  ),
                              itemCount: 4,
                              itemBuilder: (context, i) => QuizUi.buildOptionTile(
                                context: context,
                                index: i,
                                text: opts[i]['t']!,
                                imageUrl: opts[i]['img'],
                                correctIndex: correctIdx,
                                selectedIndex: userIdx,
                                showFeedback:
                                    true, // This enables the borders in QuizUi
                                onTap: () {}, // Disable taps in review
                              ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                4,
                                (i) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: QuizUi.buildOptionTile(
                                    context: context,
                                    index: i,
                                    text: opts[i]['t']!,
                                    imageUrl: opts[i]['img'],
                                    correctIndex: correctIdx,
                                    selectedIndex: userIdx,
                                    showFeedback:
                                        true, // This enables the borders in QuizUi
                                    onTap: () {},
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (index == _questions.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30, top: 10),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: _btn(isEng ? "EXIT" : "KELUAR", () {
                          _audioPlayer.stop();
                          widget.onFinish();
                          if (Navigator.canPop(context)) Navigator.pop(context);
                        }),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
