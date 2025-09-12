// import 'dart:convert';
// import '../models/analysis_models.dart';

// class LlmApiClient {
//   final String _apiUrl = "YOUR_LLM_API_ENDPOINT"; // 여기에 실제 API URL을 입력하세요.

//   // LLM 호출을 위한 시스템 프롬프트 (설계 내용 반영)
//   final String _systemPrompt = """
// You are an assistant that maps emotional text to clinical clusters.
// You MUST ONLY return a JSON object in the following format. Do not add any other text.
// The scores must be between 0.0 and 1.0.
// Provide 1 to 5 evidence keywords from the text.
// The 'intent' can be 'self_harm_low', 'self_harm_medium', 'self_harm_high', 'other_harm_low', 'other_harm_medium', 'other_harm_high', or 'none'.
// The 'irony_or_negation' must be a boolean.

// JSON Schema:
// {
//   "text_cluster_scores": {
//     "depression": 0.0,
//     "anxiety": 0.0,
//     "panic": 0.0,
//     "anger": 0.0,
//     "numbness": 0.0,
//     "burnout": 0.0,
//     "calm": 0.0
//   },
//   "evidence": ["keyword1", "keyword2"],
//   "intent": "none",
//   "irony_or_negation": false
// }
// """;

//   Future<LLMResponse> getAnalysis(String note, Map<String, dynamic> meta) async {
//     final body = {
//       'system_prompt': _systemPrompt,
//       'user_input': {
//         'note': note, // 원문
//         'meta': meta, // icon, intensity, contexts, time
//       }
//     };

//     // 실제 API 호출 (http 패키지 필요)
//     // final response = await http.post(
//     //   Uri.parse(_apiUrl),
//     //   headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer YOUR_API_KEY'},
//     //   body: jsonEncode(body),
//     // );

//     // 아래는 더미 응답입니다. 실제로는 위 API 호출 결과를 사용해야 합니다.
//     await Future.delayed(const Duration(milliseconds: 300)); // 네트워크 지연 흉내
//     final mockResponseJson = {
//       "text_cluster_scores": {
//         "depression": 0.15, "anxiety": 0.82, "panic": 0.3, "anger": 0.1,
//         "numbness": 0.05, "burnout": 0.4, "calm": 0.0
//       },
//       "evidence": ["손이 떨려", "망할 것 같아"],
//       "intent": "none",
//       "irony_or_negation": false
//     };

//     // if (response.statusCode == 200) {
//     //   final data = jsonDecode(response.body);
//     //   return _parseResponse(data);
//     // } else {
//     //   throw Exception('Failed to call LLM API');
//     // }
//     return _parseResponse(mockResponseJson);
//   }

//   // JSON 응답을 LLMResponse 객체로 파싱
//   LLMResponse _parseResponse(Map<String, dynamic> data) {
//     final scoresData = data['text_cluster_scores'] as Map<String, dynamic>;
//     final clusterScores = scoresData.map((key, value) {
//       try {
//         final cluster = EmotionCluster.values.byName(key);
//         return MapEntry(cluster, value.toDouble());
//       } catch (e) {
//         // 알려지지 않은 클러스터 키는 무시
//         return const MapEntry(EmotionCluster.calm, -1.0);
//       }
//     })..removeWhere((key, value) => value == -1.0);

//     return LLMResponse(
//       clusterScores: clusterScores,
//       evidence: List<String>.from(data['evidence']),
//       intent: data['intent'],
//       isIronic: data['irony_or_negation'],
//     );
//   }
// }
