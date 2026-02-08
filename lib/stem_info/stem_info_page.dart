import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';
import 'stem_detail_page.dart';
import 'package:provider/provider.dart';
import '/navigation_provider.dart';
import 'package:stemxploref2/widgets/curved_navigation_bar.dart';
import 'package:flutter_localization/flutter_localization.dart';
import '/widgets/language_toggle.dart';

class StemInfoPage extends StatefulWidget {
  static const routeName = '/stem-info';

  const StemInfoPage({super.key});

  @override
  State<StemInfoPage> createState() => _StemInfoPageState();
}

class _StemInfoPageState extends State<StemInfoPage> {
  @override
  Widget build(BuildContext context) {
    final FlutterLocalization localization = FlutterLocalization.instance;
    // This variable now refreshes whenever setState is called
    final bool isEnglish = localization.currentLocale?.languageCode == 'en';

    final List<Map<String, String>> stemData = isEnglish
        ? [
            {
              'title': 'Video: STEM Meaning',
              'preview':
                  'Learn what STEM means and how Science, Technology, Engineering, and Math work together. '
                  'See simple examples of how STEM is used in real life.\n\n'
                  'This video also shows how students can apply STEM concepts in everyday activities and projects, '
                  'making learning fun and interactive.',
              'videoUrl': 'https://youtu.be/wRV28EOCGGo?si=i7nfreNgNU1jF1J8',
              'previewImage': 'assets/images/STEMvideo1.png',
            },
            {
              'title': 'Applied STEM in real life',
              'preview': '',
              'previewImage': 'assets/images/STEM 2.png',
              'detailImage': 'assets/images/STEM 2.png',
            },
            {
              'title': 'Importance of STEM',
              'preview':
                  'STEM is important because it helps students understand the world, encourages innovation, and equips them with skills for modern jobs.',
              'detailImage': ' ',
            },
            {
              'title': 'STEM careers',
              'preview': '',
              'previewImage': 'assets/images/stemInfo3.png',
              'detailImage': ' ',
            },
            {
              'title': 'STEM learning activities',
              'preview': '',
              'previewImage': 'assets/images/steminfo4.png',
              'detailImage': ' ',
            },
          ]
        : [
            {
              'title': 'Video: Maksud STEM',
              'preview':
                  'Ketahui maksud STEM dan bagaimana Sains, Teknologi, Kejuruteraan, dan Matematik berfungsi bersama. '
                  'Lihat contoh mudah bagaimana STEM digunakan dalam kehidupan sebenar.\n\n'
                  'Video ini juga menunjukkan bagaimana pelajar boleh menggunakan konsep STEM dalam aktiviti dan projek harian, '
                  'membuat pembelajaran menjadi menyeronokkan dan interaktif.',
              'videoUrl': 'https://youtu.be/wRV28EOCGGo?si=i7nfreNgNU1jF1J8',
              'previewImage': 'assets/images/STEMvideo1.png',
            },
            {
              'title': 'Aplikasi STEM dalam kehidupan',
              'preview': '',
              'previewImage': 'assets/images/STEM 2.png',
              'detailImage': 'assets/images/STEM 2.png',
            },
            {
              'title': 'Kepentingan STEM',
              'preview':
                  'STEM adalah penting kerana ia membantu murid memahami dunia, menggalakkan inovasi, dan melengkapi mereka dengan kemahiran untuk kerjaya moden.',
              'detailImage': ' ',
            },
            {
              'title': 'Kerjaya STEM',
              'preview': '',
              'previewImage': 'assets/images/stemInfo3.png',
              'detailImage': ' ',
            },
            {
              'title': 'Aktiviti pembelajaran STEM',
              'preview': '',
              'previewImage': 'assets/images/steminfo4.png',
              'detailImage': ' ',
            },
          ];

    final String title = isEnglish ? 'STEM Info' : 'Maklumat STEM';

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
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                    // Direct Toggle using GestureDetector inside the layout position
                    GestureDetector(
                      onTap: () {
                        // DIRECT CHANGE: Toggles immediately on click
                        final String nextLocale = isEnglish ? 'ms' : 'en';
                        localization.translate(nextLocale);
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(
                          8,
                        ), // Padding to match icon button hit area
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              key: ValueKey<bool>(isEnglish),
                              isEnglish
                                  ? 'assets/flag/language us_flag.png'
                                  : 'assets/flag/language ms_flag.png',
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: stemData.length,
                  itemBuilder: (context, index) {
                    final item = stemData[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StemDetailPage(itemIndex: index),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item['title']!,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  isEnglish ? 'Read more' : 'Baca lagi',
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (item.containsKey('previewImage'))
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  item['previewImage']!,
                                  width: double.infinity,
                                  height: 115,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Text(
                                  item['preview']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
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
            ],
          ),
        ),
      ),
    );
  }
}
