// 입력:
// icon, intensity, contexts, timeOfDay, textScores 가중 합(예):
// icon: +0.30 해당 클러스터에
// intensity: +0.20*(intensity/10.0) 해당 icon 축에
// context:
// work → anxiety +0.05, burnout +0.05
// people → anxiety +0.08, anger +0.03
// night → depression +0.05
// time:
// morning → anxiety +0.05
// night → depression +0.03
// text: 각 클러스터 +0.15*textScores[cluster]
// pattern: v0에선 0.0 고정(나중에 최근7일 패턴 붙이기)

//정규화:
// 최대값이 1.0 넘으면 전체를 max로 나눠 0~1 사이 유지

//top/secondary:
// 최댓값 클러스터를 top으로, 그다음이 0.2 이상이면 secondary

import '../models/checkin.dart';

class GResult {
  final Map<String, double> scores;
  final String top;
  final String? secondary;
  GResult(this.scores, this.top, this.secondary);
}

GResult gScores({required Checkin c, required Map<String, double> textScores}) {
  final Map<String, double> s = {
    'anxiety': 0,
    'depression': 0,
    'panic': 0,
    'anger': 0,
    'numb': 0,
    'burnout': 0,
    'recovery': 0,
  };

  // 1) 아이콘 반영
  if (s.containsKey(c.icon)) s[c.icon] = s[c.icon]! + 0.30;

  // 2) 강도 (해당 아이콘 축에)
  final intensityNorm = (c.intensity / 10.0).clamp(0.0, 1.0);
  if (s.containsKey(c.icon)) s[c.icon] = s[c.icon]! + 0.20 * intensityNorm;

  // 3) 맥락
  for (final ctx in c.contexts) {
    switch (ctx) {
      case 'work':
        s['anxiety'] = s['anxiety']! + 0.05;
        s['burnout'] = s['burnout']! + 0.05;
        break;
      case 'people':
        s['anxiety'] = s['anxiety']! + 0.08;
        s['anger'] = s['anger']! + 0.03;
        break;
      case 'night':
        s['depression'] = s['depression']! + 0.05;
        break;
      case 'home':
        s['depression'] = s['depression']! + 0.02;
        break;
      case 'alone':
        s['depression'] = s['depression']! + 0.02;
        s['numb'] = s['numb']! + 0.02;
        break;
      case 'commute':
        s['panic'] = s['panic']! + 0.03;
        break;
    }
  }

  // 4) 시간대(간단 규칙)
  final hour = c.ts.hour;
  if (hour < 12) {
    s['anxiety'] = s['anxiety']! + 0.05;
  } else if (hour >= 22) {
    s['depression'] = s['depression']! + 0.03;
  }

  // 5) 텍스트 점수 가산
  textScores.forEach((k, v) {
    s[k] = (s[k]! + 0.15 * v).clamp(0.0, 1.0);
  });

  // 6) (선택) 최근 패턴 가산은 v0 제외

  // 정규화(최댓값 기준)
  final maxv = s.values.fold<double>(0.0, (p, c) => c > p ? c : p);
  if (maxv > 1.0) {
    s.updateAll((k, v) => v / maxv);
  }

  // 상위 후보 추출
  final sorted = s.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  final top = sorted.first.key;
  String? secondary;
  if (sorted.length > 1 && sorted[1].value >= 0.20) secondary = sorted[1].key;

  return GResult(s, top, secondary);
}
