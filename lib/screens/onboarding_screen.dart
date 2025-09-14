// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srj_5/providers/user_provider.dart';
import 'package:srj_5/screens/home_screen.dart';
import 'package:srj_5/utils/app_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nicknameController = TextEditingController();
  String _selectedCharacter = '';
  double _rsesScore = 25;
  final List<String> _characterTypes = [
    '공손+분석형',
    '귀욤 감성+공감형',
    '10찐따+공감형',
    '따뜻+분석형',
  ];

  void _nextPage() => _pageController.nextPage(
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeIn,
  );

  Future<void> _completeOnboarding() async {
    if (_nicknameController.text.isEmpty || _selectedCharacter.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('닉네임과 캐릭터를 선택해주세요!')));
      return;
    }
    Provider.of<UserProvider>(context, listen: false).completeOnboarding(
      _nicknameController.text,
      _selectedCharacter,
      _rsesScore.toInt(),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildNicknamePage(),
            _buildCharacterPage(),
            _buildRsesPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildNicknamePage() => Padding(
    padding: const EdgeInsets.all(24.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('반가워요!\n어떻게 불러드릴까요?', style: AppTextStyles.title),
        const SizedBox(height: 30),
        TextField(
          controller: _nicknameController,
          decoration: InputDecoration(
            labelText: '닉네임',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(onPressed: _nextPage, child: const Text('다음')),
      ],
    ),
  );

  Widget _buildCharacterPage() => Padding(
    padding: const EdgeInsets.all(24.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('당신을 도와줄\n케어 캐릭터를 선택해주세요.', style: AppTextStyles.title),
        const SizedBox(height: 30),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: _characterTypes.map((type) {
            final isSelected = _selectedCharacter == type;
            return ChoiceChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) => setState(() {
                if (selected) _selectedCharacter = type;
              }),
              selectedColor: AppColors.primary.withOpacity(0.8),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textColor,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 30),
        ElevatedButton(onPressed: _nextPage, child: const Text('다음')),
      ],
    ),
  );

  Widget _buildRsesPage() => Padding(
    padding: const EdgeInsets.all(24.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('마지막이에요.\n스스로를 얼마나 가치있게 생각하나요?', style: AppTextStyles.title),
        const SizedBox(height: 10),
        const Text('(이 점수는 추천 정확도를 높이는 데 사용돼요)', style: AppTextStyles.body),
        const SizedBox(height: 50),
        Text(
          '자존감 점수: ${_rsesScore.toInt()}',
          style: AppTextStyles.heading,
          textAlign: TextAlign.center,
        ),
        Slider(
          value: _rsesScore,
          min: 10,
          max: 40,
          divisions: 30,
          label: _rsesScore.toInt().toString(),
          onChanged: (v) => setState(() => _rsesScore = v),
          activeColor: AppColors.primary,
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('낮음', style: AppTextStyles.body),
            Text('높음', style: AppTextStyles.body),
          ],
        ),
        const SizedBox(height: 50),
        ElevatedButton(
          onPressed: _completeOnboarding,
          child: const Text('시작하기'),
        ),
      ],
    ),
  );
}
