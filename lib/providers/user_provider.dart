// lib/providers/user_provider.dart
import 'package:flutter/foundation.dart';
import 'package:srj_5/models/app_models.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _userProfile;
  final List<EmotionRecord> _emotionRecords = [];

  UserProfile? get userProfile => _userProfile;
  List<EmotionRecord> get emotionRecords => List.unmodifiable(_emotionRecords);

  void completeOnboarding(
    String nickname,
    String characterType,
    int rsesScore,
  ) {
    _userProfile = UserProfile(
      userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
      nickname: nickname,
      characterType: characterType,
      rsesScore: rsesScore,
    );
    notifyListeners();
  }

  void addEmotionRecord(EmotionRecord record) {
    _emotionRecords.add(record);
    _emotionRecords.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }

  UserProvider() {
    _generateDummyData();
  }

  void _generateDummyData() {
    _userProfile = UserProfile(
      userId: 'user_dummy_1234',
      nickname: '마음이',
      characterType: '따뜻+분석형',
      rsesScore: 22,
    );
    final baseDate = DateTime.now();
    _emotionRecords.addAll([
      EmotionRecord(
        timestamp: baseDate.subtract(const Duration(days: 1, hours: 2)),
        emotion: EmotionCluster.anxiety,
        intensity: 7.0,
        gScore: 7.5,
        note: "내일 발표 때문에 너무 떨린다...",
      ),
      EmotionRecord(
        timestamp: baseDate.subtract(const Duration(days: 2)),
        emotion: EmotionCluster.anger,
        intensity: 8.0,
        gScore: 8.2,
      ),
      EmotionRecord(
        timestamp: baseDate.subtract(const Duration(days: 4)),
        emotion: EmotionCluster.depression,
        intensity: 6.0,
        gScore: 6.8,
      ),
      EmotionRecord(
        timestamp: baseDate.subtract(const Duration(days: 4, hours: 5)),
        emotion: EmotionCluster.calm,
        intensity: 4.0,
        gScore: 3.5,
      ),
      EmotionRecord(
        timestamp: baseDate.subtract(const Duration(days: 7)),
        emotion: EmotionCluster.calm,
        intensity: 3.0,
        gScore: 2.8,
      ),
      EmotionRecord(
        timestamp: baseDate.subtract(const Duration(days: 10)),
        emotion: EmotionCluster.burnout,
        intensity: 9.0,
        gScore: 9.1,
        note: "모든 게 다 지친다.",
      ),
    ]);
  }
}
