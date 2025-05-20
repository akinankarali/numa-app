class Emotion {
  final String name;
  final double percentage;
  
  Emotion({
    required this.name,
    required this.percentage,
  });
  
  factory Emotion.fromJson(Map<String, dynamic> json) {
    return Emotion(
      name: json['name'],
      percentage: json['percentage'].toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'percentage': percentage,
    };
  }
}

class EmotionalAnalysis {
  final List<Emotion> emotions;
  final String insight;
  final String dominantMood;
  
  EmotionalAnalysis({
    required this.emotions,
    required this.insight,
    required this.dominantMood,
  });
  
  factory EmotionalAnalysis.fromJson(Map<String, dynamic> json) {
    return EmotionalAnalysis(
      emotions: (json['emotions'] as List)
          .map((e) => Emotion.fromJson(e))
          .toList(),
      insight: json['insight'],
      dominantMood: json['dominantMood'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'emotions': emotions.map((e) => e.toJson()).toList(),
      'insight': insight,
      'dominantMood': dominantMood,
    };
  }
}

class JournalEntry {
  final String id;
  final DateTime date;
  final String audioPath;
  final EmotionalAnalysis? analysis;
  
  JournalEntry({
    required this.id,
    required this.date,
    required this.audioPath,
    this.analysis,
  });
  
  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      audioPath: json['audioPath'],
      analysis: json['analysis'] != null
          ? EmotionalAnalysis.fromJson(json['analysis'])
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'audioPath': audioPath,
      'analysis': analysis?.toJson(),
    };
  }
}

class WeeklyProgress {
  final List<bool> daysCompleted;
  final int totalDays;
  
  WeeklyProgress({
    required this.daysCompleted,
    this.totalDays = 7,
  });
  
  factory WeeklyProgress.empty() {
    return WeeklyProgress(
      daysCompleted: List.generate(7, (index) => false),
    );
  }
  
  factory WeeklyProgress.fromJson(Map<String, dynamic> json) {
    return WeeklyProgress(
      daysCompleted: (json['daysCompleted'] as List)
          .map((e) => e as bool)
          .toList(),
      totalDays: json['totalDays'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'daysCompleted': daysCompleted,
      'totalDays': totalDays,
    };
  }
} 