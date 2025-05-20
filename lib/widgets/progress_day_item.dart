import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProgressDayItem extends StatelessWidget {
  final int dayIndex;
  final String dayLetter;
  final bool isCompleted;
  
  const ProgressDayItem({
    Key? key,
    required this.dayIndex,
    required this.dayLetter,
    required this.isCompleted,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isToday = DateTime.now().weekday == dayIndex;
    
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : isToday
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
            border: isToday
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1,
                  )
                : null,
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  )
                : Text(
                    (dayIndex).toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          dayLetter,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isToday
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
} 