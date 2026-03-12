mixin CareerLogic {
  List<dynamic> dbQuestions = [];
  List<dynamic> allCareers = [];
  final Map<int, int> singleChoices = {};
  final Set<int> multiChoicesQ5 = {};

  void applyScore(String? tag, Map<String, int> scores, int weight) {
    if (tag == null) return;
    final t = tag.toLowerCase();
    if (t.contains('sci')) {
      scores['Science'] = (scores['Science'] ?? 0) + weight;
    } else if (t.contains('tech')) {
      scores['Technology'] = (scores['Technology'] ?? 0) + weight;
    } else if (t.contains('eng')) {
      scores['Engineering'] = (scores['Engineering'] ?? 0) + weight;
    } else if (t.contains('math')) {
      scores['Mathematics'] = (scores['Mathematics'] ?? 0) + weight;
    } else if (t == 'all') {
      scores.updateAll((k, v) => v + weight);
    }
  }

  String calculateSuggestedField() {
    var scores = {
      'Science': 0,
      'Mathematics': 0,
      'Engineering': 0,
      'Technology': 0,
    };
    for (var entry in singleChoices.entries) {
      final q = dbQuestions.firstWhere(
        (e) => e['id'].toString() == entry.key.toString(),
      );
      final opt = (q['options'] as List).firstWhere(
        (o) => o['id'].toString() == entry.value.toString(),
      );
      applyScore(opt['score_tag'], scores, 2);
    }
    if (dbQuestions.isNotEmpty) {
      final qSkills = dbQuestions.last;
      for (var optId in multiChoicesQ5) {
        final opt = (qSkills['options'] as List).firstWhere(
          (o) => o['id'].toString() == optId.toString(),
        );
        applyScore(opt['score_tag'], scores, 1);
      }
    }
    return scores.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  void resetLogicState() {
    singleChoices.clear();
    multiChoicesQ5.clear();
  }
}
