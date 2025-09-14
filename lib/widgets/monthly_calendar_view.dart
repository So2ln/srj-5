// lib/widgets/monthly_calendar_view.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:srj_5/models/app_models.dart';
import 'package:srj_5/utils/app_styles.dart';

class MonthlyCalendarView extends StatefulWidget {
  final List<EmotionRecord> records;
  const MonthlyCalendarView({super.key, required this.records});

  @override
  State<MonthlyCalendarView> createState() => _MonthlyCalendarViewState();
}

class _MonthlyCalendarViewState extends State<MonthlyCalendarView> {
  late final Map<DateTime, List<EmotionRecord>> _recordsByDate;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _recordsByDate = {};
    for (var record in widget.records) {
      final date = DateTime.utc(
        record.timestamp.year,
        record.timestamp.month,
        record.timestamp.day,
      );
      if (_recordsByDate[date] == null) _recordsByDate[date] = [];
      _recordsByDate[date]!.add(record);
    }
  }

  List<EmotionRecord> _getRecordsForDay(DateTime day) =>
      _recordsByDate[DateTime.utc(day.year, day.month, day.day)] ?? [];

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _showDaySummary(context, selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar<EmotionRecord>(
      locale: 'ko_KR',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: _onDaySelected,
      eventLoader: _getRecordsForDay,
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isNotEmpty)
            return Positioned(
              bottom: 1,
              child: _buildEventsMarker(date, events),
            );
          return null;
        },
      ),
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(
          color: AppColors.primaryLight,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }

  // --- 여러 감정 기록 표시를 위한 수정 ---
  Widget _buildEventsMarker(DateTime date, List<EmotionRecord> records) {
    // 기록이 여러 개일 경우
    if (records.length > 1) {
      // 가장 최근 기록을 찾기 위해 정렬
      records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final latestRecord = records.first;

      return Stack(
        alignment: Alignment.center,
        children: [
          // 가장 최근 이모티콘을 크게 표시
          Icon(
            _getEmotionIcon(latestRecord.emotion),
            size: 20, // 기본 아이콘보다 크게
            color: _getEmotionColor(latestRecord.emotion),
          ),
          // 우측 상단에 작은 + 아이콘 표시
          const Positioned(
            top: 0,
            right: 0,
            child: Icon(Icons.add_circle, size: 10, color: Colors.black54),
          ),
        ],
      );
    }
    // 기록이 하나일 경우
    return Icon(
      _getEmotionIcon(records[0].emotion),
      size: 16,
      color: _getEmotionColor(records[0].emotion),
    );
  }

  void _showDaySummary(BuildContext context, DateTime day) {
    final records = _getRecordsForDay(day);
    if (records.isEmpty) return;
    final avgGScore =
        records.map((r) => r.gScore).reduce((a, b) => a + b) / records.length;
    final mainEmotion = records.reduce((a, b) => a.gScore > b.gScore ? a : b);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              DateFormat('M월 d일 EEEE', 'ko_KR').format(day),
              style: AppTextStyles.heading,
            ),
            const SizedBox(height: 16),
            Text(
              "종합 정서 점수 (G-Score): ${avgGScore.toStringAsFixed(1)} / 10",
              style: AppTextStyles.bodyBold,
            ),
            Text(
              "주요 정서: ${mainEmotion.emotion.name}",
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('이날의 채팅내역 보기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getEmotionIcon(EmotionCluster e) {
    const map = {
      EmotionCluster.anxiety: Icons.sentiment_neutral,
      EmotionCluster.anger: Icons.whatshot,
      EmotionCluster.depression: Icons.sentiment_very_dissatisfied,
      EmotionCluster.burnout: Icons.battery_alert,
      EmotionCluster.calm: Icons.sentiment_satisfied,
      EmotionCluster.panic: Icons.warning_amber_rounded,
      EmotionCluster.numbness: Icons.hourglass_empty,
    };
    return map[e] ?? Icons.question_mark;
  }

  Color _getEmotionColor(EmotionCluster e) {
    const map = {
      EmotionCluster.anxiety: Colors.orange,
      EmotionCluster.anger: Colors.red,
      EmotionCluster.depression: Colors.blueGrey,
      EmotionCluster.burnout: Colors.purple,
      EmotionCluster.calm: Colors.green,
    };
    return map[e] ?? AppColors.primary;
  }
}
