import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wsa2/service/api_service.dart';

import '../../Theme/colors.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();

  String? recordingPath;
  bool isRecording = false;
  bool isPlaying = false;
  bool isLoading = false;

  List<dynamic> recordings = [];

  @override
  void initState() {
    super.initState();
    _debugToken();
    _fetchRecordings();
  }

  Future<void> _debugToken() async {
    final prefs = await SharedPreferences.getInstance();
    print("DEBUG TOKEN => ${prefs.getString("token")}");
    print("DEBUG USERID => ${prefs.getString("userID")}");
  }

  // ---------------- FETCH RECORDINGS ----------------
  Future<void> _fetchRecordings() async {
    setState(() => isLoading = true);
    try {
      recordings = await RecordingApiService.getMyRecordings();
    } catch (e) {
      _toast("Failed to load recordings");
    }
    setState(() => isLoading = false);
  }

  // ---------------- START RECORD ----------------
  Future<void> _startRecording() async {
    if (await audioRecorder.hasPermission()) {
      final dir = await getApplicationDocumentsDirectory();
      final path = p.join(
        dir.path,
        "rec_${DateTime.now().millisecondsSinceEpoch}.m4a",
      );

      await audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      setState(() {
        isRecording = true;
        recordingPath = null;
      });
    }
  }

  // ---------------- STOP + SAVE + UPLOAD ----------------
  Future<void> _stopRecording() async {
    final path = await audioRecorder.stop();
    if (path == null) return;

    setState(() {
      isRecording = false;
      recordingPath = path;
    });

    try {
      await RecordingApiService.uploadRecording(File(path));
      await _fetchRecordings();
      _toast("Recording saved successfully");
    } catch (e) {
      _toast("Upload failed. Please login again.");
    }
  }

  // ---------------- PLAY LOCAL ----------------
  Future<void> _playLocal() async {
    if (recordingPath == null) return;

    if (audioPlayer.playing) {
      await audioPlayer.stop();
      setState(() => isPlaying = false);
    } else {
      await audioPlayer.setFilePath(recordingPath!);
      audioPlayer.play();
      setState(() => isPlaying = true);
    }
  }

  // ---------------- PLAY SERVER ----------------
  Future<void> _playServer(String url) async {
    await audioPlayer.stop();
    await audioPlayer.setUrl(url);
    audioPlayer.play();
  }

  // ---------------- DELETE ----------------
  Future<void> _deleteRecording(String id) async {
    await RecordingApiService.deleteRecording(id);
    _fetchRecordings();
    _toast("Recording deleted");
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Voice Recorder")),
      floatingActionButton: _recordingButton(),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // -------- LAST LOCAL RECORD --------
          if (recordingPath != null)
            MaterialButton(
              color: AppColors.primary,
              onPressed: _playLocal,
              child: Text(
                isPlaying ? "Stop Playing" : "Play Last Recording",
                style: const TextStyle(color: Colors.white),
              ),
            ),

          const SizedBox(height: 20),

          // -------- SERVER RECORDINGS --------
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : recordings.isEmpty
                ? const Center(child: Text("No recordings found"))
                : ListView.builder(
                    itemCount: recordings.length,
                    itemBuilder: (context, index) {
                      final r = recordings[index];
                      final audioUrl =
                          "https://wsa-1.onrender.com/${r['filePath']}";

                      return Card(
                        child: ListTile(
                          leading: IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () => _playServer(audioUrl),
                          ),
                          title: Text(r["originalName"] ?? "Voice Note"),
                          subtitle: Text(
                            r["createdAt"]?.toString().substring(0, 10) ?? "",
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteRecording(r["_id"]),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ---------------- RECORD BUTTON ----------------
  Widget _recordingButton() {
    return FloatingActionButton(
      backgroundColor: AppColors.primary,
      onPressed: isRecording ? _stopRecording : _startRecording,
      child: Icon(isRecording ? Icons.stop : Icons.mic),
    );
  }
}
