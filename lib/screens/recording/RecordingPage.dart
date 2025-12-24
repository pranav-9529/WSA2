import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wsa2/Theme/colors.dart';
import 'package:wsa2/models/recording_model.dart';
import 'package:wsa2/service/recording_service.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen>
    with SingleTickerProviderStateMixin {
  Duration recordingDuration = Duration.zero;
  Timer? _recordingTimer;

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  final RecordingService service = RecordingService();
  final AudioPlayer player = AudioPlayer();

  bool recording = false;
  String? currentPath;
  int? playingIndex;

  Box<RecordingModel>? recordingsBox;
  String? userID;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller first
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Then load user & Hive
    _loadUser();
  }

  @override
  void dispose() {
    _animationController.dispose();
    service.dispose();
    player.dispose();
    recordingsBox?.close();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    userID = prefs.getString("userID");

    if (userID == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not logged in")));
      return;
    }

    await initHiveAndService();
  }

  Future<void> initHiveAndService() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(RecordingModelAdapter().typeId)) {
      Hive.registerAdapter(RecordingModelAdapter());
    }

    recordingsBox = await Hive.openBox<RecordingModel>('recordings_$userID');
    await service.init();

    player.playerStateStream.listen((state) => setState(() {}));
    setState(() {});
  }

  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  Future<String> getPublicRecordingPath(String fileName) async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/WSA');
      if (!await directory.exists()) await directory.create(recursive: true);
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    return '${directory.path}/$fileName.aac';
  }

  Future<void> startRecording() async {
    if (recordingsBox == null) return;

    currentPath = await service.start();

    recordingDuration = Duration.zero;

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        recordingDuration += const Duration(seconds: 1);
      });
    });

    setState(() => recording = true);
    _animationController.repeat(reverse: true);
  }

  Future<void> stopRecording() async {
    if (recordingsBox == null || currentPath == null) return;

    await service.stop();

    _recordingTimer?.cancel();

    await recordingsBox!.add(
      RecordingModel(path: currentPath!, createdAt: DateTime.now()),
    );

    setState(() {
      recording = false;
      recordingDuration = Duration.zero;
    });

    _animationController.stop();
    _animationController.reset();
  }

  Future<void> playRecording(String path, int index) async {
    if (playingIndex == index) {
      if (player.playing) {
        await player.pause();
      } else {
        await player.play();
      }
    } else {
      playingIndex = index;
      setState(() {});
      try {
        await player.stop();
        await player.setFilePath(path);
        await player.play();
      } catch (e) {
        print("Error playing recording: $e");
        playingIndex = null;
      }
    }
    setState(() {});
  }

  Future<void> deleteRecording(int index) async {
    if (recordingsBox == null) return;

    if (playingIndex == index) {
      await player.stop();
      playingIndex = null;
    }

    final recording = recordingsBox!.getAt(index);
    if (recording != null) {
      final file = File(recording.path);
      if (await file.exists()) await file.delete();
    }

    await recordingsBox!.deleteAt(index);
    setState(() {});
  }

  Future<void> shareRecording(int index) async {
    if (!await requestStoragePermission()) return;

    final recording = recordingsBox!.getAt(index);
    if (recording != null) {
      final file = File(recording.path);
      if (await file.exists()) {
        await Share.shareXFiles([
          XFile(file.path),
        ], text: "Check out this recording!");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recording file not found.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (recordingsBox == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("WSA Recorder")),
      body: Column(
        children: [
          const SizedBox(height: 20),

          /// 🎙 ANIMATED RECORD BUTTON
          Center(
            child: GestureDetector(
              onTap: recording ? stopRecording : startRecording,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  double scale = 1 + _animationController.value * 0.3;
                  return Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: recording
                          ? RadialGradient(
                              colors: [
                                Colors.red.withOpacity(0.3),
                                Colors.red.withOpacity(0.0),
                              ],
                              stops: const [0.6, 1],
                            )
                          : null,
                    ),
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: recording
                              ? AppColors.secondary
                              : const Color.fromARGB(255, 255, 255, 255),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 6,
                              color: Colors.black12,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mic,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            child: Column(
              children: [
                Text(
                  recording ? "Recording..." : "Tap to Record",
                  style: AppTextStyles.body1,
                ),
                const SizedBox(height: 6),
                if (recording)
                  Text(
                    formatDuration(recordingDuration),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      letterSpacing: 1.5,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// 📂 RECORDINGS LIST
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: recordingsBox!.listenable(),
              builder: (context, Box<RecordingModel> box, _) {
                if (box.isEmpty) {
                  return const Center(child: Text("No recordings yet"));
                }

                final recordings = box.values.toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                return ListView.builder(
                  itemCount: recordings.length,
                  itemBuilder: (context, index) {
                    final recording = recordings[index];
                    final isPlaying =
                        playingIndex != null &&
                        p.basename(recording.path) ==
                            p.basename(
                              recordingsBox!.getAt(playingIndex!)!.path,
                            ) &&
                        player.playing;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Icon(
                            isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
                            color: AppColors.primary,
                            size: 36,
                          ),
                          title: Text(
                            p.basename(recording.path),
                            style: AppTextStyles.body3,
                          ),
                          subtitle: Text(
                            recording.createdAt.toString(),
                            style: AppTextStyles.body2,
                          ),
                          onTap: () {
                            final realIndex = box.values.toList().indexOf(
                              recording,
                            );
                            playRecording(recording.path, realIndex);
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.share),
                            color: AppColors.secondary,
                            onPressed: () {
                              final realIndex = box.values.toList().indexOf(
                                recording,
                              );
                              shareRecording(realIndex);
                            },
                          ),
                          onLongPress: () {
                            final realIndex = box.values.toList().indexOf(
                              recording,
                            );
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Delete Recording"),
                                content: const Text(
                                  "Are you sure you want to delete this recording?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteRecording(realIndex);
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
