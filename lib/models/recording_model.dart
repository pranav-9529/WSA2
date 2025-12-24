import 'package:hive/hive.dart';

part 'recording_model.g.dart';

@HiveType(typeId: 1)
class RecordingModel extends HiveObject {
  @HiveField(0)
  String path;

  @HiveField(1)
  DateTime createdAt;

  RecordingModel({required this.path, required this.createdAt});
}
