// lib/screens/intervention_screen.dart
import 'package:flutter/material.dart';
import 'package:srj_5/models/app_models.dart';
import 'package:srj_5/utils/app_styles.dart';

class InterventionScreen extends StatelessWidget {
  final AnalysisResult analysisResult;
  const InterventionScreen({super.key, required this.analysisResult});

  @override
  Widget build(BuildContext context) {
    final solution = analysisResult.solution;
    final reasonCard = analysisResult.reasonCard;

    return Scaffold(
      appBar: AppBar(title: const Text('추천 솔루션')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '지금 당신을 위한 ${solution.routineDuration}초 루틴',
                style: AppTextStyles.title,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.self_improvement,
                        size: 60,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        solution.routineName,
                        style: AppTextStyles.heading,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                reasonCard.title,
                style: AppTextStyles.heading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                reasonCard.description,
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(onPressed: () {}, child: const Text('루틴 시작하기')),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('괜찮아요'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
