// lib/screens/report_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:srj_5/models/app_models.dart';
import 'package:srj_5/providers/user_provider.dart';
import 'package:srj_5/utils/app_styles.dart';
import 'package:srj_5/widgets/monthly_calendar_view.dart';
import 'package:intl/intl.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

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
    // 차트에 시간 순서대로(왼쪽이 과거) 표시되도록 정렬
    recentRecords.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('최근 2주간 G-Score 변화', style: AppTextStyles.heading),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: recentRecords.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(right: 16.0), // 오른쪽 여백 추가
                    child: LineChart(_buildLineChartData(recentRecords)),
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

  LineChartData _buildLineChartData(List<EmotionRecord> records) {
    // --- X축 좌우 여백 추가를 위한 로직 ---
    // 데이터의 시작 날짜와 마지막 날짜를 찾습니다.
    final minDate = records.first.timestamp;
    final maxDate = records.last.timestamp;
    // 하루만큼의 여백을 설정합니다.
    const buffer = Duration(hours: 1);

    // X축의 최소값과 최대값을 여백을 포함하여 설정합니다.
    final minX = minDate.subtract(buffer).millisecondsSinceEpoch.toDouble();
    final maxX = maxDate.add(buffer).millisecondsSinceEpoch.toDouble();
    // ------------------------------------

    final spots = records
        .map(
          (r) =>
              FlSpot(r.timestamp.millisecondsSinceEpoch.toDouble(), r.gScore),
        )
        .toList();

    return LineChartData(
      // --- X축 범위 설정 ---
      minX: minX,
      maxX: maxX,
      // ---------------------
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 28),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            // 데이터가 너무 촘촘하지 않도록 적절한 간격으로 표시
            interval: 1000 * 60 * 60 * 24 * 1, // 1일 간격
            getTitlesWidget: (value, meta) {
              // X축 범위 밖의 레이블은 그리지 않음
              if (value < minDate.millisecondsSinceEpoch ||
                  value > maxDate.millisecondsSinceEpoch) {
                return const Text('');
              }
              final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              // --- 날짜 형식 변경: "9/15" 와 같은 형식으로 표시 ---
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 4,
                child: Text(
                  DateFormat('M/d').format(date),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textColorLight,
                  ),
                ),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: AppColors.textColorLight),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primary,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true), // 데이터 포인트에 점 표시
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withOpacity(0.3),
          ),
        ),
      ],
      minY: 0,
      maxY: 15,
    );
  }
}
