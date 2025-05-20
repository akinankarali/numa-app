import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';

class SundayRitualCard extends StatelessWidget {
  const SundayRitualCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final journalProvider = Provider.of<JournalProvider>(context);
    final daysUntilSunday = journalProvider.getDaysUntilSunday();
    final hasEntriesForWeek = journalProvider.hasEntriesForWeek();
    
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
                  'Sunday Ritual',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$daysUntilSunday days away',
                  style: TextStyle(
                    fontSize: 14,
                    color: daysUntilSunday <= 2
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade600,
                    fontWeight: daysUntilSunday <= 2
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Your weekly reflection and emotional insights will be ready on Sunday.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: hasEntriesForWeek
                  ? () {
                      Navigator.pushNamed(context, '/sunday-ritual');
                    }
                  : null,
              icon: const Icon(Icons.calendar_today),
              label: const Text('Preview Sunday Ritual'),
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