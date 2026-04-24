import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:stemxploref2/widgets/gradient_background.dart';
import 'package:stemxploref2/widgets/language_toggle.dart';
import 'package:stemxploref2/widgets/rawscrollbar.dart';
import 'package:stemxploref2/widgets/box_shadow.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:stemxploref2/database_helper.dart';

class StemInfoPage extends StatefulWidget {
  static const routeName = '/stem-info';
  final Function(Map<String, dynamic>) onSelect;

  const StemInfoPage({super.key, required this.onSelect});

  @override
  State<StemInfoPage> createState() => _StemInfoPageState();
}

class _StemInfoPageState extends State<StemInfoPage> {
  final ScrollController _scrollController = ScrollController();
  bool _needsScrollReset = true;

  List<Map<String, dynamic>> _stemInfoList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromDatabase();
  }

  Future<void> _loadDataFromDatabase() async {
    try {
      final data = await DatabaseHelper().getStemInfo();
      debugPrint("Loaded ${data.length} rows from stem_info");
      setState(() {
        _stemInfoList = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading database: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_needsScrollReset) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
          _needsScrollReset = false;
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color cardBg = Theme.of(context).colorScheme.surface;
    final Color actionColor = Colors.redAccent;

    final String lang =
        FlutterLocalization.instance.currentLocale?.languageCode ?? 'en';
    final String appBarTitle = lang == 'en' ? 'STEM Info' : 'Maklumat STEM';

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appBarTitle,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: textColor,
                      ),
                    ),
                    const LanguageToggle(),
                  ],
                ),
              ),
              // List Content
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppRawScrollbar(
                        controller: _scrollController,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(30, 13, 30, 16),
                          itemCount: _stemInfoList.length,
                          itemBuilder: (context, index) {
                            final item = _stemInfoList[index];

                            final String title =
                                item['title_$lang'] ?? item['title_en'] ?? '';
                            final String? previewText =
                                item['preview_$lang'] ?? item['preview_en'];

                            final dynamic rawImg = item['preview_image'];
                            final String? previewImage =
                                (rawImg != null &&
                                    rawImg.toString().trim().isNotEmpty)
                                ? rawImg.toString()
                                : null;

                            final double screenHeight = MediaQuery.of(
                              context,
                            ).size.height;
                            final double cardHeight = (screenHeight * 0.25);

                            return GestureDetector(
                              onTap: () => widget.onSelect(item),
                              child: Container(
                                height: cardHeight,
                                margin: const EdgeInsets.only(bottom: 18),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  boxShadow: isDark ? [] : appBoxShadow,
                                  borderRadius: BorderRadius.circular(20),
                                  border: isDark
                                      ? Border.all(
                                          color: Colors.white10,
                                          width: 0.5,
                                        )
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.bold,
                                              color: textColor,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          lang == 'en'
                                              ? 'Read more'
                                              : 'Baca lagi',
                                          style: TextStyle(
                                            color: actionColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEB9000),
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                        child: previewImage != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.asset(
                                                  previewImage,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return const Center(
                                                          child: Icon(
                                                            Icons.broken_image,
                                                            color: Colors.white,
                                                          ),
                                                        );
                                                      },
                                                ),
                                              )
                                            : Center(
                                                child: Text(
                                                  previewText ?? '',
                                                  textAlign: TextAlign.center,
                                                  maxLines: 4,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
