// 분석 플로우에 사용되는 모든 데이터의 형태를 정의합니다.

// 감정 클러스터 Enum
enum EmotionCluster {
  depression, // 우울
  anxiety, // 불안
  panic, // 공포/패닉
  anger, // 분노/과민
  numbness, // 무감각/공허
  burnout, // 피로/번아웃
  calm, // 차분/안정
}

// 감정 아이콘 Enum
enum EmotionIcon { sad, anxious, fearful, angry, empty, tired, calm }

// 사용자 프로필
class UserProfile {
  final String userId;
  final int rsesScore; // 자존감 척도 점수

  UserProfile({required this.userId, required this.rsesScore});
}

// 분석 서비스의 입력값
class AnalysisInput {
  final String? note;
  final EmotionIcon icon;
  final double intensity;
  final List<String> contexts;
  final UserProfile userProfile;

  AnalysisInput({
    this.note,
    required this.icon,
    required this.intensity,
    required this.contexts,
    required this.userProfile,
  });
}

// LLM API의 응답 스키마
class LLMResponse {
  final Map<EmotionCluster, double> clusterScores;
  final List<String> evidence; // 근거 키워드
  final String intent; // 자해/타해 의도
  final bool isIronic; // 반어법 여부

  LLMResponse({
    required this.clusterScores,
    required this.evidence,
    required this.intent,
    required this.isIronic,
  });
}

// 제안할 솔루션
class Solution {
  final String routineName;
  final int routineDuration; // 초 단위
  final String miniAction;

  const Solution({
    required this.routineName,
    required this.routineDuration,
    required this.miniAction,
  });
}

// 사용자에게 보여줄 이유 카드
class ReasonCard {
  final String title;
  final String description;

  const ReasonCard({required this.title, required this.description});
}

// 분석 서비스의 최종 결과
class AnalysisResult {
  final Solution solution;
  final ReasonCard reasonCard;

  AnalysisResult({required this.solution, required this.reasonCard});
}
