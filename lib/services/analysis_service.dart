// lib/services/analysis_service.dart
import 'package:flutter/foundation.dart';
import 'package:srj_5/models/app_models.dart';
import 'package:srj_5/services/llm_api_client.dart';
import 'dart:math';

abstract class BaseAnalysisService {
  Future<AnalysisResult?> analyzeEmotion(AnalysisInput input);
  Future<ChatMessage?> getChatResponse(
    String userMessage,
    UserProfile userProfile,
  );
}

class MockAnalysisService implements BaseAnalysisService {
  final LlmApiClient _llmApiClient = LlmApiClient();
  final Random _random = Random();

  @override
  Future<AnalysisResult?> analyzeEmotion(AnalysisInput input) async {
    try {
      LLMResponse? llmResponse;
      if (_shouldCallLLM(input.note)) {
        llmResponse = await _llmApiClient.getAnalysis(input.note!);
      }
      final mlScores = _runMLScorer(input, llmResponse);
      final gScore = _calculateGScore(input, mlScores);
      final mainCluster = _findMainCluster(mlScores);
      _performSafetyCheck(llmResponse);
      final solution = _mapSolution(mainCluster, input.userProfile);
      final reasonCard = _createReasonCard(mainCluster, gScore);
      return AnalysisResult(
        solution: solution,
        reasonCard: reasonCard,
        gScore: gScore,
        mainCluster: mainCluster,
      );
    } catch (e) {
      debugPrint("분석 중 오류 발생: $e");
      return null;
    }
  }

  @override
  Future<ChatMessage?> getChatResponse(
    String userMessage,
    UserProfile userProfile,
  ) async {
    try {
      await Future.delayed(Duration(milliseconds: 600 + _random.nextInt(800)));
      String characterType = userProfile.characterType;
      bool isAnalytical = characterType.contains('분석형');
      String tone = characterType.split('+')[0];
      String responseText = isAnalytical
          ? "'$userMessage' 라고 말한 것을 보면, 아마 어떤 기대가 충족되지 않아서 속상했던 것 같아요. 그 감정의 원인이 무엇이었을까요? 정말 힘들었겠네요."
          : "'$userMessage' 라니... 정말 속상했겠어요. 그렇게 느끼는 건 너무 당연해요. 마음이 많이 힘들었을 것 같아 걱정되네요.";

      switch (tone) {
        case '귀욤 감성':
          responseText = responseText
              .replaceAll('요.', '용.')
              .replaceAll('네요.', '네용.')
              .replaceAll('다.', '당.❤️');
          break;
        case '10찐따':
          responseText =
              "(웅얼웅얼...) 저기... '$userMessage' 라고 하셨는데... (눈치) 진짜 힘드셨겠어요... 제가... 뭘 도와드릴 수 있을까요...?";
          break;
        case '따뜻':
          responseText =
              "괜찮아요. '$userMessage' 라고 느낄 수 있어요. 따뜻한 차 한잔 하면서 같이 이야기 나눠볼까요? 당신은 혼자가 아니에요.";
          break;
        default:
          break;
      }
      return ChatMessage(text: responseText, isUserMessage: false);
    } catch (e) {
      debugPrint("채팅 응답 생성 중 오류: $e");
      return null;
    }
  }

  bool _shouldCallLLM(String? note) =>
      note != null &&
      (note.contains('죽고') ||
          note.contains('자해') ||
          note.contains('...') ||
          note.contains('ㅋ') ||
          note.length > 30);
  Map<EmotionCluster, double> _runMLScorer(AnalysisInput i, LLMResponse? l) {
    Map<EmotionCluster, double> s = {
      for (var c in EmotionCluster.values) c: _random.nextDouble() * 0.1,
    };
    if (l != null) {
      l.clusterScores.forEach((c, sc) {
        s[c] = (s[c]! + sc) / 2;
      });
    }
    if (i.icon != null) {
      s[i.icon!.toCluster()] =
          (s[i.icon!.toCluster()]! + (i.intensity / 10)) * 1.5;
    }
    if (i.userProfile.rsesScore < 20) {
      s[EmotionCluster.depression] = (s[EmotionCluster.depression] ?? 0) * 1.2;
      s[EmotionCluster.anxiety] = (s[EmotionCluster.anxiety] ?? 0) * 1.1;
    }
    return s;
  }

  double _calculateGScore(AnalysisInput i, Map<EmotionCluster, double> s) {
    const w = {
      EmotionCluster.depression: 1.0,
      EmotionCluster.anxiety: 0.9,
      EmotionCluster.panic: 1.2,
      EmotionCluster.anger: 0.8,
      EmotionCluster.numbness: 0.7,
      EmotionCluster.burnout: 1.1,
      EmotionCluster.calm: -0.5,
    };
    double sum = s.entries.fold(0.0, (p, e) => p + (e.value * (w[e.key] ?? 0)));
    return ((sum + i.intensity / 10) / 2 * 10).clamp(0.0, 10.0);
  }

  EmotionCluster _findMainCluster(Map<EmotionCluster, double> s) {
    var sorted = s.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted
        .firstWhere(
          (e) => e.key != EmotionCluster.calm,
          orElse: () => sorted.first,
        )
        .key;
  }

  void _performSafetyCheck(LLMResponse? l) {
    if (l != null && l.intent.contains('harm')) {
      debugPrint("안전 게이트 발동! 의도: ${l.intent}");
    }
  }

  Solution _mapSolution(EmotionCluster c, UserProfile p) {
    if (p.rsesScore < 20 &&
        (c == EmotionCluster.depression || c == EmotionCluster.anxiety)) {
      return const Solution(
        routineName: '안전한 장소 떠올리기',
        routineDuration: 120,
        miniAction: '가장 편안했던 기억 적어보기',
      );
    }
    switch (c) {
      case EmotionCluster.anxiety:
        return const Solution(
          routineName: '4-7-8 호흡하기',
          routineDuration: 120,
          miniAction: '주변의 파란색 물건 3가지 찾기',
        );
      case EmotionCluster.anger:
        return const Solution(
          routineName: '감각 알아차리기',
          routineDuration: 120,
          miniAction: '얼음물에 손 10초 담그기',
        );
      case EmotionCluster.burnout:
        return const Solution(
          routineName: '숲 속 걷기 (영상)',
          routineDuration: 180,
          miniAction: '창 밖 1분 보기',
        );
      default:
        return const Solution(
          routineName: '오늘의 감사한 일 찾기',
          routineDuration: 120,
          miniAction: '고마운 사람에게 짧은 메시지 보내기',
        );
    }
  }

  ReasonCard _createReasonCard(EmotionCluster c, double g) => ReasonCard(
    title: "현재 당신의 마음 신호",
    description:
        "종합적인 마음 점수(G-Score)는 ${g.toStringAsFixed(1)}점이며, 주로 '${c.name}'와 관련된 신호가 보여요. 잠시 쉬어가는 시간을 추천합니다.",
  );
}
