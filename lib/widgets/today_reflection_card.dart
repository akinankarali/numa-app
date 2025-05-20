import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';

class TodayReflectionCard extends StatelessWidget {
  const TodayReflectionCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasTodayEntry = Provider.of<JournalProvider>(context).hasTodayEntry();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Reflection",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Take a moment to breathe and share your thoughts. How are you feeling today?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: hasTodayEntry
                  ? null // Disable if already recorded today
                  : () {
                      Navigator.pushNamed(context, '/record');
                    },
              icon: const Icon(Icons.mic),
              label: Text(hasTodayEntry ? "Today's Journal Complete" : "Start Today's Journal"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 