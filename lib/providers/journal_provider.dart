import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/emotion.dart';

class JournalProvider with ChangeNotifier {
  List<JournalEntry> _entries = [];
  WeeklyProgress _weeklyProgress = WeeklyProgress.empty();
  EmotionalAnalysis? _lastAnalysis;
  bool _isRecording = false;
  
  List<JournalEntry> get entries => _entries;
  WeeklyProgress get weeklyProgress => _weeklyProgress;
  EmotionalAnalysis? get lastAnalysis => _lastAnalysis;
  bool get isRecording => _isRecording;
  
  JournalProvider() {
    _loadData();
  }
  
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load entries
      final entriesJson = prefs.getString('journal_entries');
      if (entriesJson != null) {
        final List<dynamic> decoded = jsonDecode(entriesJson);
        _entries = decoded.map((e) => JournalEntry.fromJson(e)).toList();
      }
      
      // Load weekly progress
      final progressJson = prefs.getString('weekly_progress');
      if (progressJson != null) {
        _weeklyProgress = WeeklyProgress.fromJson(jsonDecode(progressJson));
      } else {
        _weeklyProgress = WeeklyProgress.empty();
        _updateWeeklyProgress();
      }
      
      // Load last analysis
      final analysisJson = prefs.getString('last_analysis');
      if (analysisJson != null) {
        _lastAnalysis = EmotionalAnalysis.fromJson(jsonDecode(analysisJson));
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading data: $e');
      }
    }
  }
  
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save entries
      final entriesJson = jsonEncode(_entries.map((e) => e.toJson()).toList());
      await prefs.setString('journal_entries', entriesJson);
      
      // Save weekly progress
      final progressJson = jsonEncode(_weeklyProgress.toJson());
      await prefs.setString('weekly_progress', progressJson);
      
      // Save last analysis
      if (_lastAnalysis != null) {
        final analysisJson = jsonEncode(_lastAnalysis!.toJson());
        await prefs.setString('last_analysis', analysisJson);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving data: $e');
      }
    }
  }
  
  void setRecording(bool value) {
    _isRecording = value;
    notifyListeners();
  }
  
  Future<void> addEntry(String audioPath) async {
    try {
      final now = DateTime.now();
      final String id = now.millisecondsSinceEpoch.toString();
      
      final entry = JournalEntry(
        id: id,
        date: now,
        audioPath: audioPath,
      );
      
      _entries.add(entry);
      _updateWeeklyProgress();
      await _saveData();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding entry: $e');
      }
    }
  }
  
  Future<void> updateEntryWithAnalysis(String entryId, EmotionalAnalysis analysis) async {
    try {
      final index = _entries.indexWhere((entry) => entry.id == entryId);
      
      if (index != -1) {
        final updatedEntry = JournalEntry(
          id: _entries[index].id,
          date: _entries[index].date,
          audioPath: _entries[index].audioPath,
          analysis: analysis,
        );
        
        _entries[index] = updatedEntry;
        _lastAnalysis = analysis;
        
        await _saveData();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating entry with analysis: $e');
      }
    }
  }
  
  void _updateWeeklyProgress() {
    // Get this week's entries
    final now = DateTime.now();
    final int currentWeekday = now.weekday;
    final startOfWeek = now.subtract(Duration(days: currentWeekday - 1));
    
    // Create a list of days in this week
    List<DateTime> daysInWeek = List.generate(7, (index) {
      return DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + index,
      );
    });
    
    // Check which days have entries
    List<bool> daysCompleted = daysInWeek.map((day) {
      final formattedDay = DateFormat('yyyy-MM-dd').format(day);
      return _entries.any((entry) {
        final formattedEntryDay = DateFormat('yyyy-MM-dd').format(entry.date);
        return formattedEntryDay == formattedDay;
      });
    }).toList();
    
    _weeklyProgress = WeeklyProgress(daysCompleted: daysCompleted);
  }
  
  // Mock analysis for demo purposes
  Future<EmotionalAnalysis> analyzeAudio(String entryId) async {
    // In a real app, this would call an API to analyze the audio
    // For now, we'll return mock data
    await Future.delayed(const Duration(seconds: 2)); // Simulate API call
    
    final List<String> emotions = ['Calm', 'Hopeful', 'Anxious', 'Stressed'];
    final List<double> percentages = [15, 10, 45, 30];
    
    final List<Emotion> emotionList = List.generate(
      emotions.length,
      (index) => Emotion(
        name: emotions[index],
        percentage: percentages[index],
      ),
    );
    
    final analysis = EmotionalAnalysis(
      emotions: emotionList,
      insight: 'Today you seem to be experiencing higher levels of anxiety and stress. These emotions might be related to the work deadlines and personal commitments you mentioned. There are also hints of calm and hope in your reflection, which suggests your resilience.',
      dominantMood: 'anxious',
    );
    
    await updateEntryWithAnalysis(entryId, analysis);
    return analysis;
  }
  
  Future<void> deleteEntry(String id) async {
    try {
      final entryIndex = _entries.indexWhere((entry) => entry.id == id);
      
      if (entryIndex != -1) {
        final entry = _entries[entryIndex];
        
        // Delete audio file
        final file = File(entry.audioPath);
        if (await file.exists()) {
          await file.delete();
        }
        
        _entries.removeAt(entryIndex);
        _updateWeeklyProgress();
        await _saveData();
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting entry: $e');
      }
    }
  }
  
  bool hasTodayEntry() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _entries.any((entry) {
      final entryDate = DateFormat('yyyy-MM-dd').format(entry.date);
      return entryDate == today;
    });
  }
  
  int getDaysUntilSunday() {
    final now = DateTime.now();
    final daysUntilSunday = 7 - now.weekday;
    return daysUntilSunday == 0 ? 7 : daysUntilSunday;
  }
  
  // Check if we have entries for this week for Sunday Ritual
  bool hasEntriesForWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return _entries.any((entry) {
      return entry.date.isAfter(startOfWeek) &&
          entry.date.isBefore(startOfWeek.add(const Duration(days: 7)));
    });
  }
} 