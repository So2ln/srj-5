import 'package:flutter/material.dart';
import 'package:srj_5/models/app_models.dart';
import 'package:srj_5/utils/app_styles.dart';

class InterventionScreen extends StatelessWidget {
  final AnalysisResult analysisResult;

  const InterventionScreen({super.key, required this.analysisResult});

  @override
  Widget build(BuildContext context) {
    final intervention = analysisResult.intervention;
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
              const Text(
                '지금 당신을 위한 120초 루틴',
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
                        intervention.routineName,
                        style: AppTextStyles.heading,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                '추천 이유',
                style: AppTextStyles.heading,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                reasonCard,
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  // TODO: 루틴 실행 로직 (예: 타이머 시작, 영상 재생 화면으로 이동)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('루틴을 시작합니다! (구현 필요)')),
                  );
                },
                child: const Text('루틴 시작하기'),
              ),
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
