import 'package:flutter/material.dart';
import 'dart:convert';
import '../widgets/gradient_background.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:stemxploref2/widgets/language_toggle.dart';
import '../widgets/rawscrollbar.dart';
import '../widgets/box_shadow.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:provider/provider.dart';
import '../ipaddress.dart';
import 'package:http/http.dart' as http;

class StemInfoPage extends StatefulWidget {
  static const routeName = '/stem-info';
  final Function(Map<String, String>) onSelect;

  const StemInfoPage({super.key, required this.onSelect});
  @override
  State<StemInfoPage> createState() => _StemInfoPageState();
}

class _StemInfoPageState extends State<StemInfoPage> {
  final ScrollController _scrollController = ScrollController();
  late Future<List<dynamic>> _stemFuture;

  @override
  void initState() {
    super.initState();
    _stemFuture = _fetchStemData();
  }

  Future<List<dynamic>> _fetchStemData() async {
    // Replace 'get_stem_info.php' with your actual endpoint
    final response = await http.get(
      Uri.parse('${ipadress.baseUrl}get_stem_info.php'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDark = themeProvider.isDarkMode;
    final Color textColor = Theme.of(context).colorScheme.onSurface;
    final Color cardBg = Theme.of(context).colorScheme.surface;
    final Color subTextColor = isDark ? Colors.white70 : Colors.black87;
    final Color actionColor = Colors.redAccent;

    final String lang =
        FlutterLocalization.instance.currentLocale?.languageCode ?? 'en';
    final String appBarTitle = lang == 'en' ? 'STEM Info' : 'Maklumat STEM';

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
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
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _stemFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    final stemData = snapshot.data!;

                    // FIX: Added the Padding wrapper to match the exact scrollbar position of your first code
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: AppRawScrollbar(
                        controller: _scrollController,
                        child: ListView.builder(
                          controller: _scrollController,
                          // FIX: Padding must be exactly the same as your first code: (28, 13, 18, 16)
                          padding: const EdgeInsets.fromLTRB(28, 13, 18, 16),
                          itemCount: stemData.length,
                          itemBuilder: (context, index) {
                            final item = Map<String, String>.from(
                              stemData[index].map(
                                (key, value) =>
                                    MapEntry(key.toString(), value.toString()),
                              ),
                            );

                            final String title =
                                item['title_$lang'] ?? item['title_en'] ?? '';
                            final String? preview =
                                item['preview_$lang'] ?? item['preview_en'];

                            return GestureDetector(
                              onTap: () => widget.onSelect(item),
                              child: Container(
                                // Keeping your exact margin and styling
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
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 10),

                                    // Using your updated Image.network logic
                                    if (item.containsKey(
                                          'preview_image_path',
                                        ) &&
                                        item['preview_image_path'] != null &&
                                        item['preview_image_path']!
                                            .isNotEmpty &&
                                        item['preview_image_path'] != 'null')
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.network(
                                          "${ipadress.baseUrl}${item['preview_image_path']!}",
                                          width: double.infinity,
                                          height: 120,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return Container(
                                                  height: 120,
                                                  color: Colors.grey[200],
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey,
                                                  ),
                                                );
                                              },
                                        ),
                                      )
                                    else if (preview != null &&
                                        preview !=
                                            'null') // Added 'null' check for preview text
                                      Text(
                                        preview,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: subTextColor),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
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
}
