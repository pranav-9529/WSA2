// import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import '../models/recording_model.dart';

class RecordingRepository {
  final Box<RecordingModel> box = Hive.box<RecordingModel>('recordings');

  void saveRecording({
    required String path,
    required int duration,
    required bool isEmergency,
    required String userId,
  }) {
    box.add(
      RecordingModel(
        path: path,
        createdAt: DateTime.now(),
        //userId: userId,
        // duration: duration,
        // isEmergency: isEmergency,
      ),
    );
  }

  List<RecordingModel> getAll() => box.values.toList();
}
