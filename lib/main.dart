import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srj_5/providers/user_provider.dart';
import 'package:srj_5/screens/splash_screen.dart';
import 'package:srj_5/utils/app_styles.dart';

// 다른 파일들을 import 하기 전에, 해당 파일들이 프로젝트 내에 생성되었는지 확인하세요.
// 예시: import 'package:care_app/providers/user_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider를 사용하여 앱 전역에서 UserProvider 상태를 공유
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        title: '마음 케어',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Pretendard', // 앱 기본 폰트
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.background,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: AppTextStyles.heading,
            iconTheme: IconThemeData(color: AppColors.textColor),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
