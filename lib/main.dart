import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const SpeechToTextApp());
}

class SpeechToTextApp extends StatelessWidget {
  const SpeechToTextApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SpeechToTextScreen(),
    );
  }
}

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({super.key});

  @override
  _SpeechToTextScreenState createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Tap the mic to start speaking...";
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _audioFilePath;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initializePermissions();
  }

  Future<void> _initializePermissions() async {
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  Future<void> _startRecording() async {
    if (await _audioRecorder.hasPermission()) {
      final dir = await getApplicationDocumentsDirectory();
      _audioFilePath = "${dir.path}/recorded_audio.m4a";
      await _audioRecorder.start(const RecordConfig(), path: _audioFilePath!);
    }
  }

  Future<void> _stopRecording() async {
    await _audioRecorder.stop();
    setState(() {
      //_audioRecorder = _text;
    }); // Refresh UI to show the recorded file
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _startRecording();
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
        log(_text);
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      _stopRecording();
    }
  }

  void _playAudio() {
    if (_audioFilePath != null) {
      _audioPlayer.play(DeviceFileSource(_audioFilePath!));
      log(_text);
      log(_audioPlayer.source.toString());
    }
  }

  void _shareAudio() {
    // Use a package like 'share_plus' to share the recorded audio file
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Speech to Text and Audio Recorder")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              _isListening ? _text : _audioRecorder.toString(),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _listen,
              child: Text(_isListening ? "Stop" : "Start Speaking"),
            ),
            if (_audioFilePath != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _playAudio,
                child: const Text("Play Recorded Audio"),
              ),
              ElevatedButton(
                onPressed: _shareAudio,
                child: const Text("Share Recorded Audio"),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
