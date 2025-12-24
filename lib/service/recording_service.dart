// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:permission_handler/permission_handler.dart';

// class RecordingService {
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
//   bool _isInitialized = false;
//   DateTime? _startTime;

//   Future<void> init() async {
//     if (!_isInitialized) {
//       var status = await Permission.microphone.request();
//       if (!status.isGranted) {
//         throw Exception("Microphone permission denied");
//       }

//       await _recorder.openRecorder();
//       _isInitialized = true;
//     }
//   }

//   Future<String> startRecording(String path) async {
//     if (!_isInitialized) {
//       await init();
//     }

//     final filePath = '$path/help_${DateTime.now().millisecondsSinceEpoch}.m4a';
//     _startTime = DateTime.now();

//     await _recorder.startRecorder(toFile: filePath, codec: Codec.aacMP4);

//     return filePath;
//   }

//   Future<int> stopRecording() async {
//     await _recorder.stopRecorder();
//     final endTime = DateTime.now();
//     return endTime.difference(_startTime!).inSeconds;
//   }

//   void dispose() {
//     _recorder.closeRecorder();
//   }
// }

import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordingService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isReady = false;
  String? currentPath;

  Future<void> init() async {
    await Permission.microphone.request();
    await Permission.storage.request();

    await _recorder.openRecorder();
    _isReady = true;
  }

  Future<String> start() async {
    if (!_isReady) throw Exception("Recorder not ready");

    final dir = await getExternalStorageDirectory();
    final folder = Directory('${dir!.path}/WSA_Recordings');

    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    currentPath =
        '${folder.path}/rec_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder.startRecorder(toFile: currentPath, codec: Codec.aacADTS);

    return currentPath!;
  }

  Future<void> stop() async {
    await _recorder.stopRecorder();
  }

  Future<String> getRecordingPath(String fileName) async {
    final directory = Directory('/storage/emulated/0/WSA'); // public folder
    if (!await directory.exists()) await directory.create(recursive: true);
    return '${directory.path}/$fileName.aac'; // or .m4a/.wav
  }

  void dispose() {
    _recorder.closeRecorder();
  }
}
