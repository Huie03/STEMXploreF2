import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:stemxploref2/widgets/gradient_background.dart';
import 'package:stemxploref2/widgets/language_toggle.dart';
import 'package:stemxploref2/navigation_provider.dart';
import 'package:stemxploref2/quiz_game/quiz_ui.dart';
import 'package:stemxploref2/quiz_game/quiz_content.dart';
import 'package:stemxploref2/quiz_game/quiz_answer.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:stemxploref2/full_screen_image.dart';
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
  final ScrollController _reviewScrollController = ScrollController();
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
    _reviewScrollController.dispose();
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
      await _audioPlayer.play(AssetSource('audio/quiz_bm.music.mp3'));
    } catch (e) {
      debugPrint("Android Audio Error: $e");
    }
  }

  void _stopMusic() {
    if (_audioPlayer.state == PlayerState.playing) {
      _audioPlayer.stop();
    }
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
                      : _isReviewMode
                      ? QuizReviewAnswer.buildReviewList(
                          context: context,
                          questions: _questions,
                          score: _score,
                          scrollController: _reviewScrollController,
                          isEnglish: isEnglish,
                          exitButton: _btn(isEnglish ? "EXIT" : "KELUAR", () {
                            _stopMusic();
                            widget.onFinish();
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          }),
                        )
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
                            : QuizContent(
                                questions: _questions,
                                currentQuestionIndex: _currentQuestionIndex,
                                selectedOptionIndex: _selectedOptionIndex,
                                isLocked: _isLocked,
                                isReviewMode: _isReviewMode,
                                isEnglish: isEnglish,
                                scrollController: _quizScrollController,
                                onOptionTap: _handleAnswer,
                                onImageTap: _showFullScreenImage,
                                navButtons: _buildNavButtons(isEnglish),
                              )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavButtons(bool isEng) {
    bool isFirstQuestion = _currentQuestionIndex == 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _btn(isEng ? "Back" : "Kembali", () {
          if (isFirstQuestion) {
            _stopMusic();
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
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
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
        pageBuilder: (context, _, _) => FullScreenImage(assetPath: imagePath),
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
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
        ElevatedButton(
          onPressed: _resetAndStartQuiz,
          child: const Text("Try Again"),
        ),
      ],
    ),
  );
}
