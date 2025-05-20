import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/journal_provider.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({Key? key}) : super(key: key);

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final _audioRecorder = Record();
  bool _isRecording = false;
  bool _isPaused = false;
  bool _isCompleted = false;
  String? _path;
  Duration _recordDuration = Duration.zero;
  
  @override
  void initState() {
    super.initState();
    _requestPermission();
  }
  
  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }
  
  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission is required to record audio'),
        ),
      );
      Navigator.pop(context);
    }
  }
  
  Future<void> _start() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'numa_journal_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _path = '${appDir.path}/$fileName';
      
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(
          path: _path,
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          samplingRate: 44100,
        );
        
        setState(() {
          _isRecording = true;
          _isPaused = false;
          _recordDuration = Duration.zero;
        });
        
        Provider.of<JournalProvider>(context, listen: false).setRecording(true);
        
        _updateDuration();
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
  }
  
  Future<void> _pause() async {
    try {
      await _audioRecorder.pause();
      setState(() {
        _isPaused = true;
      });
    } catch (e) {
      print('Error pausing recording: $e');
    }
  }
  
  Future<void> _resume() async {
    try {
      await _audioRecorder.resume();
      setState(() {
        _isPaused = false;
      });
    } catch (e) {
      print('Error resuming recording: $e');
    }
  }
  
  Future<void> _stop() async {
    try {
      final path = await _audioRecorder.stop();
      
      setState(() {
        _isRecording = false;
        _isPaused = false;
        _isCompleted = true;
      });
      
      Provider.of<JournalProvider>(context, listen: false).setRecording(false);
      
      if (path != null) {
        _path = path;
      }
    } catch (e) {
      print('Error stopping recording: $e');
    }
  }
  
  void _updateDuration() {
    if (!_isRecording) return;
    
    Future.delayed(const Duration(seconds: 1), () async {
      if (_isRecording && !_isPaused && mounted) {
        final duration = await _audioRecorder.getDuration();
        if (duration != null && mounted) {
          setState(() {
            _recordDuration = duration;
          });
        }
        _updateDuration();
      }
    });
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
  
  Future<void> _saveAndAnalyze() async {
    if (_path == null) return;
    
    final journalProvider = Provider.of<JournalProvider>(context, listen: false);
    await journalProvider.addEntry(_path!);
    
    final entries = journalProvider.entries;
    if (entries.isNotEmpty) {
      final latestEntry = entries.last;
      
      Navigator.pushReplacementNamed(
        context,
        '/journal-success',
        arguments: latestEntry.id,
      );
    }
  }
  
  Widget _buildRecordingUI() {
    if (_isCompleted) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.save,
              size: 40,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your recording is complete! Save it to analyze your emotions and add to your journal.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _saveAndAnalyze,
            icon: const Icon(Icons.analytics_outlined),
            label: const Text('Save & Analyze'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 48),
            ),
          ),
        ],
      );
    }
    
    if (_isRecording) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.purple.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: _isPaused
                  ? const Icon(
                      Icons.mic_off,
                      size: 40,
                      color: Colors.purple,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatDuration(_recordDuration),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          if (!_isPaused)
            Text(
              "I'm listening. Share your thoughts and feelings...",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            )
          else
            Text(
              "Recording paused",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _stop,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.red.shade100,
                  foregroundColor: Colors.red,
                ),
                child: const Icon(Icons.stop, size:
 30),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _isPaused ? _resume : _pause,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(24),
                  backgroundColor: Colors.purple,
                ),
                child: Icon(
                  _isPaused ? Icons.play_arrow : Icons.pause,
                  size: 36,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      );
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.purple.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mic,
            size: 40,
            color: Colors.purple,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'How are you feeling today? Tap to start recording your thoughts.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _start,
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
          ),
          child: const Text('Start Recording'),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Voice Journal'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Take 3-5 minutes to reflect on your thoughts and feelings',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Expanded(
                child: Center(
                  child: _buildRecordingUI(),
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.purple,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Today's Prompt",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'What emotions are you carrying today? Where do you feel them in your body?',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tips for Reflection',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildReflectionTip('Speak naturally, as if talking to a trusted friend'),
              _buildReflectionTip('There are no right or wrong answers'),
              _buildReflectionTip('Focus on how you feel, not just what happened'),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildReflectionTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.circle,
            size: 8,
            color: Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 