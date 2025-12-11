import 'package:flutter/material.dart';
// import 'package:safecircle/demo2/videomodel.dart';
// import 'package:safecircle/demo2/videoplayscreen.dart';
import 'package:wsa2/demo2/videomodel.dart';
import 'package:wsa2/demo2/videoplayscreen.dart';

class VideoScreen extends StatelessWidget {
  final List<SafetyVideo> videos = [
    SafetyVideo(
      title: "Self-Defense Basics",
      url:
          "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4",
    ),
    SafetyVideo(
      title: "Street Safety Tips",
      url:
          "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Self-Safety Videos")),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.play_circle_fill, color: Colors.red),
            title: Text(videos[index].title),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(video: videos[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
