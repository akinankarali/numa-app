import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/journal_provider.dart';
import '../providers/breathing_provider.dart';
import '../widgets/emotion_percentage_item.dart';
import '../widgets/breathing_exercise_card.dart';
import '../theme/app_theme.dart';

class JournalSuccessScreen extends StatefulWidget {
  final String entryId;
  
  const JournalSuccessScreen({
    Key? key,
    required this.entryId,
  }) : super(key: key);

  @override
  State<JournalSuccessScreen> createState() => _JournalSuccessScreenState();
}

class _JournalSuccessScreenState extends State<JournalSuccessScreen> {
  bool _isAnalyzing = true;
  bool _showBreathingExercise = false;
  
  @override
  void initState() {
    super.initState();
    _analyzeAudio();
  }
  
  Future<void> _analyzeAudio() async {
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);
    
    await journalProvider.analyzeAudio(widget.entryId);
    
    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        
        // Show breathing exercise if dominant mood is anxious or stressed
        final analysis = journalProvider.lastAnalysis;
        if (analysis != null) {
          final mood = analysis.dominantMood.toLowerCase();
          _showBreathingExercise = mood == 'anxious' || mood == 'stressed';
        }
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isAnalyzing) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Analyzing'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text('Analyzing your voice journal...'),
            ],
          ),
        ),
      );
    }
    
    final journalProvider = Provider.of<JournalProvider>(context);
    final analysis = journalProvider.lastAnalysis;
    
    if (analysis == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Journal Complete'),
        ),
        body: const Center(
          child: Text('Something went wrong with the analysis.'),
        ),
      );
    }
    
    // Get appropriate breathing exercise if needed
    final breathingProvider = Provider.of<BreathingProvider>(context);
    final exercise = breathingProvider.getExerciseForMood(analysis.dominantMood);
    
    // Apply theme based on dominant mood
    final theme = AppTheme.themeForMood(analysis.dominantMood);
    
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Journal Complete'),
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: theme.colorScheme.primary,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Journal Complete',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    'Your voice journal has been analyzed and saved',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  "Today's Emotional Landscape",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                ...analysis.emotions.map((emotion) => 
                  EmotionPercentageItem(emotion: emotion)
                ).toList(),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'AI Insight',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        analysis.insight,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_showBreathingExercise && exercise != null)
                  BreathingExerciseCard(
                    exercise: exercise,
                    onStart: () {
                      breathingProvider.startExercise(exercise);
                      Navigator.pushNamed(
                        context,
                        '/breathing-exercise',
                      );
                    },
                  ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reflection Question',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'What specific situations triggered your ${analysis.dominantMood.toLowerCase()} feelings today, and how might you address them?',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text('Return to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 