import 'package:flutter/material.dart';
// import 'package:safecircle/demo2/videomodel.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:wsa2/demo2/videomodel.dart';

class VideoPlayerScreen extends StatefulWidget {
  final SafetyVideo video;
  VideoPlayerScreen({required this.video});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.network(widget.video.url);

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _controller,
          autoPlay: true,
          looping: false,
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.video.title)),
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (_chewieController == null) {
              return Center(child: CircularProgressIndicator());
            }
            return Chewie(controller: _chewieController!);
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading video"));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
