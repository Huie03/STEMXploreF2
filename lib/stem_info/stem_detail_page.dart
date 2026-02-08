import 'package:flutter/material.dart';
import '../widgets/gradient_background.dart';
import 'package:provider/provider.dart';
import '/navigation_provider.dart';
import 'package:stemxploref2/widgets/curved_navigation_bar.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '/widgets/language_toggle.dart';

class StemDetailPage extends StatefulWidget {
  final int itemIndex;

  const StemDetailPage({required this.itemIndex, super.key});

  @override
  State<StemDetailPage> createState() => _StemDetailPageState();
}

class _StemDetailPageState extends State<StemDetailPage> {
  YoutubePlayerController? _controller;
  late List<Map<String, String>> stemData;

  @override
  void initState() {
    super.initState();
    _initializeDataAndController();
  }

  void _initializeDataAndController() {
    final FlutterLocalization localization = FlutterLocalization.instance;
    final bool isEnglish = localization.currentLocale?.languageCode == 'en';

    stemData = isEnglish ? _getEnglishData() : _getMalayData();

    final item = stemData[widget.itemIndex];
    final String? videoUrl = item['videoUrl'];
    final String? videoId = videoUrl != null
        ? YoutubePlayer.convertUrlToId(videoUrl)
        : null;

    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          disableDragSeek: false,
        ),
      );
    }
  }

  @override
  void deactivate() {
    _controller?.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FlutterLocalization localization = FlutterLocalization.instance;
    final bool isEnglish = localization.currentLocale?.languageCode == 'en';
    final item = stemData[widget.itemIndex];

    if (_controller == null) {
      return _buildRegularPage(context, isEnglish, item);
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.redAccent,
      ),
      builder: (context, player) {
        return _buildRegularPage(context, isEnglish, item, videoPlayer: player);
      },
    );
  }

  Widget _buildRegularPage(
    BuildContext context,
    bool isEnglish,
    Map<String, String> item, {
    Widget? videoPlayer,
  }) {
    final FlutterLocalization localization = FlutterLocalization.instance;
    final String title = isEnglish
        ? 'STEM Info'
        : 'Maklumat STEM'; // Localized title

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // --- ADJUSTED APP BAR TO MATCH INFO PAGE ---
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 50), // Balance the flag button
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.black,
                      ),
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
              ),

              // --- END OF ADJUSTED APP BAR ---
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 20,
                    top: 15, // Adjusted top padding slightly
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.black45),
                        ),
                        child: Column(
                          children: [
                            if (item['preview'] != null &&
                                item['preview']!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 0,
                                ), // Removed bottom padding here to use SizedBox for control
                                child: Text(
                                  item['preview']!,
                                  textAlign: TextAlign.justify,
                                  style: const TextStyle(
                                    fontSize:
                                        15, // <--- Add your desired font size here
                                    color: Colors
                                        .black87, // Optional: makes it slightly softer than pure black
                                    height:
                                        1.5, // Optional: improves readability with line spacing
                                  ),
                                ),
                              ),

                            // --- ADDED SPACE HERE ---
                            if (item['preview'] != null &&
                                item['preview']!.isNotEmpty)
                              const SizedBox(
                                height: 50,
                              ), // Adjust this value (20) to your liking
                            // ------------------------
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child:
                                  videoPlayer ??
                                  (widget.itemIndex == 1
                                      ? AppliedStemLayout(isEnglish: isEnglish)
                                      : Image.asset(
                                          item['detailImage'] ?? '',
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.image,
                                                    size: 100,
                                                    color: Colors.white,
                                                  ),
                                        )),
                            ),
                            // --- ADDED SOURCE TEXT AND SPACING BELOW ---
                            if (widget.itemIndex == 0) ...[
                              const SizedBox(
                                height: 15,
                              ), // Space above the text
                              Align(
                                alignment: Alignment.centerLeft,
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize:
                                          12, // Slightly smaller to look like a caption
                                      color: Colors.black,
                                      height: 1.4,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: "Source:\n",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(
                                        text:
                                            "What is STEM? – STEM Best Practice, 20 June 2017\n",
                                      ),
                                      TextSpan(
                                        text:
                                            "https://www.youtube.com/watch?v=wRV28EOCGGo",
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ), // Extra space below the source
                            ],
                            // ------------------------------------------
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppCurvedNavBar(
        currentIndex: 0,
        onTap: (index) {
          Provider.of<NavigationProvider>(
            context,
            listen: false,
          ).setIndex(index);

          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }

  // Data helpers to keep build clean
  List<Map<String, String>> _getEnglishData() => [
    {
      'title': 'Video: STEM Meaning',
      'preview':
          'Learn what STEM means and how Science, Technology, Engineering, and Math work together. '
          'See simple examples of how STEM is used in real life.\n\n'
          'This video also shows how students can apply STEM concepts in everyday activities and projects, '
          'making learning fun and interactive.',
      'videoUrl': 'https://youtu.be/wRV28EOCGGo?si=i7nfreNgNU1jF1J8',
    },
    {
      'title': 'Applied STEM in real life',
      'preview': '',
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
      'detailImage': 'assets/images/stemInfo3.png',
    },
    {
      'title': 'STEM learning activities',
      'preview': '',
      'detailImage': 'assets/images/steminfo4.png',
    },
  ];

  List<Map<String, String>> _getMalayData() => [
    {
      'title': 'Video: Maksud STEM',
      'preview':
          'Ketahui maksud STEM dan bagaimana Sains, Teknologi, Kejuruteraan, dan Matematik berfungsi bersama. '
          'Lihat contoh mudah bagaimana STEM digunakan dalam kehidupan sebenar.\n\n'
          'Video ini juga menunjukkan bagaimana pelajar boleh menggunakan konsep STEM dalam aktiviti dan projek harian, '
          'membuat pembelajaran menjadi menyeronokkan dan interaktif.',
      'videoUrl': 'https://youtu.be/wRV28EOCGGo?si=i7nfreNgNU1jF1J8',
    },
    {
      'title': 'Aplikasi STEM dalam kehidupan',
      'preview': '',
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
      'detailImage': 'assets/images/stemInfo3.png',
    },
    {
      'title': 'Aktiviti pembelajaran STEM',
      'preview': '',
      'detailImage': 'assets/images/steminfo4.png',
    },
  ];
}

class AppliedStemLayout extends StatelessWidget {
  final bool isEnglish;
  const AppliedStemLayout({super.key, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          isEnglish
              ? "STEM is applied in daily life through technology, transportation, healthcare, and environmental solutions."
              : "STEM diaplikasikan dalam kehidupan harian melalui teknologi, pengangkutan, kesihatan, dan penyelesaian alam sekitar.",
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        _buildSection(
          isEnglish ? "1. Technology" : "1. Teknologi",
          isEnglish
              ? "Used in smartphones, computers, and apps to communicate, learn, and solve problems."
              : "Digunakan dalam telefon pintar, komputer, dan aplikasi untuk berkomunikasi, belajar, dan menyelesaikan masalah.",
          ['assets/images/info1.png'],
        ),
        _buildSection(
          isEnglish ? "2. Transportation" : "2. Pengangkutan",
          isEnglish
              ? "Helps design vehicles and traffic systems to make travel safer and faster."
              : "Membantu mereka bentuk kenderaan dan sistem trafik untuk menjadikan perjalanan lebih selamat dan pantas.",
          ['assets/images/info2.png'],
        ),
        _buildSection(
          isEnglish ? "3. Healthcare" : "3. Kesihatan",
          isEnglish
              ? "Used in medical tools and medicines to diagnose illnesses and keep people healthy."
              : "Digunakan dalam alatan perubatan dan ubat-ubatan untuk mendiagnosis penyakit dan menjaga kesihatan.",
          ['assets/images/info3.png'],
        ),
        _buildSection(
          isEnglish ? "4. Environmental" : "4. Alam Sekitar",
          isEnglish
              ? "Helps protect nature through recycling, renewable energy, and clean water systems."
              : "Membantu melindungi alam semula jadi melalui kitar semula, tenaga boleh diperbaharui, dan sistem air bersih.",
          ['assets/images/info4.png'],
        ),
      ],
    );
  }

  Widget _buildSection(String title, String desc, List<String> images) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 15,
              height: 1.3,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: images
                .map(
                  (img) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          img,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, e, s) => Container(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            height: 80,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
