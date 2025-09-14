// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:srj_5/providers/user_provider.dart';
import 'package:srj_5/screens/splash_screen.dart';
import 'package:srj_5/utils/app_styles.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MaterialApp(
        title: '마음 케어',
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'Pretendard',
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
