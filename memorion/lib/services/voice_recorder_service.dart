import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

class VoiceRecorderService {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;

  Future<String> _tempPath() async {
    final dir = await getTemporaryDirectory();
    return '${dir.path}/question.wav';
  }

  Future<void> start() async {
    if (_isRecording) {
      // Already recording
      return;
    }

    if (await _recorder.hasPermission()) {
      final path = await _tempPath();
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
