// nlp(note) → { textScores: Map<String,double>, flags: {otherHarm: bool}, evidence: List }
// evidence는 매칭된 키워드 1~3개만 수집(‘빡치’, ‘갈궈’, ‘죽이-’ 등)

import '../models/checkin.dart';
import 'nlp_rules.dart';

class NlpEngine {
  NlpResult analyze(Checkin c) {
    return ruleTextScore(c.note);
  }
}
