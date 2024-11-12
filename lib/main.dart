import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

class SpeechRecorderApp extends StatefulWidget {
  const SpeechRecorderApp({super.key});

  @override
  _SpeechRecorderAppState createState() => _SpeechRecorderAppState();
}

class _SpeechRecorderAppState extends State<SpeechRecorderApp> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  String _recordedText = '';
  String? _audioPath;

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(onResult: (result) {
        setState(() {
          _recordedText = result.recognizedWords;
          log("=============${_recordedText.toString()}");
        });
      });
    }
  }

  void _stopListening() async {
    await _speech.stop();
  }

  Future<void> _startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    _audioPath = '${tempDir.path}/recording.m4a';
    await _audioRecorder.start(const RecordConfig(), path: _audioPath!);
  }

  Future<void> _stopRecording() async {
    await _audioRecorder.stop();
    setState(() {}); // To refresh UI after recording
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speech Recorder')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Recorded Text:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text("=============${_recordedText.toString()}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startListening,
              child: const Text('Start Listening'),
            ),
            ElevatedButton(
              onPressed: _stopListening,
              child: const Text('Stop Listening'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startRecording,
              child: const Text('Start Recording'),
            ),
            ElevatedButton(
              onPressed: _stopRecording,
              child: const Text('Stop Recording'),
            ),
            if (_audioPath != null)
              Column(
                children: [
                  Text('Audio Recorded: $_audioPath'),
                  ElevatedButton(
                    onPressed: () {
                      _audioPlayer.play(DeviceFileSource(_audioPath!));
                      log("=============${_recordedText.toString()}");
                    },
                    child: const Text('Play Recorded Audio'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(const MaterialApp(home: SpeechRecorderApp()));
