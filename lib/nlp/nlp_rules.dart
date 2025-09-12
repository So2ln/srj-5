// // 텍스트를 소문자/정규화 → 키워드 매칭 → raw 점수 계산
// // 강화/약화어로 가중
// // 폭력 의도 플래그 추출

// // Dart 의사코드 느낌: double lexScore(String note, List words) { ... }
// // Map<String,double> ruleTextScore(String note) { ... }
// // bool detectOtherHarm(String note) { ... }

// import 'package:srj_5/nlp/lexicons_ko.dart';

// String normalize(String s) {
//   var t = s.trim();
//   // 공백/반복 문자/자모 결합 등 간단 정규화
//   t = t.replaceAll(RegExp(r'\s+'), ' ');
//   t = t.replaceAll('ㅋㅋ', '');
//   t = t.replaceAll('ㅠㅠ', '');
//   return t;
// }

// // note에 특정 키워드 존재 비율 기반 점수 (아주 단순 v0)
// double lexScore(String note, List<String> words) {
//   final text = note;
//   int hits = 0;
//   for (final w in words) {
//     if (text.contains(w)) hits++;
//   }
//   if (hits == 0) return 0.0;
//   final lengthPenalty = (text.split(' ').length + 3);
//   final raw = hits / lengthPenalty;
//   return raw.clamp(0.0, 1.0);
// }

// // 룰 기반 텍스트 점수 + 보조 플래그/evidence 추출
// class NlpResult {
//   final Map<String, double> textScores;
//   final bool otherHarm;
//   final List<String> evidence;
//   NlpResult({
//     required this.textScores,
//     required this.otherHarm,
//     required this.evidence,
//   });
// }

// NlpResult ruleTextScore(String rawNote) {
//   final note = normalize(rawNote);
//   final Map<String, double> m = {
//     'anxiety': 0,
//     'depression': 0,
//     'panic': 0,
//     'anger': 0,
//     'numb': 0,
//     'burnout': 0,
//     'recovery': 0,
//   };
//   final evidence = <String>[];

//   keywordMap.forEach((cluster, words) {
//     final sc = lexScore(note, words);
//     if (sc > 0) {
//       m[cluster] = sc;
//       // evidence는 상위 1~2개만 간단 추출
//       for (final w in words) {
//         if (note.contains(w) && evidence.length < 3) evidence.add(w);
//       }
//     }
//   });

//   // 강화/약화 가중
//   final mult = strongRe.hasMatch(note)
//       ? 1.2
//       : weakRe.hasMatch(note)
//       ? 0.85
//       : 1.0;
//   m.updateAll((k, v) => (v * mult).clamp(0.0, 1.0));

//   // 부정/완곡 톤(참고용) — v0에서는 직접 가중치 적용하지 않고, 필요시 추가
//   final hasNeg = negationRe.hasMatch(note);
//   final hasEuph = euphemismRe.hasMatch(note);
//   // 예: 긍정 단어 앞의 부정은 분노/우울 쪽 가중할 수 있음 (추후)

//   // 타해 의도 감지
//   final otherHarm = otherHarmRe.hasMatch(note);
//   if (otherHarm &&
//       !evidence.any(
//         (e) =>
//             e.contains('죽') ||
//             e.contains('패') ||
//             e.contains('부셔') ||
//             e.contains('쪼개'),
//       )) {
//     evidence.add('타해 의도 표현');
//   }

//   return NlpResult(textScores: m, otherHarm: otherHarm, evidence: evidence);
// }
