import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// Import with prefix for location package
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:wsa2/Theme/colors.dart'; // keep this as-is

class UserLocationAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String userDisplayName;

  const UserLocationAppBar({super.key, required this.userDisplayName});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  State<UserLocationAppBar> createState() => _UserLocationAppBarState();
}

class _UserLocationAppBarState extends State<UserLocationAppBar> {
  String currentLocation = "Detecting location...";
  bool isLoadingLocation = true;

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  Future<void> _fetchUserLocation() async {
    try {
      loc.Location locationService = loc.Location();

      bool serviceEnabled = await locationService.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await locationService.requestService();
        if (!serviceEnabled) {
          _setLocationError("Location service disabled");
          return;
        }
      }

      loc.PermissionStatus permission = await locationService.hasPermission();
      if (permission == loc.PermissionStatus.denied ||
          permission == loc.PermissionStatus.deniedForever) {
        permission = await locationService.requestPermission();
        if (permission != loc.PermissionStatus.granted) {
          _setLocationError("Location permission denied");
          return;
        }
      }

      // 🔥 SET HIGH ACCURACY
      await locationService.changeSettings(accuracy: loc.LocationAccuracy.high);

      // 🔥 LIVE LOCATION LISTENER
      locationService.onLocationChanged.listen((loc.LocationData data) async {
        if (data.latitude == null || data.longitude == null) return;

        List<Placemark> placemarks = await placemarkFromCoordinates(
          data.latitude!,
          data.longitude!,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final locationName =
              "${place.subLocality ?? ''}, ${place.locality ?? ''}"
                  .replaceAll(", ,", ",")
                  .replaceAll(RegExp(r'^,|,$'), '');

          _setLocationSuccess(
            locationName.isNotEmpty ? locationName : "Unknown location",
          );
        }
      });
    } catch (e) {
      debugPrint("Location error: $e");
      _setLocationError("Error fetching location");
    }
  }

  void _setLocationSuccess(String locationName) {
    if (!mounted) return;
    setState(() {
      currentLocation = locationName;
      isLoadingLocation = false;
    });
  }

  void _setLocationError(String errorMessage) {
    if (!mounted) return;
    setState(() {
      currentLocation = errorMessage;
      isLoadingLocation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // black icons
        statusBarBrightness: Brightness.light,
      ),
    );

    return SafeArea(
      bottom: false, // only protect top
      child: Material(
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.25),
        child: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(color: Colors.white),
          ),
          title: Row(
            children: [
              SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, ${widget.userDisplayName}",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 20),
                      Text(
                        isLoadingLocation
                            ? "Fetching your location..."
                            : currentLocation,
                        style: AppTextStyles.body1,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none,
                size: 30,
                color: Colors.black,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
