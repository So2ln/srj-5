// import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/foundation.dart';
// import 'package:srj_5/models/app_models.dart';
// import 'package:srj_5/models/llm_result.dart';
// import 'package:srj_5/services/llm_api_client.dart';

// // 실제/모의 서비스를 전환할 수 있도록 인터페이스(규격) 정의
// abstract class BaseApiService {
//   Future<AnalysisResult?> analyzeEmotion({
//     String? note,
//     String? icon,
//     int? intensity,
//     List<String>? contexts,
//     UserProfile? userProfile,
//   });
//   Future<ChatMessage> getChatResponse({
//     required String userMessage,
//     required UserProfile userProfile,
//   });
// }

// // 백엔드 없이 앱을 테스트하기 위한 모의 API 서비스
// class MockApiService implements BaseApiService {
//   final Random _random = Random();
//   final LlmApiClient _llmApiClient = LlmApiClient();

//   // 이모티콘 탭 등을 통한 감정 분석 요청 처리
//   @override
//   Future<AnalysisResult?> analyzeEmotion({
//     String? note,
//     String? icon,
//     int? intensity,
//     List<String>? contexts,
//     UserProfile? userProfile,
//   }) async {
//     await Future.delayed(Duration(milliseconds: 600 + _random.nextInt(400)));

//     debugPrint("--- Mock API 호출 (analyzeEmotion) ---");
//     debugPrint("입력 노트: $note / 아이콘: $icon");

//     bool shouldUseLLM = _shouldCallLLM(note);
//     debugPrint("LLM 호출 여부: $shouldUseLLM");

//     LlmAnalysisResult? llmResult;
//     if (shouldUseLLM) {
//       // 실제 LLM API를 호출하지 않고 시뮬레이션만 진행합니다.
//       // llmResult = await _llmApiClient.analyzeWithLlm(note: note!);
//       llmResult = LlmAnalysisResult(
//         clusterScores: {'anxiety': 0.8, 'depression': 0.4},
//         evidence: ['떨린다', '망할 것 같다'],
//         intent: 'self-harm-low',
//         ironyOrNegation: false,
//       );
//     }

//     String mainCluster;
//     String reasonCard;
//     Map<String, double> finalProbabilities;

//     if (llmResult != null) {
//       mainCluster = llmResult.clusterScores.entries
//           .reduce((a, b) => a.value > b.value ? a : b)
//           .key;
//       finalProbabilities = _normalizeProbabilities(llmResult.clusterScores);
//       reasonCard =
//           "'${llmResult.evidence.join(', ')}' 표현에서 LLM이 복합적인 감정을 분석했어요.";
//     } else {
//       mainCluster = icon ?? _determineClusterFromNote(note) ?? 'anxiety';
//       finalProbabilities = _generateProbabilities(mainCluster);
//       reasonCard =
//           "'${_getEvidenceFromNote(note)}' 신호와 ${icon ?? '입력된'} 감정을 고려했을 때, 현재 '$mainCluster' 상태일 수 있어요.";
//     }

//     if (userProfile != null && userProfile.rsesScore < 20) {
//       finalProbabilities['depression'] =
//           (finalProbabilities['depression'] ?? 0) * 1.2;
//       finalProbabilities['anxiety'] =
//           (finalProbabilities['anxiety'] ?? 0) * 1.1;
//     }

//     return AnalysisResult(
//       mainCluster: mainCluster,
//       clusterProbabilities: _normalizeProbabilities(finalProbabilities),
//       intervention: _mapIntervention(mainCluster, userProfile),
//       reasonCard: reasonCard,
//     );
//   }

//   // 채팅 메시지에 대한 캐릭터 응답 생성
//   @override
//   Future<ChatMessage> getChatResponse({
//     required String userMessage,
//     required UserProfile userProfile,
//   }) async {
//     await Future.delayed(Duration(milliseconds: 600 + _random.nextInt(800)));
//     debugPrint("--- Mock API 호출 (getChatResponse) ---");
//     debugPrint("캐릭터 타입: ${userProfile.characterType}");

//     String characterType = userProfile.characterType;
//     String responseText = "";

//     bool isAnalytical = characterType.contains('분석형');
//     String tone = characterType.split('+')[0];

//     // 1. 내용 생성 (분석형 vs 공감형)
//     if (isAnalytical) {
//       responseText =
//           "'$userMessage' 라고 말한 것을 보면, 아마 어떤 기대가 충족되지 않아서 속상했던 것 같아요. 그 감정의 원인이 무엇이었을까요? 정말 힘들었겠네요.";
//     } else {
//       // 공감형
//       responseText =
//           "'$userMessage' 라니... 정말 속상했겠어요. 그렇게 느끼는 건 너무 당연해요. 마음이 많이 힘들었을 것 같아 걱정되네요.";
//     }

//     // 2. 말투 적용
//     switch (tone) {
//       case '귀욤 감성':
//         responseText = responseText
//             .replaceAll('요.', '용.')
//             .replaceAll('네요.', '네용.')
//             .replaceAll('다.', '당.❤️');
//         break;
//       case '10찐따':
//         responseText =
//             "(웅얼웅얼...) 저기... '$userMessage' 라고 하셨는데... (눈치) 진짜 힘드셨겠어요... 제가... 뭘 도와드릴 수 있을까요...?";
//         break;
//       case '따뜻':
//         responseText =
//             "괜찮아요. '$userMessage' 라고 느낄 수 있어요. 따뜻한 차 한잔 하면서 같이 이야기 나눠볼까요? 당신은 혼자가 아니에요.";
//         break;
//       case '공손':
//       default:
//         break;
//     }

//     return ChatMessage(text: responseText, isUserMessage: false);
//   }

//   // --- 아래는 내부에서 사용하는 헬퍼 함수들 ---

//   bool _shouldCallLLM(String? note) {
//     if (note == null) return false;
//     if (note.contains('죽고') || note.contains('자해')) return true;
//     if (note.contains('...') || note.contains('ㅋ') || note.length > 50)
//       return true;
//     return false;
//   }

//   String? _determineClusterFromNote(String? note) {
//     if (note == null) return null;
//     if (note.contains('화나') || note.contains('짜증')) return 'anger';
//     if (note.contains('우울') || note.contains('슬퍼')) return 'depression';
//     if (note.contains('불안') || note.contains('떨려')) return 'anxiety';
//     if (note.contains('지쳐') || note.contains('번아웃')) return 'burnout';
//     return 'anxiety';
//   }

//   String _getEvidenceFromNote(String? note) {
//     if (note == null) return "입력된";
//     if (note.contains('떨려')) return "떨림";
//     if (note.contains('화나')) return "화남";
//     return "여러가지";
//   }

//   Map<String, double> _generateProbabilities(String mainCluster) {
//     Map<String, double> probs = {
//       'depression': 0.1,
//       'anxiety': 0.1,
//       'anger': 0.1,
//       'panic': 0.1,
//       'burnout': 0.1,
//       'calm': 0.05,
//     };
//     probs[mainCluster] = 0.45;
//     return _normalizeProbabilities(probs);
//   }

//   Map<String, double> _normalizeProbabilities(Map<String, double> probs) {
//     double sum = probs.values.fold(0.0, (prev, element) => prev + element);
//     if (sum == 0) return probs;
//     return probs.map((key, value) => MapEntry(key, value / sum));
//   }

//   Intervention _mapIntervention(String cluster, UserProfile? userProfile) {
//     bool isLowRSES = (userProfile?.rsesScore ?? 30) < 20;
//     if (isLowRSES && (cluster == 'depression' || cluster == 'anxiety')) {
//       return Intervention(routineName: '안전한 장소 떠올리기', type: 'grounding');
//     }
//     switch (cluster) {
//       case 'anxiety':
//         return Intervention(routineName: '4-7-8 호흡하기', type: 'breathing');
//       case 'anger':
//         return Intervention(routineName: '감각 알아차리기', type: 'sensory');
//       case 'burnout':
//         return Intervention(routineName: '숲 속 걷기', type: 'nature');
//       default:
//         return Intervention(routineName: '오늘의 감사한 일 찾기', type: 'cognitive');
//     }
//   }
// }
