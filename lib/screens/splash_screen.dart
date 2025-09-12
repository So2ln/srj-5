import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:srj_5/screens/home_screen.dart';
import 'package:srj_5/screens/onboarding_screen.dart';
import 'package:srj_5/utils/app_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    // 2초간 스플래시 화면을 보여줌
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 로컬 저장소에서 온보딩 완료 여부 확인
    final prefs = await SharedPreferences.getInstance();
    final bool onboardingCompleted =
        prefs.getBool('onboardingCompleted') ?? false;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            onboardingCompleted ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              color: AppColors.primary,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              '마음 케어',
              style: AppTextStyles.title.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
