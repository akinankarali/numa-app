import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';
import 'progress_day_item.dart';

class WeeklyProgressWidget extends StatelessWidget {
  const WeeklyProgressWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weeklyProgress = Provider.of<JournalProvider>(context).weeklyProgress;
    
    final List<String> dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Weekly Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${weeklyProgress.daysCompleted.where((day) => day).length}/${weeklyProgress.totalDays} days',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                7,
                (index) => ProgressDayItem(
                  dayIndex: index + 1,
                  dayLetter: dayLetters[index],
                  isCompleted: weeklyProgress.daysCompleted.length > index 
                      ? weeklyProgress.daysCompleted[index]
                      : false,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/emotional-map');
              },
              icon: const Icon(Icons.bar_chart),
              label: const Text('View Emotional Map'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 