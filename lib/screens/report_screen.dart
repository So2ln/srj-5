// lib/screens/report_screen.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:srj_5/models/app_models.dart';
import 'package:srj_5/providers/user_provider.dart';
import 'package:srj_5/utils/app_styles.dart';
import 'package:srj_5/widgets/monthly_calendar_view.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool _isCurved = false; // 기본값을 직선으로 설정

  @override
  Widget build(BuildContext context) {
    final List<EmotionRecord> records = Provider.of<UserProvider>(
      context,
    ).emotionRecords;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('마음 리포트'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '월간'),
              Tab(text: '주간'),
            ],
            labelStyle: AppTextStyles.bodyBold,
            indicatorColor: AppColors.primary,
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: MonthlyCalendarView(records: records),
              ),
            ),
            _buildWeeklyReport(records),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyReport(List<EmotionRecord> records) {
    final recentRecords = records
        .where(
          (r) => r.timestamp.isAfter(
            DateTime.now().subtract(const Duration(days: 14)),
          ),
        )
        .toList();

    // --- 1. 데이터 사전 처리: 날짜별로 G-Score 평균 계산 ---
    final Map<DateTime, double> dailyAverageScores = {};
    final Map<DateTime, int> dailyRecordCounts = {};
    for (var record in recentRecords) {
      final dateKey = DateTime(
        record.timestamp.year,
        record.timestamp.month,
        record.timestamp.day,
      );
      dailyAverageScores[dateKey] =
          (dailyAverageScores[dateKey] ?? 0) + record.gScore;
      dailyRecordCounts[dateKey] = (dailyRecordCounts[dateKey] ?? 0) + 1;
    }
    dailyAverageScores.forEach((key, value) {
      dailyAverageScores[key] = value / dailyRecordCounts[key]!;
    });

    final sortedDailyData = dailyAverageScores.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('최근 2주간 G-Score 변화', style: AppTextStyles.heading),
              // 스위치로 smoothing ON/OFF
              // Row(
              //   children: [
              //     const Text('부드러운 곡선', style: TextStyle(fontSize: 12)),
              // Switch(
              //   value: _isCurved,
              //   onChanged: (value) => setState(() => _isCurved = value),
              //   activeColor: AppColors.primary,
              // ),
              //   ],
              // ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: sortedDailyData.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(right: 16.0, top: 16.0),
                    child: LineChart(_buildLineChartData(sortedDailyData)),
                  )
                : const Center(child: Text("표시할 데이터가 없습니다.")),
          ),
          const SizedBox(height: 40),
          const Text('가장 자주 기록된 감정', style: AppTextStyles.heading),
          const SizedBox(height: 10),
          _buildEmotionFrequency(records),
        ],
      ),
    );
  }

  Widget _buildEmotionFrequency(List<EmotionRecord> records) {
    if (records.isEmpty) return const Text('기록이 없습니다.');
    Map<EmotionCluster, int> frequency = {};
    for (var record in records) {
      frequency[record.emotion] = (frequency[record.emotion] ?? 0) + 1;
    }
    final sortedEntries = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Column(
      children: sortedEntries
          .take(3)
          .map(
            (entry) => ListTile(
              leading: const Icon(Icons.favorite, color: AppColors.primary),
              title: Text(entry.key.name, style: AppTextStyles.bodyBold),
              trailing: Text('${entry.value}회', style: AppTextStyles.body),
            ),
          )
          .toList(),
    );
  }

  // --- 차트 데이터 생성 함수 (완벽 수정 버전) ---
  LineChartData _buildLineChartData(
    List<MapEntry<DateTime, double>> dailyData,
  ) {
    // --- 1. X축을 위한 정수 인덱스 생성 ---
    // spots: X축 값으로 0, 1, 2... 순서의 정수를 사용
    final spots = dailyData.asMap().entries.map((entry) {
      // entry.key 는 인덱스 (0, 1, 2, ...), entry.value 는 MapEntry<DateTime, double>
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    // bottomTitles: 정수 인덱스를 실제 날짜 텍스트로 변환하기 위한 '번역기' 맵
    final Map<int, String> bottomTitlesMap = {
      for (var entry in dailyData.asMap().entries)
        entry.key: DateFormat('M/d').format(entry.value.key),
    };

    return LineChartData(
      // --- 툴팁 추가: 점을 터치하면 날짜와 G-Score 표시 ---
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              // spot.spotIndex는 점의 인덱스(0, 1, 2...)와 같습니다.
              final dateText = bottomTitlesMap[spot.spotIndex] ?? '';
              return LineTooltipItem(
                '$dateText\nG-Score: ${spot.y.toStringAsFixed(1)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 32),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        // --- 2. X축 라벨(날짜) 설정 ---
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1, // 모든 정수 인덱스마다 라벨을 그리려고 시도
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              // 데이터가 너무 촘촘할 경우, 2일에 한 번씩만 라벨 표시 (조절 가능)
              if (dailyData.length > 10 && index % 2 != 0) {
                return const SizedBox.shrink();
              }
              final title = bottomTitlesMap[index] ?? '';
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 4,
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textColorLight,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: AppColors.textColorLight),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: _isCurved,
          color: AppColors.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withOpacity(0.2),
          ),
        ),
      ],
      minY: 0,
      maxY: 10,
    );
  }
}
