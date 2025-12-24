import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

class RecordingService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _initialized = false;
  String? _currentPath;

  Future<void> init() async {
    await _recorder.openRecorder();
    _initialized = true;
  }

  Future<String> startRecording() async {
    if (!_initialized) {
      throw Exception("Recorder not initialized");
    }

    final dir = await getApplicationDocumentsDirectory();
    _currentPath =
        '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(toFile: _currentPath, codec: Codec.aacADTS);

    return _currentPath!;
  }

  Future<int> stopRecording() async {
    await _recorder.stopRecorder();
    return DateTime.now().second; // replace later if needed
  }

  void dispose() {
    _recorder.closeRecorder();
  }
}
