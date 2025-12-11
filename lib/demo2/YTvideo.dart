// import 'package:flutter/material.dart';
// import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// class YouTubeVideoScreen extends StatefulWidget {
//   final String videoUrl; // YouTube URL

//   YouTubeVideoScreen({required this.videoUrl});

//   @override
//   _YouTubeVideoScreenState createState() => _YouTubeVideoScreenState();
// }

// class _YouTubeVideoScreenState extends State<YouTubeVideoScreen> {
//   late YoutubePlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl)!;
//     _controller = YoutubePlayerController(
//       initialVideoId: videoId,
//       flags: YoutubePlayerFlags(autoPlay: true, mute: false),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("YouTube Video")),
//       body: YoutubePlayer(
//         controller: _controller,
//         showVideoProgressIndicator: true,
//       ),
//     );
//   }
// }
