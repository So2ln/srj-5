// run(checkin: Checkin) →
// nlpEngine.nlp(checkin.note) → textScores, flags, evidence
// fuseScores(...) → scores, top
// mapIntervention(top) → intervention
// reasonCard(...) → 문자열
// return {top, scores, intervention, reasonCard, safety: flags.otherHarm}

import 'package:srj_5/logic/g_scores.dart';
import 'package:srj_5/logic/solutions.dart';
import 'package:srj_5/models/solution.dart';

import '../models/checkin.dart';
import '../models/scores.dart';
import '../nlp/nlp_engine.dart';
import '../logic/reason_card.dart';

class RecommendUseCase {
  final _nlp = NlpEngine();

  Future<(ClusterScores, Solution, bool)> run(Checkin c) async {
    // 1) NLP 룰 점수
    final nlpRes = _nlp.analyze(c);

    // 2) 스코어 융합
    final fused = gScores(c: c, textScores: nlpRes.textScores);

    // 3) 개입 매핑
    final preset = pickPreset(fused.top);
    final steps = SolutionPreset.steps[preset] ?? [];

    // 4) 이유 카드
    final reason = buildReasonCard(
      icon: c.icon,
      intensity: c.intensity,
      contexts: c.contexts,
      evidence: nlpRes.evidence,
      topCluster: fused.top,
      preset: preset,
    );

    final scores = ClusterScores(
      scores: fused.scores,
      top: fused.top,
      secondary: fused.secondary,
    );
    final iv = Solution(preset: preset, steps: steps, reasonCard: reason);
    final safety = nlpRes.otherHarm; // true면 안전 카드/지연 버튼 노출
    return (scores, iv, safety);
  }
}
