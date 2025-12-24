import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wsa2/Theme/colors.dart';
import 'package:wsa2/screens/folder%20and%20contacts/folder.dart';
import 'package:wsa2/screens/map/map1.dart';
import 'package:wsa2/screens/map/route_finder_page.dart';
import 'package:wsa2/screens/recording/RecordingPage.dart';
import 'package:wsa2/service/locationservice.dart';
import 'package:wsa2/service/nearby_service.dart';
import 'package:wsa2/widgets/live_location_appbar2.dart';
import 'package:wsa2/widgets/nearby_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  //String userName = "User";

  String police = "Loading...";
  String hospital = "Loading...";
  double? userLat;
  double? userLon;

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? "User";
  }

  String fname = "User";

  @override
  void initState() {
    super.initState();
    loadUserName();
    Future.microtask(loadNearbyPlaces);
  }

  Future<void> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fname = prefs.getString('userName') ?? "User";
    });
  }
  // @override
  // void initState() {
  //   super.initState();
  //   _loadUserName();
  //   Future.microtask(loadNearbyPlaces);
  // }

  // Future<void> _loadUserName() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final name = prefs.getString('username') ?? "User";
  //   setState(() {
  //     userName = name;
  //   });
  // }

  Future<void> loadNearbyPlaces() async {
    final location = await LocationService.getCurrentLocation();
    if (location == null) {
      setState(() {
        police = "Location not available";
        hospital = "Location not available";
      });
      return;
    }

    userLat = location.latitude;
    userLon = location.longitude;

    final policeList = await NearbyService.fetchNearby(
      lat: userLat!,
      lon: userLon!,
      type: "police",
    );

    final hospitalList = await NearbyService.fetchNearby(
      lat: userLat!,
      lon: userLon!,
      type: "hospital",
    );

    setState(() {
      police = policeList.isNotEmpty
          ? policeList.take(3).join("\n• ")
          : "No police station found nearby";

      hospital = hospitalList.isNotEmpty
          ? hospitalList.take(3).join("\n• ")
          : "No hospital found nearby";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // appBar: LiveLocationAppBar(latitude: userLat, longitude: userLon),
      appBar: UserLocationAppBar(userDisplayName: fname),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 255, 255, 255),
                    Color(0xFFF3A3BE),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9098),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Center(
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE30F33),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                            color: const Color(0xFFBD0140),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                              "SOS",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            NearbyCard(
              title: "Nearby Police S. within 10 Km.",
              subtitle: police,
              icon: Icons.local_police,
              onTap: () {
                // later open map
              },
            ),
            const SizedBox(height: 10),
            NearbyCard(
              title: "Nearby Hospital within 10 Km.",
              subtitle: hospital,
              icon: Icons.local_hospital,
              onTap: () {
                // later open map
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                card1(
                  image: "assets/images/safe.png",
                  cardname: "Safe Route",
                  pagename: RouteFinderPage(),
                ),
                const SizedBox(width: 10),
                card1(
                  image: "assets/images/track.png",
                  cardname: "Track me",
                  pagename: MapPage(),
                ),
                const SizedBox(width: 10),
                card1(
                  image: "assets/images/image 9.png",
                  cardname: "Contacts",
                  pagename: FolderScreen(),
                ),
              ],
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecordingScreen()),
                );
              },
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white),
                child: Center(child: Text("Recording Page")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class card1 extends StatefulWidget {
  const card1({
    super.key,
    required this.image,
    required this.cardname,
    required this.pagename,
  });

  final String image;
  final String cardname;
  final Widget pagename;

  @override
  State<card1> createState() => _card1State();
}

class _card1State extends State<card1> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => widget.pagename),
        );
      },
      child: Container(
        height: 115,
        width: 107,
        decoration: BoxDecoration(
          color: AppColors.card,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 90,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(widget.image),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.cardname,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
