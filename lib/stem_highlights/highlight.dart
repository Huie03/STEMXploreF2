class Highlight {
  final int id;
  final String titleEn;
  final String titleMs;
  final String subtitleEn;
  final String subtitleMs;
  final String image1Url;
  final String image2Url;
  final String desc1En;
  final String desc1Ms;
  final String desc2En;
  final String desc2Ms;
  final String skillsImageEn;
  final String skillsImageMs;
  final String citationEn;
  final String citationMs;
  final String sourceUrl;
  final String? videoUrl;

  Highlight({
    required this.id,
    required this.titleEn,
    required this.titleMs,
    required this.subtitleEn,
    required this.subtitleMs,
    required this.image1Url,
    required this.image2Url,
    required this.desc1En,
    required this.desc1Ms,
    required this.desc2En,
    required this.desc2Ms,
    required this.skillsImageEn,
    required this.skillsImageMs,
    required this.citationEn,
    required this.citationMs,
    required this.sourceUrl,
    this.videoUrl,
  });

  static List<Highlight> getHardcodedHighlights() {
    return [
      Highlight(
        id: 1,
        titleEn: 'MJIIT STEM Competition',
        titleMs: 'Pertandingan STEM MJIIT',
        subtitleEn:
            'Malaysian students compete in robotics and water rocket engineering challenges.',
        subtitleMs:
            'Pelajar Malaysia bersaing dalam cabaran robotik dan kejuruteraan roket air.',
        image1Url: 'assets/highlights/images/SH1.png',
        image2Url: 'assets/highlights/images/SH1.1.png',
        desc1En:
            'UTM’s MJIIT STEM Competition gathered 249 students from 42 schools, featuring water rocket engineering and line-following robotics challenges promoting creativity, teamwork, and problem-solving.',
        desc1Ms:
            'Pertandingan STEM MJIIT UTM mengumpulkan 249 pelajar dari 42 sekolah, menampilkan cabaran kejuruteraan roket air dan robotik penjejak garisan yang memupuk kreativiti, kerja berpasukan dan penyelesaian masalah.',
        desc2En:
            'Students designed rockets powered by water pressure and programmed autonomous robots, gaining hands-on experience applying science and engineering concepts through experimentation and competition.',
        desc2Ms:
            'Pelajar mereka bentuk roket yang dikuasakan oleh tekanan air dan memprogramkan robot autonomi, memperoleh pengalaman praktikal dalam menggunakan konsep sains dan kejuruteraan melalui eksperimen dan pertandingan.',
        skillsImageEn: 'assets/highlights/images/SH1.2_en.png',
        skillsImageMs: 'assets/highlights/images/SH1.2_ms.png',
        citationEn:
            'Peng Yen Liew. (2025, May 15). MJIIT STEM Competitions promotes STEM among Malaysian students. UTM NewsHub.',
        citationMs:
            'Peng Yen Liew. (2025, May 15). Pertandingan STEM MJIIT mempromosikan STEM dalam kalangan pelajar Malaysia. UTM NewsHub.',
        sourceUrl:
            'https://news.utm.my/2025/05/mjiit-stem-competitions-promotes-stem-among-malaysian-students/',
      ),
      Highlight(
        id: 2,
        titleEn: 'Robotics Break Barriers',
        titleMs: 'Robotik Memecah Halangan',
        subtitleEn:
            'Indigenous Malaysian students achieve success through robotics education programmes.',
        subtitleMs:
            'Pelajar orang asli Malaysia mencapai kejayaan melalui program pendidikan robotik.',
        image1Url: 'assets/highlights/images/SH2.png',
        image2Url: 'assets/highlights/images/SH2.1.png',
        desc1En:
            'Petrosains Tech4All introduced indigenous students to robotics and coding, preparing them for competitions and representing Malaysia at the International Robot Olympiad.',
        desc1Ms:
            'Petrosains Tech4All memperkenalkan pelajar orang asli kepada robotik dan pengekodan, menyediakan mereka untuk pertandingan dan mewakili Malaysia di Olympiad Robot Antarabangsa.',
        desc2En:
            'Teams built innovative robots and won international gold, demonstrating creativity, resilience, and confidence gained through inclusive STEM education opportunities.',
        desc2Ms:
            'Pasukan membina robot inovatif dan memenangi pingat emas antarabangsa, menunjukkan kreativiti, daya tahan, dan keyakinan yang diperoleh melalui peluang pendidikan STEM yang inklusif.',
        skillsImageEn: 'assets/highlights/images/SH2.2_en.png',
        skillsImageMs: 'assets/highlights/images/SH2.2_ms.png',
        citationEn:
            'Breaking barriers, building bots. (2025, March 25). The Star.',
        citationMs:
            'Breaking barriers, building bots. (2025, March 25). The Star.',
        sourceUrl:
            'https://www.thestar.com.my/starpicks/2025/03/25/breaking-barriers-building-bots',
      ),
      Highlight(
        id: 3,
        titleEn: 'AI Learning Platform Innovators',
        titleMs: 'Inovator Platform Pembelajaran AI',
        subtitleEn: 'STEM innovation and skills can emerge at any age.',
        subtitleMs:
            'Inovasi dan kemahiran STEM boleh muncul pada sebarang usia.',
        image1Url: 'assets/highlights/images/SH3.png',
        image2Url: 'assets/highlights/images/SH3.1.png',
        desc1En:
            'Young Malaysian brothers created MineduAI, an AI learning platform built inside the video game Minecraft that guides students through subjects like mathematics and science.',
        desc1Ms:
            'Dua beradik rakyat Malaysia mencipta MineduAI, sebuah platform pembelajaran AI yang dibina di dalam permainan video Minecraft yang membimbing pelajar melalui subjek seperti matematik dan sains.',
        desc2En:
            'Their innovation combines gaming with AI tutoring to make learning interactive while encouraging creativity, problem-solving, and digital skills among students.',
        desc2Ms:
            'Inovasi mereka menggabungkan permainan dengan tunjuk ajar AI untuk menjadikan pembelajaran interaktif sambil menggalakkan kreativiti, penyelesaian masalah, dan kemahiran digital dalam kalangan pelajar.',
        skillsImageEn: 'assets/highlights/images/SH3.2_en.png',
        skillsImageMs: 'assets/highlights/images/SH3.2_ms.png',
        citationEn:
            'MineduAI Puts Malaysia’s Youngest Co-Founders on the Global AI Stage.',
        citationMs:
            'MineduAI meletakkan Pengasas Bersama termuda Malaysia di Pentas AI Global.',
        sourceUrl: 'https://mineduai.my/',
        videoUrl: 'assets/highlights/videos/h3.mp4',
      ),
      Highlight(
        id: 4,
        titleEn: 'Curtin STEM Outreach',
        titleMs: 'Program Jangkauan STEM Curtin',
        subtitleEn:
            'University volunteers inspire students through hands-on science and engineering activities.',
        subtitleMs:
            'Sukarelawan universiti memberi inspirasi kepada pelajar melalui aktiviti sains dan kejuruteraan secara praktikal.',
        image1Url: 'assets/highlights/images/SH4.png',
        image2Url: 'assets/highlights/images/SH4.1.png',
        desc1En:
            'Curtin University Malaysia organised a “Fun with Science” showcase where students explored interactive experiments connecting classroom science concepts with real-world applications.',
        desc1Ms:
            'Curtin University Malaysia menganjurkan pameran “Fun with Science” di mana pelajar meneroka eksperimen interaktif yang menghubungkan konsep sains bilik darjah dengan aplikasi dunia sebenar.',
        desc2En:
            'Students observed exciting demonstrations including Elephant Toothpaste reactions, lava lamps, and non-Newtonian fluids, helping them understand chemistry and physics through engaging experiments.',
        desc2Ms:
            'Pelajar memerhati demonstrasi menarik termasuk tindak balas Ubat Gigi Gajah, lampu lava, dan bendalir bukan Newton, membantu mereka memahami kimia dan fizik melalui eksperimen yang menarik.',
        skillsImageEn: 'assets/highlights/images/SH4.2_en.png',
        skillsImageMs: 'assets/highlights/images/SH4.2_ms.png',
        citationEn:
            'Curtin Malaysia brings science to life for SMK Lutong students. (2025, March 28). Curtin University Malaysia News.',
        citationMs:
            'Curtin Malaysia membawa sains ke dalam kehidupan pelajar SMK Lutong. (2025, Mac 28). Berita Curtin University Malaysia.',
        sourceUrl:
            'https://news.curtin.edu.my/news/curtin-malaysia-brings-science-to-life-for-smk-lutong-students/',
      ),
      Highlight(
        id: 5,
        titleEn: 'Samsung STEM Innovation Challenge',
        titleMs: 'Cabaran Inovasi STEM Samsung',
        subtitleEn:
            'Malaysian students create innovative STEM solutions in a national technology competition.',
        subtitleMs:
            'Pelajar Malaysia mencipta penyelesaian STEM inovatif dalam pertandingan teknologi kebangsaan.',
        image1Url: 'assets/highlights/images/SH5.png',
        image2Url: '',
        desc1En:
            'Students developed innovative prototypes solving community problems using STEM knowledge and creativity.',
        desc1Ms:
            'Pelajar membangunkan prototaip inovatif yang menyelesaikan masalah komuniti menggunakan pengetahuan STEM dan kreativiti.',
        desc2En: '',
        desc2Ms: '',
        skillsImageEn: 'assets/highlights/images/SH5.2_en.png',
        skillsImageMs: 'assets/highlights/images/SH5.2_ms.png',
        citationEn:
            'Samsung Newsroom Malaysia. (2025, December 10). Young Innovators Shine at Samsung Solve for Tomorrow 2025 Grand Finale.',
        citationMs:
            'Samsung Newsroom Malaysia. (2025, Disember 10). Young Innovators Shine at Samsung Solve for Tomorrow 2025 Grand Finale.',
        sourceUrl:
            'https://news.samsung.com/my/young-innovators-shine-at-samsung-solve-for-tomorrow-2025-grand-finale',
      ),
      Highlight(
        id: 6,
        titleEn: 'Young Scientist Innovator',
        titleMs: 'Inovator Saintis Muda',
        subtitleEn:
            'Teen inventor develops innovative concept addressing skin cancer treatment accessibility.',
        subtitleMs:
            'Pencipta remaja membangunkan konsep inovatif menangani kebolehcapaian rawatan kanser kulit.',
        image1Url: 'assets/highlights/images/SH6.png',
        image2Url: 'assets/highlights/images/SH6.1.png',
        desc1En:
            'Teen inventor Heman Bekele won the 3M Young Scientist Challenge with a prototype soap concept designed to help treat skin cancer.',
        desc1Ms:
            'Pencipta remaja Heman Bekele memenangi Cabaran Saintis Muda 3M dengan konsep prototaip sabun yang direka untuk membantu merawat kanser kulit.',
        desc2En:
            'Inspired by healthcare challenges, his project shows how young scientists can apply research and creativity to address global medical problems.',
        desc2Ms:
            'Diilhamkan oleh cabaran penjagaan kesihatan, projeknya menunjukkan bagaimana saintis muda boleh menggunakan penyelidikan dan kreativiti untuk menangani masalah perubatan global.',
        skillsImageEn: 'assets/highlights/images/SH6.2_en.png',
        skillsImageMs: 'assets/highlights/images/SH6.2_ms.png',
        citationEn:
            'Ruf, J. (2023, October 11). A ninth grader from Annandale is “America’s Top Young Scientist.” Washingtonian.',
        citationMs:
            'Ruf, J. (2023, Oktober 11). Seorang pelajar gred sembilan dari Annandale ialah “Saintis Muda Teratas Amerika.” Washingtonian.',
        sourceUrl:
            'https://www.washingtonian.com/2023/10/11/a-ninth-grader-from-annandale-is-americas-top-young-scientist/',
        videoUrl: 'assets/highlights/videos/h6.mp4',
      ),
    ];
  }
}
