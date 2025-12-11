import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:safecircle/demo2/YTvideo.dart';
// import 'package:safecircle/demo2/assetvideo.dart';
// import 'package:safecircle/demo2/videomodel.dart';
// import 'package:safecircle/demo2/videoplayscreen.dart';
// import 'package:safecircle/demo2/videoscreen.dart';
// import 'package:safecircle/screens/folder.dart';
// import 'package:safecircle/screens/auth/login_page.dart';
// import 'package:safecircle/screens/auth/signup_page.dart';
// import 'package:safecircle/screens/map/map.dart';
// import 'package:safecircle/screens/map/map1.dart';
// import 'package:safecircle/screens/map/map_page.dart';
// import 'package:safecircle/screens/onbording/onbording.dart';
// import 'package:video_player/video_player.dart';
import 'package:wsa2/demo2/assetvideo.dart';
import 'package:wsa2/demo2/videoscreen.dart';
// import 'package:wsa2/folder.dart';
import 'package:wsa2/screens/auth/login_page.dart';
import 'package:wsa2/screens/auth/signup_page.dart';
import 'package:wsa2/screens/folder.dart';
import 'package:wsa2/screens/map/map1.dart';
import 'package:wsa2/screens/map/route_finder_page.dart';
import 'package:wsa2/screens/onbording/onbording.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primarySwatch: Colors.pink,
      ),
      home: const FirstPage(),
    );
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  "https://wallpapers.com/images/hd/neon-colored-peacock-feather-bzoqdr609msdh9m6.jpg",
                ),
                fit: BoxFit.cover, // fills full page
              ),
            ),
          ),
          Column(
            children: [
              Center(
                child: Column(
                  children: [
                    SizedBox(height: 50),
                    Text(
                      "Welcome to SafeCircle",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 20),
                    button1(name: "Login Page", pagename: LoginPage()),
                    SizedBox(height: 10),
                    button1(name: "Sign in Page", pagename: SignupPage()),
                    SizedBox(height: 10),
                    button1(
                      name: "Onbording Screen",
                      pagename: ImageCarouselScreen(),
                    ),
                    SizedBox(height: 10),
                    // button1(
                    //   name: "Map page",
                    //   pagename: MapPage(lat: 20.51, lon: 75.15),
                    // ),
                    SizedBox(height: 10),
                    button1(name: "folder screen", pagename: FolderScreen()),
                    SizedBox(height: 10),
                    button1(name: "video screen", pagename: VideoScreen()),
                    SizedBox(height: 10),
                    button1(
                      name: "Route finder page",
                      pagename: RouteFinderPage(),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AssetVideoScreen(
                              assetPath: "videos/video1.mp4",
                            ),
                          ),
                        );
                      },
                      child: Text("Play Safety Video"),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MapPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Open Map",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class button1 extends StatefulWidget {
  const button1({super.key, required this.name, required this.pagename});

  final String name;
  final Widget pagename;

  @override
  State<button1> createState() => _button1State();
}

class _button1State extends State<button1> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.5), // transparent white
          shadowColor: const Color.fromARGB(255, 88, 88, 88).withOpacity(0.1),
          elevation: 5,
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Text(
              widget.name,
              style: TextStyle(
                color: const Color.fromARGB(255, 255, 255, 255),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ],
              ),
            ),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => widget.pagename),
          );
        },
      ),
    );
  }
}
