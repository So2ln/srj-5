import 'package:flutter/foundation.dart';
import 'package:srj_5/models/app_models.dart';

// 사용자의 프로필 정보와 감정 기록 데이터를 관리하는 클래스
class UserProvider with ChangeNotifier {
  UserProfile? _userProfile;
  final List<EmotionRecord> _emotionRecords = [];

  UserProfile? get userProfile => _userProfile;
  List<EmotionRecord> get emotionRecords => _emotionRecords;

  // 온보딩 완료 시 사용자 프로필 설정
  void completeOnboarding(
    String nickname,
    String characterType,
    int rsesScore,
  ) {
    _userProfile = UserProfile(
      nickname: nickname,
      characterType: characterType,
      rsesScore: rsesScore,
    );
    // 상태 변경을 리스너들에게 알림
    notifyListeners();
  }

  // 새로운 감정 기록 추가
  void addEmotionRecord(EmotionRecord record) {
    _emotionRecords.add(record);
    // 최신순으로 정렬
    _emotionRecords.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }

  // UI 개발을 위한 더미 데이터 생성
  UserProvider() {
    _generateDummyData();
  }

  void _generateDummyData() {
    _userProfile = UserProfile(
      nickname: '마음이',
      characterType: '따뜻+분석형',
      rsesScore: 22,
    );
    _emotionRecords.addAll([
      EmotionRecord(
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        emotion: 'anxiety',
        intensity: 7,
        note: "내일 발표 때문에 너무 떨린다...",
      ),
      EmotionRecord(
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        emotion: 'anger',
        intensity: 8,
      ),
      EmotionRecord(
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
        emotion: 'depression',
        intensity: 6,
      ),
      EmotionRecord(
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        emotion: 'anxiety',
        intensity: 5,
      ),
      EmotionRecord(
        timestamp: DateTime.now().subtract(const Duration(days: 7)),
        emotion: 'calm',
        intensity: 3,
      ),
      EmotionRecord(
        timestamp: DateTime.now().subtract(const Duration(days: 8)),
        emotion: 'anxiety',
        intensity: 8,
      ),
      EmotionRecord(
        timestamp: DateTime.now().subtract(const Duration(days: 10)),
        emotion: 'burnout',
        intensity: 9,
        note: "모든 게 다 지친다.",
      ),
      EmotionRecord(
        timestamp: DateTime.now().subtract(const Duration(days: 12)),
        emotion: 'anger',
        intensity: 7,
      ),
    ]);
  }
}
