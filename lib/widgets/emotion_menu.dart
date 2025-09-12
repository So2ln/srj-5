import 'package:flutter/material.dart';
import 'dart:math';

// 감정 메뉴 아이템 모델
class EmotionMenuItem {
  final IconData icon;
  final String label;
  final String key;
  EmotionMenuItem(this.icon, this.label, this.key);
}

// 홈 화면에 표시될 원형 감정 메뉴 위젯
class EmotionMenu extends StatefulWidget {
  final Function(EmotionMenuItem) onEmotionSelected;

  const EmotionMenu({super.key, required this.onEmotionSelected});

  @override
  State<EmotionMenu> createState() => _EmotionMenuState();
}

class _EmotionMenuState extends State<EmotionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<EmotionMenuItem> emotions = [
    EmotionMenuItem(Icons.sentiment_very_dissatisfied, '우울', 'depression'),
    EmotionMenuItem(Icons.sentiment_neutral, '불안', 'anxiety'),
    EmotionMenuItem(Icons.whatshot, '분노', 'anger'),
    EmotionMenuItem(Icons.hourglass_empty, '공허', 'lethargy'),
    EmotionMenuItem(Icons.battery_alert, '번아웃', 'burnout'),
    EmotionMenuItem(Icons.sentiment_satisfied, '차분', 'calm'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 뒷배경 블러 처리
        FadeTransition(
          opacity: _fadeAnimation,
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),
        ..._buildEmotionItems(),
      ],
    );
  }

  // 원형으로 감정 아이템들을 배치
  List<Widget> _buildEmotionItems() {
    final List<Widget> items = [];
    const double radius = 120.0;
    final double angleStep = (2 * pi) / emotions.length;

    for (int i = 0; i < emotions.length; i++) {
      final angle = i * angleStep - (pi / 2); // 시작점을 위쪽으로 조정
      final x = cos(angle) * radius;
      final y = sin(angle) * radius;

      items.add(
        Transform.translate(
          offset: Offset(x, y),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: () => widget.onEmotionSelected(emotions[i]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      emotions[i].icon,
                      size: 30,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emotions[i].label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return items;
  }
}
