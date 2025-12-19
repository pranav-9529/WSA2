import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoding/geocoding.dart';
import 'package:wsa2/service/locationservice.dart';

class LiveLocationAppBar extends StatefulWidget implements PreferredSizeWidget {
  const LiveLocationAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  State<LiveLocationAppBar> createState() => _LiveLocationAppBarState();
}

class _LiveLocationAppBarState extends State<LiveLocationAppBar> {
  String locationName = "Detecting location...";
  bool isLoading = true;

  static String? cachedLocation; // 🔥 CACHE

  @override
  void initState() {
    super.initState();

    if (cachedLocation != null) {
      locationName = cachedLocation!;
      isLoading = false;
    } else {
      _loadLocationName();
    }
  }

  Future<void> _loadLocationName() async {
    try {
      final location = await LocationService.getCurrentLocation();
      if (location == null) return;

      final placemarks = await placemarkFromCoordinates(
        location.latitude!,
        location.longitude!,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        final name = "${place.subLocality ?? ''}, ${place.locality ?? ''}"
            .replaceAll(", ,", ",")
            .replaceAll(RegExp(r'^,|,$'), '');

        cachedLocation = name;

        if (mounted) {
          setState(() {
            locationName = name;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          locationName = "Location unavailable";
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 143, 162),
              Color.fromARGB(255, 255, 20, 98),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.white, size: 22),
          const SizedBox(width: 6),
          Expanded(
            child: isLoading
                ? const Text(
                    "Finding your location...",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  )
                : Text(
                    locationName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }
}
