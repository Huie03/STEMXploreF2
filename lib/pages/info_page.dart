import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localization/flutter_localization.dart';
import '/widgets/gradient_background.dart';
import '/widgets/curved_navigation_bar.dart';
import '/widgets/language_toggle.dart';
import '/navigation_provider.dart';

class InfoPage extends StatefulWidget {
  static const routeName = '/info';
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  void initState() {
    super.initState();
    FlutterLocalization.instance.onTranslatedLanguage = (locale) {
      if (mounted) setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    final FlutterLocalization localization = FlutterLocalization.instance;
    final bool isEnglish =
        localization.currentLocale?.languageCode == 'en' ||
        localization.currentLocale == null;

    final String title = isEnglish ? 'Info' : 'Maklumat';
    final String description = isEnglish
        ? 'STEMXplore F2 is a mobile learning application designed for Form 2 secondary school students to explore Science, Technology, Engineering and Mathematics through interactive content, videos and learning activities. STEMXplore F2 was created to help students better understand STEM concepts, increase interest in learning and show how STEM is applied in real-life situations in a fun and engaging way, while supporting Sustainable Development Goal 4 (Quality Education).'
        : 'STEMXplore F2 adalah aplikasi pembelajaran mudah alih yang direka untuk pelajar sekolah menengah Tingkatan 2 untuk meneroka Sains, Teknologi, Kejuruteraan dan Matematik melalui kandungan interaktif, video dan aktiviti pembelajaran. STEMXplore F2 dicipta untuk membantu pelajar memahami konsep STEM dengan lebih baik, meningkatkan minat dalam pembelajaran dan menunjukkan bagaimana STEM diaplikasikan dalam situasi kehidupan sebenar dengan cara yang menyeronokkan, sambil menyokong Matlamat Pembangunan Mampan 4 (Pendidikan Berkualiti).';

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildCustomAppBar(title),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Image.asset(
                        'assets/images/Logo_F2_2.png',
                        height: 280,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        description,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 45),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/Logo_Kedah.png',
                            width: 70,
                            height: 70,
                          ),
                          const SizedBox(width: 5),
                          Image.asset(
                            'assets/images/Logo_UUM.png',
                            width: 70,
                            height: 70,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          LanguageToggle(
            onLanguageChanged: () {
              setState(
                () {},
              ); // This forces InfoPage to update its text strings
            },
          ),
        ],
      ),
    );
  }
}
