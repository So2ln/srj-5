// lib/models/app_models.dart

// 분석 플로우에 사용되는 모든 데이터의 형태를 정의합니다.

enum EmotionCluster {
  depression,
  anxiety,
  panic,
  anger,
  numbness,
  burnout,
  calm;

  factory EmotionCluster.fromString(String value) {
    return EmotionCluster.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EmotionCluster.anxiety,
    );
  }
}

enum EmotionIcon {
  sad,
  anxious,
  fearful,
  angry,
  empty,
  tired,
  calm;

  EmotionCluster toCluster() {
    switch (this) {
      case EmotionIcon.sad:
        return EmotionCluster.depression;
      case EmotionIcon.anxious:
        return EmotionCluster.anxiety;
      case EmotionIcon.fearful:
        return EmotionCluster.panic;
      case EmotionIcon.angry:
        return EmotionCluster.anger;
      case EmotionIcon.empty:
        return EmotionCluster.numbness;
      case EmotionIcon.tired:
        return EmotionCluster.burnout;
      case EmotionIcon.calm:
        return EmotionCluster.calm;
    }
  }
}

class UserProfile {
  final String userId;
  final String nickname;
  final String characterType;
  final int rsesScore;
  UserProfile({
    required this.userId,
    required this.nickname,
    required this.characterType,
    required this.rsesScore,
  });
}

class AnalysisInput {
  final String? note;
  final EmotionIcon? icon;
  final double intensity;
  final List<String> contexts;
  final UserProfile userProfile;
  AnalysisInput({
    this.note,
    this.icon,
    required this.intensity,
    required this.contexts,
    required this.userProfile,
  });
}

class LLMResponse {
  final Map<EmotionCluster, double> clusterScores;
  final List<String> evidence;
  final String intent;
  final bool isIronic;
  LLMResponse({
    required this.clusterScores,
    required this.evidence,
    required this.intent,
    required this.isIronic,
  });
}

class Solution {
  final String routineName;
  final int routineDuration;
  final String miniAction;
  const Solution({
    required this.routineName,
    required this.routineDuration,
    required this.miniAction,
  });
}

class ReasonCard {
  final String title;
  final String description;
  const ReasonCard({required this.title, required this.description});
}

class AnalysisResult {
  final Solution solution;
  final ReasonCard reasonCard;
  final double gScore;
  final EmotionCluster mainCluster;
  AnalysisResult({
    required this.solution,
    required this.reasonCard,
    required this.gScore,
    required this.mainCluster,
  });
}

class ChatMessage {
  final String text;
  final bool isUserMessage;
  ChatMessage({required this.text, required this.isUserMessage});
}

class EmotionRecord {
  final DateTime timestamp;
  final EmotionCluster emotion;
  final String? note;
  final double intensity;
  final double gScore;
  EmotionRecord({
    required this.timestamp,
    required this.emotion,
    this.note,
    required this.intensity,
    required this.gScore,
  });
}
