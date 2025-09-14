// // LLM API의 응답을 파싱하기 위한 전용 모델
// class LlmAnalysisResult {
//   final Map<String, double> clusterScores;
//   final List<String> evidence;
//   final String intent;
//   final bool ironyOrNegation;

//   LlmAnalysisResult({
//     required this.clusterScores,
//     required this.evidence,
//     required this.intent,
//     required this.ironyOrNegation,
//   });

//   factory LlmAnalysisResult.fromJson(Map<String, dynamic> json) {
//     // cluster_scores 파싱
//     var scoresJson = json['cluster_scores'] as Map<String, dynamic>;
//     Map<String, double> scores = scoresJson.map((key, value) {
//       return MapEntry(key, value.toDouble());
//     });

//     // evidence 파싱
//     var evidenceList = json['evidence'] as List;
//     List<String> evidence = evidenceList
//         .map((item) => item.toString())
//         .toList();

//     return LlmAnalysisResult(
//       clusterScores: scores,
//       evidence: evidence,
//       intent: json['intent'] ?? 'none',
//       ironyOrNegation: json['irony_or_negation'] ?? false,
//     );
//   }
// }
