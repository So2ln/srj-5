// lib/services/llm_api_client.dart
import 'package:srj_5/models/app_models.dart';
import 'dart:math';

class LlmApiClient {
  final Random _random = Random();

  Future<LLMResponse> getAnalysis(String note) async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(500)));
    Map<EmotionCluster, double> scores = {
      for (var cluster in EmotionCluster.values)
        cluster: _random.nextDouble() * 0.3,
    };
    if (note.contains('불안') || note.contains('떨려')) {
      scores[EmotionCluster.anxiety] = 0.6 + _random.nextDouble() * 0.3;
    } else if (note.contains('우울') || note.contains('슬퍼')) {
      scores[EmotionCluster.depression] = 0.7 + _random.nextDouble() * 0.2;
    } else {
      scores[EmotionCluster.values[_random.nextInt(
            EmotionCluster.values.length,
          )]] =
          0.5 + _random.nextDouble() * 0.2;
    }
    return LLMResponse(
      clusterScores: scores,
      evidence: ['텍스트', '분석', '키워드'],
      intent: note.contains('죽고') ? 'self-harm-medium' : 'none',
      isIronic: note.contains('ㅋ'),
    );
  }
}
