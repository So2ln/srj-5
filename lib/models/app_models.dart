// 앱에서 사용하는 모든 데이터 클래스를 정의합니다.

// 감정 분석 API의 응답을 파싱하기 위한 모델
class AnalysisResult {
  final String mainCluster;
  final Map<String, double> clusterProbabilities;
  final Intervention intervention;
  final String reasonCard;

  AnalysisResult({
    required this.mainCluster,
    required this.clusterProbabilities,
    required this.intervention,
    required this.reasonCard,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    var probabilitiesJson =
        json['cluster_probabilities'] as Map<String, dynamic>;
    Map<String, double> probabilities = probabilitiesJson.map((key, value) {
      return MapEntry(key, value.toDouble());
    });

    return AnalysisResult(
      mainCluster: json['main_cluster'],
      clusterProbabilities: probabilities,
      intervention: Intervention.fromJson(json['intervention']),
      reasonCard: json['reason_card'],
    );
  }
}

// 개입(솔루션) 정보를 담는 모델
class Intervention {
  final String routineName;
  final String type;

  Intervention({required this.routineName, required this.type});

  factory Intervention.fromJson(Map<String, dynamic> json) {
    return Intervention(routineName: json['routine_name'], type: json['type']);
  }
}

// 사용자 프로필 정보를 담는 모델
class UserProfile {
  final String nickname;
  final String characterType;
  final int rsesScore; // 자존감 척도 점수

  UserProfile({
    required this.nickname,
    required this.characterType,
    required this.rsesScore,
  });
}

// 사용자의 감정 기록 하나를 나타내는 모델
class EmotionRecord {
  final DateTime timestamp;
  final String emotion; // 예: 'anxiety', 'anger'
  final String? note; // 텍스트로 기록한 경우
  final int intensity;

  EmotionRecord({
    required this.timestamp,
    required this.emotion,
    this.note,
    required this.intensity,
  });
}
