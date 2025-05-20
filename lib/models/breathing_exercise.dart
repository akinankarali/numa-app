class BreathingExercise {
  final String id;
  final String name;
  final String description;
  final List<String> steps;
  final List<int> timings; // [inhale, hold, exhale, hold]
  final int repetitions;
  final List<String> benefits;
  final String targetMood;
  
  BreathingExercise({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    required this.timings,
    required this.repetitions,
    required this.benefits,
    required this.targetMood,
  });
  
  factory BreathingExercise.fromJson(Map<String, dynamic> json) {
    return BreathingExercise(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      steps: (json['steps'] as List).map((e) => e as String).toList(),
      timings: (json['timings'] as List).map((e) => e as int).toList(),
      repetitions: json['repetitions'],
      benefits: (json['benefits'] as List).map((e) => e as String).toList(),
      targetMood: json['targetMood'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'steps': steps,
      'timings': timings,
      'repetitions': repetitions,
      'benefits': benefits,
      'targetMood': targetMood,
    };
  }
  
  // Önceden tanımlanmış nefes egzersizleri
  static List<BreathingExercise> getPredefinedExercises() {
    return [
      BreathingExercise(
        id: '1',
        name: '4-7-8 Breathing Technique',
        description: 'A relaxing breath technique to help reduce anxiety and promote sleep',
        steps: [
          'Breathe in quietly through your nose for 4 seconds',
          'Hold your breath for 7 seconds',
          'Exhale completely through your mouth for 8 seconds',
          'Repeat this cycle 4 times'
        ],
        timings: [4, 7, 8, 0],
        repetitions: 4,
        benefits: [
          'Reduces anxiety and stress',
          'Helps with falling asleep',
          'Improves focus',
          'Manages cravings'
        ],
        targetMood: 'anxious',
      ),
      BreathingExercise(
        id: '2',
        name: 'Box Breathing',
        description: 'A simple technique to help calm your nervous system',
        steps: [
          'Breathe in through your nose for 4 seconds',
          'Hold your breath for 4 seconds',
          'Exhale slowly through your mouth for 4 seconds',
          'Hold your breath for 4 seconds',
          'Repeat this cycle 4 times'
        ],
        timings: [4, 4, 4, 4],
        repetitions: 4,
        benefits: [
          'Reduces stress',
          'Improves concentration',
          'Regulates autonomic nervous system',
          'Helps with emotional regulation'
        ],
        targetMood: 'anxious',
      ),
      BreathingExercise(
        id: '3',
        name: 'Diaphragmatic Breathing',
        description: 'Deep abdominal breathing to engage your diaphragm',
        steps: [
          'Place one hand on your chest and the other on your abdomen',
          'Breathe in deeply through your nose for 5 seconds, feeling your abdomen expand',
          'Hold briefly for a second',
          'Exhale slowly through pursed lips for 5 seconds',
          'Repeat this cycle 5 times'
        ],
        timings: [5, 1, 5, 0],
        repetitions: 5,
        benefits: [
          'Reduces blood pressure',
          'Slows heart rate',
          'Relaxes muscles',
          'Improves core muscle stability'
        ],
        targetMood: 'stressed',
      ),
    ];
  }
} 