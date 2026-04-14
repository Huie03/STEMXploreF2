import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:stemxploref2/theme_provider.dart';
import '../widgets/gradient_background.dart';
import '../widgets/language_toggle.dart';
import '../navigation_provider.dart';
import '../widgets/box_shadow.dart';
import '../widgets/rawscrollbar.dart';
import '../ipaddress.dart';
import 'package:photo_view/photo_view.dart';

class FaqPage extends StatefulWidget {
  static const routeName = '/faq';
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final ScrollController _scrollController = ScrollController();
  int _expandedIndex = -1; // -1 means everything is closed
  late Future<List<Map<String, dynamic>>> _faqFuture;

  // 1. Keep initState as is - it ensures boxes are closed on fresh entry
  @override
  void initState() {
    super.initState();
    _expandedIndex = -1;
    _faqFuture = _fetchFaqs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Remove deactivate entirely
  // Simplify didChangeDependencies to only handle the scroll jump
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // We no longer reset _expandedIndex here.
    // We only handle the scrolling logic.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && _expandedIndex == -1) {
        _scrollController.jumpTo(0);
      }
    });
  }

  Future<List<Map<String, dynamic>>> _fetchFaqs() async {
    final url = Uri.parse('${ipaddress.baseUrl}get_faq.php');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Decode the response as a Map (because it starts with { })
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Look for the 'data' key you added in PHP
        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          List<dynamic> data = jsonResponse['data'];
          return data.map((item) => item as Map<String, dynamic>).toList();
        } else {
          debugPrint("PHP returned success: false or data is null");
          return [];
        }
      } else {
        debugPrint("Server Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      // This will tell you if there is a connection or parsing error
      debugPrint("Flutter Fetch Error: $e");
      return [];
    }
  }

  void _showFullScreenImage(BuildContext context, String imagePath) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              PhotoView(
                // Use NetworkImage for XAMPP server files
                imageProvider: NetworkImage('${ipaddress.baseUrl}$imagePath'),
                loadingBuilder: (context, event) =>
                    const Center(child: CircularProgressIndicator()),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2.0,
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final bool isDark = themeProvider.isDarkMode;
    final bool isEnglish = navProvider.locale.languageCode == 'en';
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(
                context,
                isEnglish ? 'Frequently Asked Question' : 'Soalan Lazim',
                textColor,
              ),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _faqFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final faqs = snapshot.data ?? [];

                    return AppRawScrollbar(
                      controller: _scrollController,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(30, 13, 30, 16),
                        itemCount: faqs.length,
                        itemBuilder: (context, index) {
                          final item = faqs[index];
                          return _buildFaqItem(
                            index,
                            isEnglish
                                ? (item['question_en'] ?? '')
                                : (item['question_ms'] ?? ''),
                            isEnglish
                                ? (item['answer_en'] ?? '')
                                : (item['answer_ms'] ?? ''),
                            isDark,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Combined Helper: AppBar ---
  Widget _buildAppBar(BuildContext context, String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: textColor,
            ),
          ),
          const LanguageToggle(),
        ],
      ),
    );
  }

  // --- Combined Helper: Faq Item ---
  Widget _buildFaqItem(int index, String question, String answer, bool isDark) {
    final bool isExpanded = _expandedIndex == index;
    final Color questionBg = isDark ? const Color(0xFF535252) : Colors.white;
    final Color answerBg = isDark
        ? const Color.fromARGB(255, 111, 111, 111)
        : const Color.fromARGB(255, 235, 145, 0);

    bool isImagePath = answer.contains('assets/') && (answer.endsWith('.png'));

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => _expandedIndex = isExpanded ? -1 : index),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: questionBg,
                boxShadow: isDark ? [] : appBoxShadow,
                borderRadius: BorderRadius.circular(15),
                border: isDark ? Border.all(color: Colors.white10) : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: answerBg,
                  boxShadow: isDark ? [] : appBoxShadow,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: isImagePath
                    ? GestureDetector(
                        // 2. Wrap image in GestureDetector to trigger PhotoView
                        onTap: () => _showFullScreenImage(context, answer),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            '${ipaddress.baseUrl}$answer',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Image not found on server',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : Text(
                        answer,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}
