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
  });

  factory Highlight.fromJson(Map<String, dynamic> json) {
    // Helper to extract nested map data safely
    Map<String, dynamic> getMap(dynamic data) =>
        data is Map ? Map<String, dynamic>.from(data) : {};

    final titleData = getMap(json['title']);
    final subtitleData = getMap(json['subtitle']);
    final descData = getMap(json['descriptions']);
    final desc1Data = getMap(descData['desc1']);
    final desc2Data = getMap(descData['desc2']);
    final skillsData = getMap(json['skills']);
    final sourceData = getMap(json['source']);
    final citationData = getMap(sourceData['citation']);

    return Highlight(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      titleEn: titleData['en']?.toString() ?? '',
      titleMs: titleData['ms']?.toString() ?? '',
      subtitleEn: subtitleData['en']?.toString() ?? '',
      subtitleMs: subtitleData['ms']?.toString() ?? '',
      image1Url: json['images']?['image1']?.toString() ?? '',
      image2Url: json['images']?['image2']?.toString() ?? '',
      desc1En: desc1Data['en']?.toString() ?? '',
      desc1Ms: desc1Data['ms']?.toString() ?? '',
      desc2En: desc2Data['en']?.toString() ?? '',
      desc2Ms: desc2Data['ms']?.toString() ?? '',
      skillsImageEn: skillsData['en']?.toString() ?? '',
      skillsImageMs: skillsData['ms']?.toString() ?? '',
      citationEn: citationData['en']?.toString() ?? '',
      citationMs: citationData['ms']?.toString() ?? '',
      sourceUrl: sourceData['url']?.toString() ?? '',
    );
  }
}
