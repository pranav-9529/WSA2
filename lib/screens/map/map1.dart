import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
// import 'package:url_launcher/url_launcher.dart';
import 'package:wsa2/Theme/colors.dart';
// import 'package:material_symbols_icons/material_symbols_icons.dart';

void main() {
  runApp(const MyApp());
}

class NearbyPlace {
  final String id;
  final String name;
  final String type;
  final double lat;
  final double lon;
  final double distanceKm;

  NearbyPlace({
    required this.id,
    required this.name,
    required this.type,
    required this.lat,
    required this.lon,
    required this.distanceKm,
  });

  static double _haversineKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371.0;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  static double _deg2rad(double deg) => deg * (pi / 180.0);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live Location Map',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const MapPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Location location = Location();
  StreamSubscription<LocationData>? locationSub;

  final MapController mapController = MapController();

  List<LatLng> routePoints = [];

  double liveLat = 0.0;
  double liveLon = 0.0;
  bool locationReady = false;
  bool loadingPlaces = false;

  Map<String, List<NearbyPlace>> byType = {
    'hospital': [],
    'police': [],
    'pharmacy': [],
    'fire_station': [],
  };

  String selectedType = 'hospital';
  NearbyPlace? selectedPlace;

  Timer? _placesTimer;
  double? _lastFetchLat;
  double? _lastFetchLon;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    locationSub?.cancel();
    _placesTimer?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) return;
    }

    location.changeSettings(accuracy: LocationAccuracy.high, interval: 1000);

    final loc = await location.getLocation();
    setState(() {
      liveLat = loc.latitude ?? 0.0;
      liveLon = loc.longitude ?? 0.0;
      locationReady = true;
    });

    _fetchAllPlaces(); // initial fetch

    locationSub = location.onLocationChanged.listen((locData) {
      setState(() {
        liveLat = locData.latitude ?? 0.0;
        liveLon = locData.longitude ?? 0.0;
        locationReady = true;
      });
      _schedulePlacesFetch();
    });
  }

  void _schedulePlacesFetch() {
    // Only fetch if moved more than 0.5 km
    if (_lastFetchLat != null &&
        _lastFetchLon != null &&
        NearbyPlace._haversineKm(
              liveLat,
              liveLon,
              _lastFetchLat!,
              _lastFetchLon!,
            ) <
            0.5) {
      return;
    }

    _lastFetchLat = liveLat;
    _lastFetchLon = liveLon;

    _placesTimer?.cancel();
    _placesTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) _fetchAllPlaces();
    });
  }

  Future<void> _fetchAllPlaces() async {
    setState(() => loadingPlaces = true);

    final types = ['hospital', 'police', 'pharmacy', 'fire_station'];
    for (final type in types) {
      byType[type] = await _fetchNearby(type);
    }

    setState(() => loadingPlaces = false);
  }

  Future<List<NearbyPlace>> _fetchNearby(String type) async {
    String query = '';

    switch (type) {
      case 'hospital':
      case 'store':
      case 'police':
      case 'fire_station':
        query = 'node["amenity"="$type"](around:6000,$liveLat,$liveLon);';
        break;
      case 'Medical':
        // Fetch both amenity=pharmacy and shop=chemist
        query =
            'node["amenity"="Medical"](around:6000,$liveLat,$liveLon);'
            'node["shop"="chemist"](around:6000,$liveLat,$liveLon);';
        break;
      // You can add more types here if needed
    }

    final url = Uri.parse(
      'https://overpass-api.de/api/interpreter?data=[out:json];$query out;',
    );

    final res = await http.get(url);
    if (res.statusCode != 200) return [];

    final data = json.decode(res.body);
    final List elements = data['elements'] ?? [];

    return elements
        .map((e) {
          final double lat = e['lat'];
          final double lon = e['lon'];
          final name = e['tags']?['name'] ?? 'Unknown $type';
          return NearbyPlace(
            id: e['id'].toString(),
            name: name,
            type: type,
            lat: lat,
            lon: lon,
            distanceKm: NearbyPlace._haversineKm(liveLat, liveLon, lat, lon),
          );
        })
        .where((p) => p.distanceKm <= 6.0)
        .toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'hospital':
        return Icons.local_hospital;
      case 'police':
        return Icons.local_police;
      case 'pharmacy':
        return Icons.medication;
      case 'fire_station':
        return Icons.fire_truck;
      default:
        return Icons.place;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'hospital':
        return const Color(0xFFE53935); // Red
      case 'police':
        return const Color(0xFF1E88E5); // Deep blue
      case 'pharmacy':
        return const Color(0xFF43A047); // Green
      case 'fire_station':
        return const Color(0xFFFF8F00); // Orange
      default:
        return Colors.grey; // Neutral
    }
  }

  // Future<void> _openInMaps(NearbyPlace p) async {
  //   final uri = Uri.parse(
  //     'https://www.google.com/maps/search/?api=1&query=${p.lat},${p.lon}',
  //   );
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri, mode: LaunchMode.externalApplication);
  //   }
  // }

  Future<void> _getRoute(double destLat, double destLon) async {
    // fetch fresh location so route always starts from current device position
    final currentLoc = await location.getLocation();

    final double startLat = currentLoc.latitude!;
    final double startLon = currentLoc.longitude!;

    print("Start from: $startLat , $startLon"); // debug
    print("Destination: $destLat , $destLon");

    // Notice the OSRM order -> LON, LAT
    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/driving/'
      '$startLon,$startLat;$destLon,$destLat?overview=full&geometries=geojson',
    );

    final res = await http.get(url);

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final coords = data["routes"][0]["geometry"]["coordinates"];

      setState(() {
        routePoints = coords
            .map<LatLng>((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
            .toList();
      });
    } else {
      print("ROUTE API ERROR: ${res.statusCode}");
    }
  }

  // ------- share location function ----------------------
  // void shareLocation(double lat, double lon) async {
  //   // Step 1: Make the map URL
  //   String mapUrl = "https://www.google.com/maps?q=$lat,$lon";

  //   // Step 2: Encode the text properly
  //   String encodedText = Uri.encodeFull("📍 My Current Location:\n$mapUrl");

  //   // Step 3: WhatsApp app URL
  //   final Uri whatsappUri = Uri.parse("whatsapp://send?text=$encodedText");

  //   // Step 4: Launch WhatsApp
  //   if (await canLaunchUrl(whatsappUri)) {
  //     await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
  //   } else {
  //     print("WhatsApp is not installed");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (!locationReady) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.loder,
            strokeWidth: 4,
            strokeCap: StrokeCap.round,
          ),
        ),
      );
    }

    final places = byType[selectedType] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Live Location", style: AppTextStyles.heading),
        automaticallyImplyLeading: true,
        backgroundColor: AppColors.background,
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(liveLat, liveLon),
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}",
                subdomains: const ['a', 'b', 'c'],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 6,
                    color: Colors.blue,
                  ),
                ],
              ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(liveLat, liveLon),
                    width: 150,
                    height: 150,
                    child: Container(
                      height: 5,
                      width: 5,
                      decoration: BoxDecoration(
                        color: const Color(0x00398DF4),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: Color.fromARGB(69, 54, 99, 248),
                          width: 60,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.my_location,
                          color: const Color(0xFF3663F8),
                        ),
                      ),
                    ),
                  ),
                  ...places.map(
                    (p) => Marker(
                      point: LatLng(p.lat, p.lon),
                      width: 40,
                      height: 40,
                      child: InkWell(
                        onTap: () => _getRoute(p.lat, p.lon),
                        child: Icon(
                          _iconForType(p.type),
                          color: _colorForType(p.type),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Bottom sheet
          Stack(
            children: [
              DraggableScrollableSheet(
                initialChildSize: 0.32,
                minChildSize: 0.28,
                maxChildSize: 0.6,
                builder: (context, controller) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 14,
                          offset: Offset(0, -4),
                          color: Colors.black26,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 80,
                          left: 0,
                          child: Container(
                            height: 500,
                            width: 500,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            Container(
                              width: 46,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 50,
                              width: 350,
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        color: AppColors.button,
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                      child: Icon(Icons.map),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Nearest Safesty Satation",
                                      style: AppTextStyles.body3,
                                    ),
                                    SizedBox(width: 40),
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        color: AppColors.button,
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                      child: Icon(Icons.arrow_downward_rounded),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 42,
                                child: ListView(
                                  controller: controller,
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  children:
                                      [
                                            'hospital',
                                            'police',
                                            'pharmacy',
                                            'fire_station',
                                            'General Srote',
                                          ]
                                          .map(
                                            (type) => Padding(
                                              padding: const EdgeInsets.only(
                                                right: 8,
                                              ),
                                              child: ChoiceChip(
                                                label: Text(type.toUpperCase()),
                                                selected: selectedType == type,
                                                onSelected: (_) => setState(
                                                  () => selectedType = type,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                            ),
                            Expanded(
                              child: _buildPlaceList(controller, places),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              // share location button
              Positioned(
                bottom: 730,
                left: 320,

                child: GestureDetector(
                  onTap: () {
                    // share logic
                  },
                  child: Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: AppColors.button,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.share,
                        color: const Color.fromARGB(255, 0, 0, 0),
                        size: 28,
                      ),
                      onPressed: () {
                        // shareLocation(liveLat, liveLon);
                      },
                    ),
                  ),
                ),
              ),
              // help location button
              Positioned(
                bottom: 680,
                left: 320,

                child: GestureDetector(
                  onTap: () {
                    // share logic
                  },
                  child: Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                      color: AppColors.button,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.help_outline,
                        color: const Color.fromARGB(255, 0, 0, 0),
                        size: 28,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => HelpPopup(),
                        );
                      },
                    ),
                  ),
                ),
              ),
              // my location button
              Positioned(
                bottom: 628,
                left: 320,

                child: GestureDetector(
                  onTap: () async {
                    // Fetch location
                    final loc = await location.getLocation();

                    setState(() {
                      liveLat = loc.latitude!;
                      liveLon = loc.longitude!;
                    });

                    print("LIVE LOCATION UPDATED 👉  $liveLat , $liveLon");

                    // Move map to new location
                    mapController.move(LatLng(liveLat, liveLon), 16.0);
                  },
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: AppColors.button,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.my_location,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      size: 25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceList(
    ScrollController controller,
    List<NearbyPlace> places,
  ) {
    if (loadingPlaces)
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.loder,
          strokeWidth: 4,
          strokeCap: StrokeCap.round,
        ),
      );
    if (places.isEmpty)
      return Center(
        child: Text("No nearby places within 6 km", style: AppTextStyles.body1),
      );

    return ListView.builder(
      controller: controller,
      itemCount: places.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final p = places[index];
        final isActive = selectedPlace?.id == p.id;
        return Card(
          color: AppColors.card,
          elevation: isActive ? 6 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(_iconForType(p.type), color: _colorForType(p.type)),

            title: Text(p.name, style: AppTextStyles.body3),
            subtitle: Text(
              "${p.distanceKm.toStringAsFixed(2)} km away",
              style: AppTextStyles.cardtext1,
            ),
            //------------------- add nevigate for direction from here --------
            // trailing: isActive
            //     ? TextButton(
            //         onPressed: () => _getRoute(p.lat, p.lon),
            //         child: Text("Navigate", style: AppTextStyles.redbutton),
            //       )
            //     : null,
            // onTap: () => setState(() => selectedPlace = p),
          ),
        );
      },
    );
  }
}

class HelpPopup extends StatelessWidget {
  const HelpPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              "How to Use the Map",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 15),

            // Help content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📍 Your Location:", style: AppTextStyles.subHeading),
                SizedBox(height: 4),
                Text(
                  "Shows your current GPS location on the map.",
                  style: AppTextStyles.body3,
                ),

                SizedBox(height: 12),
                Text("🔵 Nearby Places:", style: AppTextStyles.subHeading),
                SizedBox(height: 4),
                Text(
                  "Police stations, hospitals, pharmacies and fire stations will "
                  "automatically appear within 6 km.",
                  style: AppTextStyles.body3,
                ),

                SizedBox(height: 12),
                Text("🛣 Track Route:", style: AppTextStyles.subHeading),
                SizedBox(height: 4),
                Text(
                  "Tap any marker to view name, type, and route button.",
                  style: AppTextStyles.body3,
                ),
                SizedBox(height: 12),
                Text("📩 Share Location:", style: AppTextStyles.subHeading),
                SizedBox(height: 4),
                Text(
                  "Using Share location button you can share current location.",
                  style: AppTextStyles.body3,
                ),
              ],
            ),

            const SizedBox(height: 25),

            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 3, // shadow size
                  shadowColor: const Color.fromARGB(
                    201,
                    0,
                    0,
                    0,
                  ), // shadow color
                  backgroundColor: AppColors.button,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text("Close", style: AppTextStyles.button1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
