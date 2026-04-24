import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stemxploref2/widgets/gradient_background.dart';
import 'package:stemxploref2/widgets/language_toggle.dart';
import 'package:stemxploref2/navigation_provider.dart';
import 'package:stemxploref2/widgets/box_shadow.dart';
import 'package:stemxploref2/widgets/rawscrollbar.dart';

class InfoPage extends StatefulWidget {
  static const routeName = '/info';
  const InfoPage({super.key});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  bool isPrivacyExpanded = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  //Reset scroll
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final bool isEnglish = navProvider.locale.languageCode == 'en';
    final Color textColor = Theme.of(context).colorScheme.onSurface;

    final String appBarTitle = isEnglish ? 'Info' : 'Maklumat';

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
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

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 0),
                  child: AppRawScrollbar(
                    controller: _scrollController,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Image.asset(
                            'assets/images/Logo_F2_2.png',
                            height: 200,
                            fit: BoxFit.contain,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: textColor,
                                  ),
                                  children: const [
                                    TextSpan(text: "STEM"),
                                    TextSpan(
                                      text: "X",
                                      style: TextStyle(fontSize: 30),
                                    ),
                                    TextSpan(text: "plore "),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF9E00),
                                  shape: BoxShape.circle,
                                ),
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "F",
                                        style: TextStyle(fontSize: 22),
                                      ),
                                      TextSpan(
                                        text: "2",
                                        style: TextStyle(fontSize: 30),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isEnglish ? "Version 1.0.0" : "Versi 1.0.0",
                            style: TextStyle(fontSize: 14, color: textColor),
                          ),

                          const SizedBox(height: 25),

                          // What's New Card
                          buildInfoCard(
                            icon: Icons.new_releases,
                            title: isEnglish ? "What’s New" : "Apa Yang Baharu",
                            content: isEnglish
                                ? "• Added interactive STEM modules\n"
                                      "• Improved bilingual support\n"
                                      "• Enhanced UI design"
                                : "• Modul STEM interaktif ditambah\n"
                                      "• Sokongan dwibahasa dipertingkatkan\n"
                                      "• Reka bentuk UI dipertingkat",
                            textColor: textColor,
                            textAlign: TextAlign.start,
                          ),

                          const SizedBox(height: 15),

                          // About Card
                          buildInfoCard(
                            icon: Icons.info,
                            title: isEnglish
                                ? "About STEMXplore F2"
                                : "Tentang STEMXplore F2",
                            content: isEnglish
                                ? "STEMXplore F2 is an interactive mobile platform for Form 2 students to build essential "
                                : "STEMXplore F2 ialah platform mudah alih interaktif untuk pelajar Tingkatan 2 bagi membina ",
                            highlightedWord: isEnglish ? "skills" : "kemahiran",
                            trailingContent: isEnglish
                                ? " through engaging, real-world learning experiences and interactive activities, supporting Quality Education (SDG 4)."
                                : " STEM penting melalui pengalaman pembelajaran dunia sebenar yang menarik serta aktiviti interaktif, menyokong Pendidikan Berkualiti (SDG 4).",
                            textColor: textColor,
                          ),

                          const SizedBox(height: 15),

                          // Privacy Policy Card
                          buildInfoCard(
                            icon: Icons.privacy_tip,
                            title: isEnglish
                                ? "Privacy Policy"
                                : "Dasar Privasi",
                            content: isEnglish
                                ? "STEMXplore F2 respects your privacy. "
                                      "This application does not collect personal data "
                                      "without consent. All information is used strictly "
                                      "for educational purposes and improving user experience."
                                : "STEMXplore F2 menghormati privasi anda. "
                                      "Aplikasi ini tidak mengumpul data peribadi tanpa kebenaran. "
                                      "Semua maklumat digunakan hanya untuk tujuan pendidikan.",
                            textColor: textColor,
                          ),

                          const SizedBox(height: 15),

                          // Terms Card
                          buildInfoCard(
                            icon: Icons.description,
                            title: isEnglish
                                ? "Terms of Service"
                                : "Terma Perkhidmatan",
                            content: isEnglish
                                ? "By using STEMXplore F2, users agree to use the "
                                      "application for educational purposes only. "
                                      "All content is protected and may not be reproduced "
                                      "without permission."
                                : "Dengan menggunakan STEMXplore F2, pengguna bersetuju "
                                      "menggunakan aplikasi ini untuk tujuan pendidikan sahaja. "
                                      "Semua kandungan dilindungi dan tidak boleh diterbitkan semula.",
                            textColor: textColor,
                          ),

                          const SizedBox(height: 20),

                          // Footer Logos
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/Logo_Kedah.png',
                                width: 70,
                                height: 70,
                              ),
                              const SizedBox(width: 20),
                              Image.asset(
                                'assets/images/Logo_UUM.png',
                                width: 150,
                                height: 150,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
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

  Widget buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    String? highlightedWord,
    String? trailingContent,
    required Color textColor,
    TextAlign textAlign = TextAlign.justify,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: appBoxShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFF9E00), size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: textColor,
                    ),
                    children: [
                      TextSpan(text: content),
                      if (highlightedWord != null)
                        TextSpan(
                          text: highlightedWord,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF9E00),
                          ),
                        ),
                      if (trailingContent != null)
                        TextSpan(text: trailingContent),
                    ],
                  ),
                  textAlign: textAlign,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
