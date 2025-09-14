// lib/widgets/emotion_menu.dart
import 'package:flutter/material.dart';
import 'package:srj_5/models/app_models.dart';
import 'dart:math';

class EmotionMenuItem {
  final IconData iconData;
  final String label;
  final EmotionIcon key;
  EmotionMenuItem(this.iconData, this.label, this.key);
}

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
    EmotionMenuItem(Icons.sentiment_very_dissatisfied, '우울', EmotionIcon.sad),
    EmotionMenuItem(Icons.sentiment_neutral, '불안', EmotionIcon.anxious),
    EmotionMenuItem(Icons.whatshot, '분노', EmotionIcon.angry),
    EmotionMenuItem(Icons.hourglass_empty, '공허', EmotionIcon.empty),
    EmotionMenuItem(Icons.battery_alert, '번아웃', EmotionIcon.tired),
    EmotionMenuItem(Icons.sentiment_satisfied, '차분', EmotionIcon.calm),
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
        FadeTransition(
          opacity: _fadeAnimation,
          child: Container(color: Colors.black.withOpacity(0.4)),
        ),
        ..._buildEmotionItems(),
      ],
    );
  }

  List<Widget> _buildEmotionItems() {
    final List<Widget> items = [];
    const double radius = 120.0;
    final double angleStep = (2 * pi) / emotions.length;
    for (int i = 0; i < emotions.length; i++) {
      final angle = i * angleStep - (pi / 2);
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
                      emotions[i].iconData,
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
