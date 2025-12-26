import 'package:flutter/material.dart';
import 'package:wsa2/Theme/colors.dart';
import 'package:wsa2/screens/main_bottom_nav.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VideoListPage(videos: videos), // ✅ FIRST SCREEN
    );
  }
}

/// ================= VIDEO DATA =================
final List<Map<String, String>> videos = [
  {"title": "Women Safety Awareness", "videoId": "gjvbGW8s2Wc"},
  {"title": "Self Defence Tips", "videoId": "TFeZjJqqBoE"},
  {"title": "Emergency Safety Training", "videoId": "B8NJajV6xVs"},
  {"title": "Escape Wrist Grabs", "videoId": "fPybGwfBwho"},
  {"title": "Escape Grabs and Slaps", "videoId": "KXobOZdHvw8"},
  {
    "title": "What To Do If a Girl Is Threatened With a Knife",
    "videoId": "gJueuxYQ2ds",
  },
  {"title": "Defending Yourself From An Attack", "videoId": "za30qxWpY5E"},
  {
    "title": "Confidence in Your Pocket: Women’s Self-Defense Gadgets",
    "videoId": "5aGdh00GAvs",
  },
  {"title": "Stay Safe for Unknown Persons", "videoId": "U-4e5SsXEqg"},
  {"title": "To save yourself from Kidnapping", "videoId": "z8T29GYPlVM"},
];

/// ================= VIDEO LIST PAGE (FIRST PAGE) =================
class VideoListPage extends StatelessWidget {
  final List<Map<String, String>> videos;
  const VideoListPage({super.key, required this.videos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Women Safety Videos", style: AppTextStyles.heading),
      ),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final thumbnail =
              "https://img.youtube.com/vi/${videos[index]["videoId"]}/hqdefault.jpg";

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WomenSafetyPlayerPage(initialIndex: index),
                ),
              );
            },
            child: Card(
              color: Colors.white,
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: Image.network(
                      thumbnail,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      videos[index]["title"]!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const WSABottomBar(currentIndex: 2),
    );
  }
}

/// ================= PLAYER PAGE (SECOND PAGE) =================
class WomenSafetyPlayerPage extends StatefulWidget {
  final int initialIndex;
  const WomenSafetyPlayerPage({super.key, required this.initialIndex});

  @override
  State<WomenSafetyPlayerPage> createState() => _WomenSafetyPlayerPageState();
}

class _WomenSafetyPlayerPageState extends State<WomenSafetyPlayerPage> {
  late YoutubePlayerController controller;
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;

    controller = YoutubePlayerController(
      initialVideoId: videos[selectedIndex]["videoId"]!,
      flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
    );
  }

  void playVideo(String videoId, int index) {
    controller.load(videoId);
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text("Women Safety", style: AppTextStyles.heading)),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // 🎥 VIDEO PLAYER
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 500,
                child: YoutubePlayer(
                  controller: controller,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 🛡 TITLE
            Row(
              children: [
                const Icon(Icons.security, color: AppColors.primary),
                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    videos[selectedIndex]["title"]!,
                    style: AppTextStyles.subHeading,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 10),
                const Text(
                  "Stay Alert • Stay Safe • Be Strong",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 📃 VIDEO LIST BELOW PLAYER
            Expanded(
              child: ListView.builder(
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedIndex == index;
                  final thumbnail =
                      "https://img.youtube.com/vi/${videos[index]["videoId"]}/hqdefault.jpg";

                  return GestureDetector(
                    onTap: () => playVideo(videos[index]["videoId"]!, index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            thumbnail,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          videos[index]["title"]!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.red : Colors.black,
                          ),
                        ),
                        subtitle: const Text("Women Safety Training"),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
