import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class VoiceRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  int _recordingIndex = 0;

  Future<String> _tempPath([String? customName]) async {
    final dir = await getTemporaryDirectory();
    final filename = customName ?? 'recording_${_recordingIndex++}_${DateTime.now().millisecondsSinceEpoch}.wav';
    return '${dir.path}/$filename';
  }

  Future<void> start([String? customFileName]) async {
    if (_isRecording) {
      // Already recording
      return;
    }

    if (await _recorder.hasPermission()) {
      final path = await _tempPath(customFileName);
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: path,
      );
      _isRecording = true;
    }
  }

  Future<File?> stop() async {
    if (!_isRecording) return null;

    final path = await _recorder.stop();
    _isRecording = false;
    if (path == null) return null;
    return File(path);
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}
