// lib/services/api_service.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:srj_5/models/app_models.dart';
import 'package:srj_5/models/llm_result.dart';
import 'package:srj_5/services/llm_api_client.dart';

abstract class BaseApiService {
  Future<AnalysisResult?> analyzeEmotion({
    String? note,
    String? icon,
    int? intensity,
    List<String>? contexts,
    UserProfile? userProfile,
  });
}

class MockApiService implements BaseApiService {
  final Random _random = Random();
  // --- 추가된 부분: LlmApiClient 인스턴스 생성 ---
  final LlmApiClient _llmApiClient = LlmApiClient();
  // ---------------------------------------------

  @override
  Future<AnalysisResult?> analyzeEmotion({
    String? note,
    String? icon,
    int? intensity,
    List<String>? contexts,
    UserProfile? userProfile,
  }) async {
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(700)));

    debugPrint("--- Mock API 호출 ---");
    debugPrint("입력 노트: $note");
    debugPrint("입력 아이콘: $icon");

    // --- 수정된 부분: LLM 게이트 로직과 실제 호출 연동 ---
    bool shouldUseLLM = _shouldCallLLM(note);
    debugPrint("LLM 호출 여부: $shouldUseLLM");

    LlmAnalysisResult? llmResult;
    if (shouldUseLLM) {
      // 실제 LLM API를 호출하지 않고, 시뮬레이션만 진행합니다.
      // 실제 테스트 시 아래 주석을 풀고, llm_api_client.dart의 API 키를 설정하세요.
      // llmResult = await _llmApiClient.analyzeWithLlm(note: note!);

      // 지금은 LLM 호출을 시뮬레이션하기 위한 더미 결과를 만듭니다.
      llmResult = LlmAnalysisResult(
        clusterScores: {'anxiety': 0.8, 'depression': 0.4},
        evidence: ['떨린다', '망할 것 같다'],
        intent: 'self-harm-low',
        ironyOrNegation: false,
      );
      debugPrint("LLM 호출 시뮬레이션 완료. 결과: ${llmResult.clusterScores}");
    }
    // ---------------------------------------------------

    String mainCluster;
    String reasonCard;
    Map<String, double> finalProbabilities;

    if (llmResult != null) {
      // LLM 결과가 있으면 그것을 기반으로 응답 생성
      mainCluster = llmResult.clusterScores.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      finalProbabilities = _normalizeProbabilities(llmResult.clusterScores);
      reasonCard =
          "'${llmResult.evidence.join(', ')}' 표현에서 LLM이 복합적인 감정을 분석했어요. '${mainCluster}' 상태일 수 있습니다.";
    } else {
      // LLM 결과가 없으면 기존 규칙 기반 로직 사용
      mainCluster = icon ?? _determineClusterFromNote(note) ?? 'anxiety';
      finalProbabilities = _generateProbabilities(mainCluster);
      reasonCard =
          "'${_getEvidenceFromNote(note)}' 신호와 ${icon ?? '입력된'} 감정을 고려했을 때, 현재 '$mainCluster' 상태일 수 있어요.";
    }

    // 개인화 가중치 적용
    if (userProfile != null && userProfile.rsesScore < 20) {
      finalProbabilities['depression'] =
          (finalProbabilities['depression'] ?? 0) * 1.2;
      finalProbabilities['anxiety'] =
          (finalProbabilities['anxiety'] ?? 0) * 1.1;
      debugPrint("자존감 낮음 -> 우울/불안 가중치 적용");
    }

    final result = AnalysisResult(
      mainCluster: mainCluster,
      clusterProbabilities: _normalizeProbabilities(finalProbabilities),
      intervention: _mapIntervention(mainCluster, userProfile),
      reasonCard: reasonCard,
    );

    return result;
  }

  bool _shouldCallLLM(String? note) {
    if (note == null) return false;
    if (note.contains('죽고') || note.contains('자해')) return true;
    if (note.contains('...') || note.contains('ㅋ') || note.length > 50)
      return true;
    return false;
  }

  String? _determineClusterFromNote(String? note) {
    if (note == null) return null;
    if (note.contains('화나') || note.contains('짜증')) return 'anger';
    if (note.contains('우울') || note.contains('슬퍼')) return 'depression';
    if (note.contains('불안') || note.contains('떨려')) return 'anxiety';
    if (note.contains('지쳐') || note.contains('번아웃')) return 'burnout';
    return 'anxiety';
  }

  String _getEvidenceFromNote(String? note) {
    if (note == null) return "입력된";
    if (note.contains('떨려')) return "떨림";
    if (note.contains('화나')) return "화남";
    return "여러가지";
  }

  Map<String, double> _generateProbabilities(String mainCluster) {
    Map<String, double> probs = {
      'depression': 0.1,
      'anxiety': 0.1,
      'anger': 0.1,
      'panic': 0.1,
      'burnout': 0.1,
      'calm': 0.05,
    };
    probs[mainCluster] = 0.45;
    return _normalizeProbabilities(probs);
  }

  Map<String, double> _normalizeProbabilities(Map<String, double> probs) {
    double sum = probs.values.fold(0.0, (prev, element) => prev + element);
    if (sum == 0) return probs;
    return probs.map((key, value) => MapEntry(key, value / sum));
  }

  Intervention _mapIntervention(String cluster, UserProfile? userProfile) {
    bool isLowRSES = (userProfile?.rsesScore ?? 30) < 20;

    if (isLowRSES && (cluster == 'depression' || cluster == 'anxiety')) {
      return Intervention(routineName: '안전한 장소 떠올리기', type: 'grounding');
    }

    switch (cluster) {
      case 'anxiety':
        return Intervention(routineName: '4-7-8 호흡하기', type: 'breathing');
      case 'anger':
        return Intervention(routineName: '감각 알아차리기', type: 'sensory');
      case 'burnout':
        return Intervention(routineName: '숲 속 걷기', type: 'nature');
      default:
        return Intervention(routineName: '오늘의 감사한 일 찾기', type: 'cognitive');
    }
  }
}
