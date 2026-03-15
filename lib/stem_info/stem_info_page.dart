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
  final Function(Map<String, dynamic>)
  onSelect; // Changed to dynamic for the list

  const StemInfoPage({super.key, required this.onSelect});

  @override
  State<StemInfoPage> createState() => _StemInfoPageState();
}

class _StemInfoPageState extends State<StemInfoPage> {
  final ScrollController _scrollController = ScrollController();

  // Your Hardcoded List
  final List<Map<String, dynamic>> stemInfoList = [
    {
      "id": 1,
      "type": "video",
      "title_en": "STEM Meaning",
      "title_ms": "Maksud STEM",
      "desc_en":
          "STEM stands for Science, Technology, Engineering and Mathematics. It explains how these four subjects work together to solve real-world problems.",
      "desc_ms":
          "STEM bermaksud Sains, Teknologi, Kejuruteraan dan Matematik. Ia menerangkan bagaimana empat bidang ini bekerjasama untuk menyelesaikan masalah dunia sebenar.",
      "preview_image": "assets/stem_info/images/SI1.png",
      "video": "assets/stem_info/videos/v1.mp4",
      "source_en":
          "Fun And Learn Education (2015, September 2). What is STEM? YouTube.",
      "source_ms":
          "Fun And Learn Education (2015, 2 September). Apakah STEM? YouTube.",
      "video_url": "https://www.youtube.com/watch?v=Q0oNyfwL-Ig",
    },
    {
      "id": 2,
      "type": "infographic",
      "title_en": "Importance of STEM",
      "title_ms": "Kepentingan STEM",
      "preview_en":
          "STEM education encourages creativity, teamwork, critical thinking and prepares students for future careers while supporting national development.",
      "preview_ms":
          "Pendidikan STEM menggalakkan kreativiti, kerja berpasukan, pemikiran kritikal serta menyediakan pelajar untuk kerjaya masa depan dan pembangunan negara.",
      "detailImage_en": "assets/stem_info/images/Info2_en.png",
      "detailImage_ms": "assets/stem_info/images/Info2_ms.png",
    },
    {
      "id": 3,
      "type": "video_special",
      "title_en": "STEM Education Overview",
      "title_ms": "Gambaran Keseluruhan Pendidikan STEM",
      "desc_en":
          "This video explains how STEM education teaches skills such as problem solving, teamwork and creativity.",
      "desc_ms":
          "Video ini menerangkan bagaimana pendidikan STEM mengajar kemahiran seperti penyelesaian masalah, kerja berpasukan dan kreativiti.",
      "preview_image": "assets/stem_info/images/SI3.png",
      "detailImage_en": "assets/stem_info/images/SI3.1_en.png",
      "detailImage_ms": "assets/stem_info/images/SI3.1_ms.png",
      "video": "assets/stem_info/videos/v3.mp4",
      "source_en":
          "BBHCSD Media (2014, April 16). STEM Education Overview. YouTube.",
      "source_ms":
          "BBHCSD Media (2014, 16 April) Gambaran Keseluruhan Pendidikan STEM. YouTube.",
      "video_url": "https://www.youtube.com/watch?v=5GWhwUN9iaY",
    },
    {
      "id": 4,
      "type": "video",
      "title_en": "STEM Skills Matter",
      "title_ms": "Kemahiran STEM Sangat Penting",
      "desc_en":
          "STEM skills help students develop logical thinking, collaboration and innovation.",
      "desc_ms":
          "Kemahiran STEM membantu pelajar membangunkan pemikiran logik, kerjasama dan inovasi.",
      "preview_image": "assets/stem_info/images/SI4.png",
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
      "title_en": "STEM in Real Life",
      "title_ms": "STEM dalam Kehidupan Seharian",
      "preview_en":
          "STEM is applied in daily life through technology, transportation, healthcare and environmental solutions.",
      "preview_ms":
          "STEM digunakan dalam kehidupan seharian melalui teknologi, pengangkutan, penjagaan kesihatan dan penyelesaian alam sekitar.",

      "detailImage_en": "assets/stem_info/images/Info5_en.png",
      "detailImage_ms": "assets/stem_info/images/Info5_ms.png",
    },
    {
      "id": 6,
      "type": "video",
      "title_en": "STEM Solves Real-World Problems",
      "title_ms": "STEM Menyelesaikan Masalah Dunia Sebenar",
      "preview_en":
          "Students work in teams during STEM camps to solve real-world problems using science and engineering.",
      "preview_ms":
          "Pelajar bekerjasama dalam kem STEM untuk menyelesaikan masalah dunia sebenar menggunakan sains dan kejuruteraan.",
      "preview_image": "assets/stem_info/images/SI6.png",
      "video": "assets/stem_info/videos/v6.mp4",
      "source_en":
          "Virginia Tech (2025, August 12). STEM Camp Challenges Students to Solve Real-World Problems. YouTube.",
      "source_ms":
          "Virginia Tech (2025, 12 Ogos). Kem STEM Menyelesaikan Masalah Dunia Sebenar. YouTube.",
      "video_url": "https://www.youtube.com/watch?v=qMgH3BdNSy8",
    },
  ];

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
              // Header
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
              // List Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AppRawScrollbar(
                    controller: _scrollController,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(28, 13, 18, 16),
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

                                // Content Area: Nested Purple Card
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
                                            // Center the text within the purple box
                                            child: Text(
                                              previewText ?? '',
                                              textAlign: TextAlign
                                                  .center, // Center text horizontally
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
