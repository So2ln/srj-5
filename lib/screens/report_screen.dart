import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:srj_5/models/app_models.dart';
import 'package:srj_5/providers/user_provider.dart';
import 'package:srj_5/utils/app_styles.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider로부터 감정 기록 데이터를 가져옴
    final records = Provider.of<UserProvider>(context).emotionRecords;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('마음 리포트'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '주간'),
              Tab(text: '월간'),
            ],
            labelStyle: AppTextStyles.bodyBold,
            indicatorColor: AppColors.primary,
          ),
        ),
        body: TabBarView(
          children: [_buildWeeklyReport(records), _buildMonthlyReport(records)],
        ),
      ),
    );
  }

  // 주간 리포트 뷰
  Widget _buildWeeklyReport(List<EmotionRecord> records) {
    // 최근 14일 데이터 필터링
    final recentRecords = records
        .where(
          (r) => r.timestamp.isAfter(
            DateTime.now().subtract(const Duration(days: 14)),
          ),
        )
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('최근 2주간 감정 강도 변화', style: AppTextStyles.heading),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: recentRecords.isNotEmpty
                ? LineChart(_buildLineChartData(recentRecords))
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

  // 월간 리포트 뷰 (감정 캘린더)
  Widget _buildMonthlyReport(List<EmotionRecord> records) {
    if (records.isEmpty) {
      return const Center(child: Text("감정 기록이 없습니다."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: Icon(
              _getEmotionIcon(record.emotion),
              color: _getEmotionColor(record.emotion),
            ),
            title: Text(DateFormat('yyyy년 MM월 dd일').format(record.timestamp)),
            subtitle: Text(record.note ?? '아이콘으로 기록됨'),
            trailing: Text(
              '강도: ${record.intensity}',
              style: AppTextStyles.body,
            ),
          ),
        );
      },
    );
  }

  // 감정 빈도 위젯
  Widget _buildEmotionFrequency(List<EmotionRecord> records) {
    if (records.isEmpty) return const Text('기록이 없습니다.');

    Map<String, int> frequency = {};
    for (var record in records) {
      frequency[record.emotion] = (frequency[record.emotion] ?? 0) + 1;
    }

    final sortedEntries = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedEntries.take(3).map((entry) {
        return ListTile(
          leading: Icon(
            _getEmotionIcon(entry.key),
            color: _getEmotionColor(entry.key),
          ),
          title: Text(entry.key, style: AppTextStyles.bodyBold),
          trailing: Text('${entry.value}회', style: AppTextStyles.body),
        );
      }).toList(),
    );
  }

  // 라인 차트 데이터 생성
  LineChartData _buildLineChartData(List<EmotionRecord> records) {
    final spots = records.map((record) {
      return FlSpot(
        record.timestamp.millisecondsSinceEpoch.toDouble(),
        record.intensity.toDouble(),
      );
    }).toList();

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 28),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              DateTime date = DateTime.fromMillisecondsSinceEpoch(
                value.toInt(),
              );
              return Text(DateFormat('d').format(date)); // 일(day)만 표시
            },
            interval: 1000 * 60 * 60 * 24 * 3, // 약 3일 간격
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
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  // 감정별 아이콘/색상 매핑
  IconData _getEmotionIcon(String emotion) {
    switch (emotion) {
      case 'anxiety':
        return Icons.sentiment_neutral;
      case 'anger':
        return Icons.whatshot;
      case 'depression':
        return Icons.sentiment_very_dissatisfied;
      case 'burnout':
        return Icons.battery_alert;
      case 'calm':
        return Icons.sentiment_satisfied;
      default:
        return Icons.sentiment_satisfied_alt;
    }
  }

  Color _getEmotionColor(String emotion) {
    switch (emotion) {
      case 'anxiety':
        return Colors.orange;
      case 'anger':
        return Colors.red;
      case 'depression':
        return Colors.blueGrey;
      case 'burnout':
        return Colors.purple;
      case 'calm':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }
}
