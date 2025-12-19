import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart';
import 'package:wsa2/Theme/colors.dart';
import 'package:wsa2/screens/folder%20and%20contacts/folder.dart';
import 'package:wsa2/screens/map/map1.dart';
import 'package:wsa2/screens/map/route_finder_page.dart';
import 'package:wsa2/service/locationservice.dart';
import 'package:wsa2/service/nearby_service.dart';
import 'package:wsa2/widgets/live_location_appbar.dart';
import 'package:wsa2/widgets/nearby_card.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String police = "Loading...";
  String hospital = "Loading...";

  @override
  void initState() {
    super.initState();
    loadNearbyPlaces();
  }

  Future<void> loadNearbyPlaces() async {
    final location = await LocationService.getCurrentLocation();
    if (location == null) return;

    final policeList = await NearbyService.fetchNearby(
      lat: location.latitude!,
      lon: location.longitude!,
      type: "police",
    );

    final hospitalList = await NearbyService.fetchNearby(
      lat: location.latitude!,
      lon: location.longitude!,
      type: "hospital",
    );

    setState(() {
      police = policeList.isNotEmpty ? policeList.first : "No police nearby";
      hospital = hospitalList.isNotEmpty
          ? hospitalList.first
          : "No hospital nearby";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LiveLocationAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 255, 255, 255),
                    const Color(0xFFF3A3BE),
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
            SizedBox(height: 10),
            NearbyCard(
              title: "Nearby Police S. with in 10 Km.",
              subtitle: police,
              icon: Icons.local_police,
              onTap: () {
                // later open map
              },
            ),
            SizedBox(height: 10),
            NearbyCard(
              title: "Nearby Hospital with in 10 Km.",
              subtitle: hospital,
              icon: Icons.local_hospital,
              onTap: () {
                // later open map
              },
            ),
            SizedBox(height: 20),

            Row(
              children: [
                card1(
                  image: "assets/images/safe.png",
                  cardname: "Sage Route",
                  pagename: RouteFinderPage(),
                ),
                SizedBox(width: 10),
                card1(
                  image: "assets/images/track.png",
                  cardname: "Track me",
                  pagename: MapPage(),
                ),
                SizedBox(width: 10),
                card1(
                  image: "assets/images/image 9.png",
                  cardname: "Sage Route",
                  pagename: FolderScreen(),
                ),
              ],
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
