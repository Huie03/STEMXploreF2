import 'package:flutter_localization/flutter_localization.dart';

// The Map of Locales for main.dart
const List<MapLocale> locales = [
  MapLocale('en', endata),
  MapLocale('ms', msdata),
];

// ENGLISH DATA
const Map<String, dynamic> endata = {
  'home_title': 'STEMXplore F2',
  'info_title': 'Info',
  'bookmark_title': 'Bookmark',
  'last_access': 'Last access learning materials:',
  'science': 'Science',
  'chapter': 'Chapter',
  'career_match': 'Interest–career matching result:',
  'stemInfo': 'STEM Info',
  'learning': 'Learning Material',
  'quiz': 'Quiz Game',
  'careers': 'STEM Careers',
  'challenge': 'Daily Challenge',
  'faq': 'Frequent Asked Questions',
  'highlights': 'STEM Highlights:',
  'read_more': 'Read more',
  'info_desc': 'STEMXplore F2 is a mobile learning application...',

  // DAILY INFO LIST
  'daily_info': [
    {
      'title': 'Nutrition',
      'fact':
          'Carbohydrates are the main source of energy for our body and help us stay active.',
      'image': 'assets/images/nutrition.png',
    },
    {
      'title': 'Biodiversity',
      'fact':
          'Biodiversity refers to the variety of living organisms in a habitat and helps keep ecosystems stable.',
      'image': 'assets/images/biodiversity.png',
    },
    {
      'title': 'Ecosystem',
      'fact':
          'An ecosystem is a community of living organisms interacting with each other and their environment.',
      'image': 'assets/images/ecosystem.png',
    },
  ],
  // QUIZ UI & RESULTS
  'quiz_start_title': 'Discover Your STEM Skills',
  'quiz_start_desc': 'Answer questions to see which STEM field fits you best.',
  'quiz_next': 'Next',
  'quiz_back': 'Back',
  'quiz_done': 'Done',
  'quiz_finish_title': 'You’ve Finished Your\nCareer Discovery!',
  'suggested_field': 'Suggested field:',
  'explore_all': 'Explore All',
  'replay': 'Replay',
  'skill_reminder': 'Please select at least 3 skills.',

  // CAREER FIELDS
  'field_science': 'Science',
  'field_math': 'Mathematics',
  'field_eng': 'Engineering',
  'field_tech': 'Technology',

  // MIND MAP TEXTS
  'mind_map_label': 'Mind map image for',
};

// MALAY DATA
const Map<String, dynamic> msdata = {
  'home_title': 'STEMXplore F2',
  'info_title': 'Maklumat',
  'bookmark_title': 'Penanda Buku',
  'last_access': 'Bahan pembelajaran terakhir dicapai:',
  'science': 'Sains',
  'chapter': 'Bab',
  'career_match': 'Keputusan padanan minat-kerjaya:',
  'stemInfo': 'Info STEM',
  'learning': 'Bahan Pembelajaran',
  'quiz': 'Permainan Kuiz',
  'careers': 'Kerjaya STEM',
  'challenge': 'Cabaran Harian',
  'faq': 'Soalan Lazim',
  'highlights': 'Sorotan STEM:',
  'read_more': 'Baca lagi',
  'info_desc': 'STEMXplore F2 adalah aplikasi pembelajaran mudah alih...',

  // DAILY INFO LIST
  'daily_info': [
    {
      'title': 'Nutrisi',
      'fact':
          'Karbohidrat adalah sumber tenaga utama bagi tubuh kita dan membantu kita kekal aktif.',
      'image': 'assets/images/nutrition.png',
    },
    {
      'title': 'Kepelbagaian Biologi',
      'fact':
          'Kepelbagaian biologi merujuk kepada kepelbagaian organisma hidup dalam sesuatu habitat.',
      'image': 'assets/images/biodiversity.png',
    },
    {
      'title': 'Ekosistem',
      'fact':
          'Ekosistem ialah komuniti organisma hidup yang berinteraksi antara satu sama lain dan persekitaran.',
      'image': 'assets/images/ecosystem.png',
    },
  ],

  // QUIZ UI & KEPUTUSAN
  'quiz_start_title': 'Temui Kemahiran STEM Anda',
  'quiz_start_desc':
      'Jawab soalan untuk melihat bidang STEM yang paling sesuai untuk anda.',
  'quiz_next': 'Seterusnya',
  'quiz_back': 'Kembali',
  'quiz_done': 'Siap',
  'quiz_finish_title': 'Anda Telah Menamatkan\nPenemuan Kerjaya Anda!',
  'suggested_field': 'Bidang dicadangkan:',
  'explore_all': 'Teroka Semua',
  'replay': 'Main Semula',
  'skill_reminder': 'Sila pilih sekurang-kurangnya 3 kemahiran.',

  // BIDANG KERJAYA
  'field_science': 'Sains',
  'field_math': 'Matematik',
  'field_eng': 'Kejuruteraan',
  'field_tech': 'Teknologi',

  // TEKS PETA MINDA
  'mind_map_label': 'Imej peta minda untuk',
};
