import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srj_5/models/app_models.dart';
import 'package:srj_5/providers/user_provider.dart';
import 'package:srj_5/screens/intervention_screen.dart';
import 'package:srj_5/screens/report_screen.dart';
import 'package:srj_5/services/api_service.dart';
import 'package:srj_5/utils/app_styles.dart';
import 'package:srj_5/widgets/emotion_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 실제 서비스에서는 DI(Dependency Injection)를 사용하는 것이 좋습니다.
  final BaseApiService _apiService = MockApiService();
  final TextEditingController _textController = TextEditingController();

  bool _isLoading = false;
  bool _isMenuVisible = false;

  // 분석 API 호출 및 결과 처리 로직
  void _analyzeAndNavigate({String? note, String? icon}) async {
    setState(() => _isLoading = true);
    final userProfile = Provider.of<UserProvider>(
      context,
      listen: false,
    ).userProfile;

    final result = await _apiService.analyzeEmotion(
      note: note,
      icon: icon,
      intensity: 7, // 예시 강도, 슬라이더 등으로 입력받을 수 있음
      contexts: ['work'], // 예시 맥락, 칩 등으로 선택하게 할 수 있음
      userProfile: userProfile,
    );

    setState(() => _isLoading = false);

    if (result != null && mounted) {
      // 분석이 끝나면 결과와 함께 Provider에 감정 기록 저장
      Provider.of<UserProvider>(context, listen: false).addEmotionRecord(
        EmotionRecord(
          timestamp: DateTime.now(),
          emotion: icon ?? result.mainCluster,
          note: note,
          intensity: 7,
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InterventionScreen(analysisResult: result),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('분석 중 오류가 발생했습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provider로부터 사용자 닉네임을 가져옴
    final nickname =
        Provider.of<UserProvider>(context).userProfile?.nickname ?? '사용자';

    return Scaffold(
      appBar: AppBar(
        title: Text('$nickname님, 안녕하세요!', style: AppTextStyles.heading),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isMenuVisible = false),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(child: _buildCharacterArea()),
                  _buildChatInput(),
                ],
              ),
            ),
          ),
          // 감정 선택 메뉴
          if (_isMenuVisible)
            EmotionMenu(
              onEmotionSelected: (emotion) {
                setState(() => _isMenuVisible = false);
                _analyzeAndNavigate(icon: emotion.key);
              },
            ),
          // 로딩 인디케이터
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      "마음을 분석하고 있어요...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 중앙 캐릭터 영역
  Widget _buildCharacterArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("오늘의 추천 루틴: '편안한 호흡하기'", style: AppTextStyles.body),
        const SizedBox(height: 30),
        InkWell(
          onTap: () => setState(() => _isMenuVisible = !_isMenuVisible),
          borderRadius: BorderRadius.circular(100),
          child: const CircleAvatar(
            radius: 80,
            backgroundColor: AppColors.primaryLight,
            child: Icon(
              Icons.person_pin_circle,
              size: 100,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text("지금 어떤 감정을 느끼고 있나요?", style: AppTextStyles.heading),
        const SizedBox(height: 5),
        const Text(
          "캐릭터를 눌러 아이콘으로 기록하거나, 아래에 글로 적어보세요.",
          style: AppTextStyles.body,
        ),
      ],
    );
  }

  // 하단 채팅 입력 영역
  Widget _buildChatInput() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: '오늘의 감정을 이야기해주세요...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(color: AppColors.textColorLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) _analyzeAndNavigate(note: value);
              },
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  _analyzeAndNavigate(note: _textController.text);
                  _textController.clear();
                  FocusScope.of(context).unfocus();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
