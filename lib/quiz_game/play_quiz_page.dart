import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/box_shadow.dart';
import '../widgets/language_toggle.dart';
import '../ipaddress.dart';
import '../navigation_provider.dart';
import '../quiz_game/quiz_ui.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';

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
  List<dynamic> _questions = [];
  bool _isLoading = true;
  String? _errorMessage;

  int _currentQuestionIndex = 0;
  int _score = 0;
  late String _subject;
  late String _difficulty;

  int? _selectedOptionIndex;
  bool _isLocked = false;
  bool _isReviewMode = false;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  String _liveTime = "00:00";

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
    _timer?.cancel();
    _stopwatch.stop();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _resetAndStartQuiz() {
    setState(() {
      _questions = [];
      _isLoading = true;
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedOptionIndex = null;
      _isLocked = false;
      _isReviewMode = false;
      _stopwatch.reset();
      _liveTime = "00:00";
      _errorMessage = null;
    });
    _parseParams();
    _fetchQuestions();
  }

  void _parseParams() {
    final parts = widget.subjectAndMode.split('|');
    _subject = parts[0].trim();
    _difficulty = parts.length > 1 ? parts[1].trim() : "Easy";
  }

  Future<void> _startBackgroundMusic() async {
    try {
      // This must match the filename in your pubspec.yaml exactly
      await _audioPlayer.play(AssetSource('audio/quiz_background_music.mp3'));
      debugPrint("Music started successfully");
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  Future<void> _fetchQuestions() async {
    try {
      final url = Uri.parse(
        '${ipadress.baseUrl}get_quiz.php?subject=$_subject&difficulty=$_difficulty',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> decodedData = json.decode(response.body);
        if (mounted) {
          setState(() {
            _questions = decodedData;
            _isLoading = false;
            if (_questions.isNotEmpty) {
              _startTimer();
              _startBackgroundMusic();
            } else {
              _errorMessage = "No questions found.";
            }
          });
        }
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _isLoading = false;
          _errorMessage = "Connection Failed.";
        });
    }
  }

  void _stopMusic() {
    _audioPlayer.stop();
  }

  void _startTimer() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted)
        setState(() {
          _liveTime = _formatTime(_stopwatch.elapsedMilliseconds);
        });
    });
  }

  String _formatTime(int ms) {
    int sec = (ms / 1000).truncate();
    return "${(sec / 60).truncate().toString().padLeft(2, '0')}:${(sec % 60).toString().padLeft(2, '0')}";
  }

  void _handleAnswer(int selectedIndex, int correctIndex) {
    if (_isLocked || _isReviewMode) return;
    setState(() {
      _selectedOptionIndex = selectedIndex;
      _isLocked = true;
      if (selectedIndex == correctIndex) _score++;
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
          _stopMusic(); //Music stop when exit
          widget.onFinish();
        }
      },
      child: Scaffold(
        body: GradientBackground(
          child: SafeArea(
            child: Column(
              children: [
                QuizUi.buildAppBar(
                  title: isEnglish ? 'Quiz Game' : 'Permainan Kuiz',
                  languageToggle: const LanguageToggle(),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : (_errorMessage != null
                            ? _buildError()
                            : _buildQuizContent(isEnglish)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizContent(bool isEnglish) {
    final q = _questions[_currentQuestionIndex];
    String rawLetter =
        q['correct_option']?.toString().trim().toUpperCase() ?? "";
    int correctIndex = "ABCD".indexOf(rawLetter);
    if (correctIndex == -1) correctIndex = 0;

    final List<dynamic> options = isEnglish
        ? (q['options_en'] ?? [])
        : (q['options_ms'] ?? q['options_en'] ?? []);
    final String questionText = isEnglish
        ? (q['q_en'] ?? "")
        : (q['q_ms'] ?? q['q_en'] ?? "");
    final String explanationText = isEnglish
        ? (q['explanation_en'] ?? "")
        : (q['explanation_ms'] ?? "");

    final int? activeSelection = _isReviewMode
        ? q['user_choice']
        : _selectedOptionIndex;
    final bool showFeedback = _isLocked || _isReviewMode;

    return Column(
      children: [
        QuizUi.buildProgressHeader(
          subject: _subject,
          difficulty: _difficulty,
          liveTime: _liveTime,
          progress: (_currentQuestionIndex + 1) / _questions.length,
          counterText: "${_currentQuestionIndex + 1}/${_questions.length}",
        ),
        const SizedBox(height: 5),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 30),
            child: QuizUi.buildQuestionCard(
              boxShadow: appBoxShadow,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildQuestionBody(questionText),
                  const Divider(height: 1, thickness: 1, color: Colors.black12),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                    child: Column(
                      children: [
                        ...List.generate(
                          options.length,
                          (i) => QuizUi.buildOptionTile(
                            index: i,
                            text: options[i].toString(),
                            correctIndex: correctIndex,
                            selectedIndex: activeSelection,
                            showFeedback: showFeedback,
                            onTap: () => _handleAnswer(i, correctIndex),
                          ),
                        ),
                        if (showFeedback)
                          _buildExplanation(isEnglish, explanationText),
                        const SizedBox(height: 15),
                        _buildNavButtons(isEnglish),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionBody(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 12),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildExplanation(bool isEnglish, String text) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEnglish ? "Explanation:" : "Penjelasan:",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(0, 0, 0, 1),
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            text.isEmpty
                ? (isEnglish
                      ? "No explanation available."
                      : "Tiada penjelasan.")
                : text,
            style: const TextStyle(fontSize: 13.5, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButtons(bool isEng) {
    bool isBackEnabled = _currentQuestionIndex > 0;
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isBackEnabled
                ? () => setState(() {
                    _currentQuestionIndex--;
                    _selectedOptionIndex =
                        _questions[_currentQuestionIndex]['user_choice'];
                    _isLocked = _selectedOptionIndex != null;
                  })
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange,
              disabledBackgroundColor: Colors.grey.shade300,
              disabledForegroundColor: Colors.grey.shade500,
              elevation: 0,
              side: BorderSide(
                color: isBackEnabled ? Colors.orange : Colors.transparent,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isEng ? "Back" : "Kembali",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: (_isLocked || _isReviewMode)
                ? () {
                    if (_currentQuestionIndex < _questions.length - 1) {
                      setState(() {
                        _currentQuestionIndex++;
                        _selectedOptionIndex =
                            _questions[_currentQuestionIndex]['user_choice'];
                        _isLocked = _selectedOptionIndex != null;
                      });
                    } else {
                      if (_isReviewMode) {
                        _stopMusic();
                        widget.onFinish();
                      } else {
                        _showResultDialog(isEng);
                      }
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _currentQuestionIndex < _questions.length - 1
                  ? (isEng ? "Next" : "Seterusnya")
                  : (isEng ? "Finish" : "Selesai"),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showResultDialog(bool isEnglish) {
    _stopwatch.stop();
    _timer?.cancel();
    _confettiController.play();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => QuizUi.buildResultsDialog(
        context: context,
        score: _score,
        total: _questions.length,
        time: _liveTime,
        isEnglish: isEnglish,
        confettiController: _confettiController,
        onReplay: () {
          Navigator.pop(ctx);
          _resetAndStartQuiz();
        },
        onReview: () {
          Navigator.pop(ctx);
          setState(() {
            _isReviewMode = true;
            _currentQuestionIndex = 0;
          });
        },
      ),
    );
  }

  Widget _buildError() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 40, color: Colors.white),
        const SizedBox(height: 10),
        Text(_errorMessage!, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: _resetAndStartQuiz,
          child: const Text("Try Again"),
        ),
      ],
    ),
  );
}
