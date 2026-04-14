import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:stemxploref2/widgets/language_toggle.dart';
import '../widgets/rawscrollbar.dart';
import '../widgets/box_shadow.dart';
import 'package:stemxploref2/theme_provider.dart';
import 'package:provider/provider.dart';

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

  final List<Map<String, dynamic>> stemInfoList = [
    {
      "id": 1,
      "type": "video_special",
      "title_en": "STEM Education Overview",
      "title_ms": "Gambaran Keseluruhan Pendidikan STEM",
      "desc_en":
          "This video explains how STEM education teaches skills"
          " such as problem solving, teamwork and creativity.",
      "desc_ms":
          "Video ini menerangkan bagaimana pendidikan STEM mengajar kemahiran"
          " seperti penyelesaian masalah, kerja berpasukan dan kreativiti.",
      "preview_image": "assets/stem_info/images/SI3.png",
      "detailImage_en": "assets/stem_info/images/Info1_en.png",
      "detailImage_ms": "assets/stem_info/images/Info1_ms.png",
      "video": "assets/stem_info/videos/v3.mp4",
      "source_en":
          "BBHCSD Media (2014, April 16). STEM Education Overview. YouTube.",
      "source_ms":
          "BBHCSD Media (2014, 16 April) Gambaran Keseluruhan Pendidikan STEM. YouTube.",
      "video_url": "https://www.youtube.com/watch?v=5GWhwUN9iaY",
    },
    {
      "id": 2,
      "type": "infographic",
      "title_en": "STEM Subjects Working Together",
      "title_ms": "Bidang STEM Bekerjasama",
      "preview_en":
          "STEM subjects work together to solve problems. For example,"
          " building a robot involves science, technology, engineering, and mathematics.",
      "preview_ms":
          "Bidang STEM bekerjasama untuk menyelesaikan masalah. Contohnya,"
          " membina robot melibatkan sains, teknologi, kejuruteraan dan matematik.",
      "detailImage_en": "assets/stem_info/images/Info2_en.png",
      "detailImage_ms": "assets/stem_info/images/Info2_ms.png",
    },
    {
      "id": 3,
      "type": "infographic",
      "title_en": "Developing STEM Skills",
      "title_ms": "Membangunkan Kemahiran STEM",
      "preview_en":
          "STEM skills are developed through a process of asking questions, planning ideas, creating solutions,"
          " testing them, and improving designs to solve real-world problems.",
      "preview_ms":
          "Kemahiran STEM dibangunkan melalui proses bertanya soalan, merancang idea, membina penyelesaian,"
          " menguji dan menambah baik reka bentuk untuk menyelesaikan masalah dunia sebenar.",
      "detailImage_en": "assets/stem_info/images/Info3_en.png",
      "detailImage_ms": "assets/stem_info/images/Info3_ms.png",
    },
    {
      "id": 4,
      "type": "video_special",
      "title_en": "STEM Skills Matter",
      "title_ms": "Perkara Kemahiran STEM",
      "desc_en":
          "STEM skills help students develop logical thinking, collaboration and innovation.",
      "desc_ms":
          "Kemahiran STEM membantu pelajar membangunkan pemikiran logik, kerjasama dan inovasi.",
      "preview_image": "assets/stem_info/images/SI4.png",
      "detailImage_en": "assets/stem_info/images/Info4_en.png",
      "detailImage_ms": "assets/stem_info/images/Info4_ms.png",
      "video": "assets/stem_info/videos/v4.mp4",
      "source_en":
          "Department of Education WA (2018, June 12). STEM Skills Matter. YouTube.",
      "source_ms":
          "Department of Education WA (2018, 12 Jun). Kepentingan Kemahiran STEM. YouTube.",
      "video_url": "https://www.youtube.com/watch?v=emfGVvrqsVc",
    },
    {
      "id": 5,
      "type": "infographic",
      "title_en": "Skills in STEM",
      "title_ms": "Kemahiran dalam STEM",
      "preview_en":
          "STEM develops essential skills such as scientific investigation,"
          " engineering design, coding logic, and data analysis"
          " to solve real-world problems.",
      "preview_ms":
          "STEM membangunkan kemahiran penting seperti penyiasatan saintifik,"
          " reka bentuk kejuruteraan, logik pengaturcaraan dan analisis data"
          " untuk menyelesaikan masalah dunia sebenar.",
      "detailImage_en": "assets/stem_info/images/Info5_en.png",
      "detailImage_ms": "assets/stem_info/images/Info5_ms.png",
    },
    {
      "id": 6,
      "type": "video_special",
      "title_en": "STEM Solves Real-World Problems",
      "title_ms": "STEM Menyelesaikan Masalah Dunia Sebenar",
      "preview_en":
          "Students work in teams to design solutions for a community in Nigeria"
          " facing unreliable electricity, using engineering and robotics.",
      "preview_ms":
          "Pelajar bekerjasama untuk mereka penyelesaian bagi komuniti di Nigeria"
          " yang menghadapi masalah bekalan elektrik tidak stabil menggunakan kejuruteraan dan robotik.",
      "preview_image": "assets/stem_info/images/SI6.png",
      "detailImage_en": "assets/stem_info/images/Info6_en.png",
      "detailImage_ms": "assets/stem_info/images/Info6_ms.png",
      "video": "assets/stem_info/videos/v6.mp4",
      "source_en":
          "Virginia Tech (2025, August 12). STEM Camp Challenges Students to Solve Real-World Problems. YouTube.",
      "source_ms":
          "Virginia Tech (2025, 12 Ogos). Kem STEM Menyelesaikan Masalah Dunia Sebenar. YouTube.",
      "video_url": "https://www.youtube.com/watch?v=qMgH3BdNSy8",
    },
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This runs whenever the page is navigated to or dependencies change
    if (_needsScrollReset) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
          _needsScrollReset = false; // Prevent infinite looping
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
                child: Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: AppRawScrollbar(
                    controller: _scrollController,
                    child: ListView.builder(
                      key: UniqueKey(),
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(30, 13, 30, 16),
                      itemCount: stemInfoList.length,
                      itemBuilder: (context, index) {
                        final item = stemInfoList[index];
                        final String title =
                            item['title_$lang'] ?? item['title_en'] ?? '';
                        final String? previewText =
                            item['preview_$lang'] ?? item['preview_en'];
                        final String? previewImage = item['preview_image'];

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
                                      lang == 'en' ? 'Read more' : 'Baca lagi',
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
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: previewImage != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            child: Image.asset(
                                              previewImage,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                              previewText ?? '',
                                              textAlign: TextAlign.center,
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.white,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
