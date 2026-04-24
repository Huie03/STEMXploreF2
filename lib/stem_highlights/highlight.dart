import 'dart:convert';

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
  final List<Map<String, String?>> extraSources;

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
    this.extraSources = const [],
  });

  // inside highlight.dart
  factory Highlight.fromMap(Map<String, dynamic> map) {
    return Highlight(
      id: map['id'],
      titleEn: map['titleEn'] ?? '',
      titleMs: map['titleMs'] ?? '',
      subtitleEn: map['subtitleEn'] ?? '',
      subtitleMs: map['subtitleMs'] ?? '',
      image1Url: map['image1Url'] ?? '',
      image2Url: map['image2Url'] ?? '',
      desc1En: map['desc1En'] ?? '',
      desc1Ms: map['desc1Ms'] ?? '',
      desc2En: map['desc2En'] ?? '',
      desc2Ms: map['desc2Ms'] ?? '',
      skillsImageEn: map['skillsImageEn'] ?? '',
      skillsImageMs: map['skillsImageMs'] ?? '',
      citationEn: map['citationEn'] ?? '',
      citationMs: map['citationMs'] ?? '',
      sourceUrl: map['sourceUrl'] ?? '',
      videoUrl: map['videoUrl'],
      // This is the CRITICAL part for SQLite
      extraSources: map['extraSources'] != null && map['extraSources'] is String
          ? List<Map<String, String?>>.from(
              jsonDecode(
                map['extraSources'],
              ).map((x) => Map<String, String?>.from(x)),
            )
          : [],
    );
  }
}
