import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class AssetVideoScreen extends StatefulWidget {
  final String assetPath;

  AssetVideoScreen({required this.assetPath});

  @override
  _AssetVideoScreenState createState() => _AssetVideoScreenState();
}

class _AssetVideoScreenState extends State<AssetVideoScreen> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(widget.assetPath);

    _controller.initialize().then((_) {
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
      appBar: AppBar(title: Text("Safety Video")),
      body: _chewieController == null
          ? Center(child: CircularProgressIndicator())
          : Chewie(controller: _chewieController!),
    );
  }
}
