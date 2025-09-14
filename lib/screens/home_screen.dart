// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srj_5/models/app_models.dart';
import 'package:srj_5/providers/user_provider.dart';
import 'package:srj_5/screens/chat_screen.dart';
import 'package:srj_5/screens/intervention_screen.dart';
import 'package:srj_5/screens/report_screen.dart';
import 'package:srj_5/services/analysis_service.dart';
import 'package:srj_5/utils/app_styles.dart';
import 'package:srj_5/widgets/emotion_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BaseAnalysisService _analysisService = MockAnalysisService();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _chatFocusNode = FocusNode();
  bool _isLoading = false;
  bool _isMenuVisible = false;

  @override
  void initState() {
    super.initState();
    _chatFocusNode.addListener(() {
      if (_chatFocusNode.hasFocus) {
        _chatFocusNode.unfocus();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChatScreen(initialMessage: ""),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _chatFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _analyzeWithIcon(EmotionIcon icon) async {
    final userProfile = Provider.of<UserProvider>(
      context,
      listen: false,
    ).userProfile;
    if (userProfile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("사용자 정보가 로드되지 않았습니다.")));
      return;
    }
    setState(() => _isLoading = true);
    final input = AnalysisInput(
      icon: icon,
      intensity: 7.0,
      contexts: ['icon_tap'],
      userProfile: userProfile,
    );
    final result = await _analysisService.analyzeEmotion(input);
    setState(() => _isLoading = false);

    if (result != null && mounted) {
      Provider.of<UserProvider>(context, listen: false).addEmotionRecord(
        EmotionRecord(
          timestamp: DateTime.now(),
          emotion: result.mainCluster,
          intensity: input.intensity,
          gScore: result.gScore,
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
      ).showSnackBar(const SnackBar(content: Text("분석 중 오류가 발생했습니다.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final nickname =
        Provider.of<UserProvider>(context).userProfile?.nickname ?? '사용자';
    return Scaffold(
      appBar: AppBar(
        title: Text('$nickname님, 안녕하세요!', style: AppTextStyles.heading),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReportScreen()),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_isMenuVisible)
                        setState(() => _isMenuVisible = false);
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: _buildCharacterArea(),
                    ),
                  ),
                ),
                _buildChatInput(),
              ],
            ),
          ),
          if (_isMenuVisible)
            Center(
              child: EmotionMenu(
                onEmotionSelected: (e) {
                  setState(() => _isMenuVisible = false);
                  _analyzeWithIcon(e.key);
                },
              ),
            ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCharacterArea() => Column(
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
          child: Icon(Icons.psychology, size: 100, color: AppColors.primary),
        ),
      ),
      const SizedBox(height: 20),
      const Text("지금 어떤 감정을 느끼고 있나요?", style: AppTextStyles.heading),
      const SizedBox(height: 5),
      const Text(
        "캐릭터를 눌러 아이콘으로 기록하거나, 아래에 글로 적어보세요.",
        style: AppTextStyles.body,
        textAlign: TextAlign.center,
      ),
    ],
  );

  Widget _buildChatInput() => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _textController,
            focusNode: _chatFocusNode,
            decoration: InputDecoration(
              hintText: '대화하기...',
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
              if (value.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(initialMessage: value),
                  ),
                );
                _textController.clear();
              }
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ChatScreen(initialMessage: _textController.text),
                  ),
                );
                _textController.clear();
              }
            },
          ),
        ),
      ],
    ),
  );
}
