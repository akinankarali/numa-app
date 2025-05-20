import 'package:flutter/foundation.dart';
import '../models/breathing_exercise.dart';

class BreathingProvider with ChangeNotifier {
  List<BreathingExercise> _exercises = [];
  BreathingExercise? _currentExercise;
  int _currentStep = 0;
  int _currentRepetition = 0;
  bool _isExerciseActive = false;
  
  List<BreathingExercise> get exercises => _exercises;
  BreathingExercise? get currentExercise => _currentExercise;
  int get currentStep => _currentStep;
  int get currentRepetition => _currentRepetition;
  bool get isExerciseActive => _isExerciseActive;
  
  BreathingProvider() {
    _loadExercises();
  }
  
  void _loadExercises() {
    _exercises = BreathingExercise.getPredefinedExercises();
    notifyListeners();
  }
  
  BreathingExercise? getExerciseForMood(String mood) {
    return _exercises.firstWhere(
      (exercise) => exercise.targetMood.toLowerCase() == mood.toLowerCase(),
      orElse: () => _exercises.first,
    );
  }
  
  void startExercise(BreathingExercise exercise) {
    _currentExercise = exercise;
    _currentStep = 0;
    _currentRepetition = 0;
    _isExerciseActive = true;
    notifyListeners();
  }
  
  void nextStep() {
    if (_currentExercise == null || !_isExerciseActive) return;
    
    _currentStep++;
    
    if (_currentStep >= _currentExercise!.steps.length - 1) {
      _currentStep = 0;
      _currentRepetition++;
      
      if (_currentRepetition >= _currentExercise!.repetitions) {
        _completeExercise();
      }
    }
    
    notifyListeners();
  }
  
  void _completeExercise() {
    _isExerciseActive = false;
    notifyListeners();
  }
  
  void stopExercise() {
    _isExerciseActive = false;
    _currentExercise = null;
    notifyListeners();
  }
  
  int getCurrentStepDuration() {
    if (_currentExercise == null || !_isExerciseActive) return 0;
    
    if (_currentStep < _currentExercise!.timings.length) {
      return _currentExercise!.timings[_currentStep];
    }
    
    return 0;
  }
  
  String getCurrentInstructionText() {
    if (_currentExercise == null || !_isExerciseActive) return '';
    
    if (_currentStep < _currentExercise!.steps.length) {
      return _currentExercise!.steps[_currentStep];
    }
    
    return '';
  }
} 