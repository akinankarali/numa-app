import 'package:flutter/material.dart';
import '../models/emotion.dart';

class EmotionPercentageItem extends StatelessWidget {
  final Emotion emotion;
  
  const EmotionPercentageItem({
    Key? key,
    required this.emotion,
  }) : super(key: key);
  
  Color _getEmotionColor(String emotionName) {
    switch (emotionName.toLowerCase()) {
      case 'calm':
        return const Color(0xFF14B8A6); // Teal
      case 'hopeful':
        return const Color(0xFF9333EA); // Purple
      case 'anxious':
        return const Color(0xFFF97316); // Orange
      case 'stressed':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF64748B); // Blue Gray
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                emotion.name,
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                '${emotion.percentage.toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: emotion.percentage / 100,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getEmotionColor(emotion.name),
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
} 