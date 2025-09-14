// lib/utils/app_styles.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6A1B9A);
  static const Color primaryLight = Color(0xFFE1BEE7);
  static const Color background = Color(0xFFF3E5F5);
  static const Color textColor = Color(0xFF333333);
  static const Color textColorLight = Color(0xFF888888);
}

class AppTextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );
  static const TextStyle heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textColorLight,
    height: 1.5,
  );
  static const TextStyle bodyBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );
}
