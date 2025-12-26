import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:wsa2/Theme/colors.dart';
import 'package:wsa2/screens/main_bottom_nav.dart';

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

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  final Location location = Location();
  StreamSubscription<LocationData>? locationSub;

  final MapController mapController = MapController();

  late final AnimationController _pulseController;

  List<LatLng> routePoints = [];

  double liveLat = 19.8658; // Jalna fallback
  double liveLon = 75.8872;
  bool locationReady = false;
  bool loadingPlaces = false;

  bool _isMounted = true;

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

    // IMPORTANT: initialize controller BEFORE anything that can trigger build
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _initLocation();
  }

  @override
  void dispose() {
    _isMounted = false;
    _pulseController.dispose();
    locationSub?.cancel();
    _placesTimer?.cancel();
    super.dispose();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        if (_isMounted) {
          setState(() => locationReady = true);
        }
        return;
      }
    }

    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) {
        if (_isMounted) {
          setState(() => locationReady = true);
        }
        return;
      }
    }

    location.changeSettings(accuracy: LocationAccuracy.high, interval: 2000);

    final loc = await location.getLocation();
    if (_isMounted) {
      setState(() {
        liveLat = loc.latitude ?? liveLat;
        liveLon = loc.longitude ?? liveLon;
        locationReady = true;
      });
    }

    _fetchAllPlaces();

    locationSub = location.onLocationChanged.listen((locData) {
      if (!_isMounted) return;
      setState(() {
        liveLat = locData.latitude ?? liveLat;
        liveLon = locData.longitude ?? liveLon;
      });
      _schedulePlacesFetch();
    });
  }

  void _schedulePlacesFetch() {
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
    _placesTimer = Timer(const Duration(seconds: 2), () {
      if (_isMounted) _fetchAllPlaces();
    });
  }

  Future<void> _fetchAllPlaces() async {
    if (!_isMounted) return;

    setState(() => loadingPlaces = true);

    final types = ['hospital', 'police', 'pharmacy', 'fire_station'];
    for (final type in types) {
      byType[type] = await _fetchNearby(type);
    }

    if (_isMounted) {
      setState(() => loadingPlaces = false);
    }
  }

  Future<List<NearbyPlace>> _fetchNearby(String type) async {
    String query = '';

    switch (type) {
      case 'hospital':
      case 'police':
      case 'fire_station':
        query = 'node["amenity"="$type"](around:6000,$liveLat,$liveLon);';
        break;
      case 'pharmacy':
        query =
            '''
    (
      node["amenity"="pharmacy"](around:6000,$liveLat,$liveLon);
      node["shop"="chemist"](around:6000,$liveLat,$liveLon);
      node["amenity"="doctors"](around:6000,$liveLat,$liveLon);
      node["healthcare"="pharmacy"](around:6000,$liveLat,$liveLon);
      node["amenity"="pharmacy"](around:6000,$liveLat,$liveLon);
      
    );
  ''';
        break;
    }

    if (query.isEmpty) return [];

    final url = Uri.parse(
      'https://overpass-api.de/api/interpreter?data=[out:json];$query out;',
    );

    try {
      final res = await http.get(url).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return [];

      final data = json.decode(res.body);
      final List elements = data['elements'] ?? [];

      final places = elements
          .map<NearbyPlace>((e) {
            final double lat = (e['lat'] ?? 0.0).toDouble();
            final double lon = (e['lon'] ?? 0.0).toDouble();
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
          .where((p) => p.lat != 0.0 && p.lon != 0.0 && p.distanceKm <= 6.0)
          .toList();

      places.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      return places;
    } catch (e) {
      print('Overpass error: $e');
      return [];
    }
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
        return const Color(0xFFE53935);
      case 'police':
        return const Color(0xFF1E88E5);
      case 'pharmacy':
        return const Color(0xFF43A047);
      case 'fire_station':
        return const Color(0xFFFF8F00);
      default:
        return Colors.grey;
    }
  }

  Future<void> _getRoute(double destLat, double destLon) async {
    try {
      final currentLoc = await location.getLocation();
      final startLat = currentLoc.latitude ?? liveLat;
      final startLon = currentLoc.longitude ?? liveLon;

      final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/'
        '$startLon,$startLat;$destLon,$destLat?overview=full&geometries=geojson',
      );

      final res = await http.get(url).timeout(const Duration(seconds: 10));
      if (!_isMounted) return;

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final coords =
            (data['routes']?[0]?['geometry']?['coordinates'] ?? []) as List;

        if (coords.isEmpty) return;

        setState(() {
          routePoints = coords
              .map<LatLng>(
                (c) =>
                    LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
              )
              .toList();
        });
      } else {
        print('ROUTE API ERROR: ${res.statusCode}');
      }
    } catch (e) {
      print('Route error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!locationReady) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.loder,
                strokeWidth: 4,
                strokeCap: StrokeCap.round,
              ),
              const SizedBox(height: 16),
              Text("Getting your location...", style: AppTextStyles.body3),
            ],
          ),
        ),
      );
    }

    final places = byType[selectedType] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Live Location", style: AppTextStyles.heading),
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng(liveLat, liveLon),
              initialZoom: 15,
              minZoom: 3,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                userAgentPackageName: 'com.example.app',
              ),
              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 6,
                      color: Colors.blue.withOpacity(0.8),
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // pulsing current location marker LatLng(liveLat, liveLon)
                  Marker(
                    point: LatLng(liveLat, liveLon),
                    width: 120,
                    height: 120,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 120,
                          height: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pulsing outer circle (Google Maps style)
                              Container(
                                width: 80 + (20 * _pulseController.value),
                                height: 80 + (20 * _pulseController.value),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.blue.withOpacity(
                                        0.6 * _pulseController.value,
                                      ),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(
                                        0.4 * _pulseController.value,
                                      ),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              // Inner pulse ring
                              Container(
                                width: 60 + (10 * (1 - _pulseController.value)),
                                height:
                                    60 + (10 * (1 - _pulseController.value)),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.blue.withOpacity(0.8),
                                    width: 3,
                                  ),
                                ),
                              ),
                              // Main location icon
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade500,
                                      Colors.blue.shade700,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // nearby places markers
                  ...places.map(
                    (p) => Marker(
                      point: LatLng(p.lat, p.lon),
                      width: 45,
                      height: 45,
                      child: GestureDetector(
                        onTap: () => _getRoute(p.lat, p.lon),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _colorForType(p.type).withOpacity(0.2),
                                _colorForType(p.type),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _colorForType(p.type).withOpacity(0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            _iconForType(p.type),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // draggable bottom sheet with list
          Positioned.fill(
            bottom: 0,
            child: DraggableScrollableSheet(
              initialChildSize: 0.32,
              minChildSize: 0.28,
              maxChildSize: 0.6,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 14,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
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
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              Container(
                                height: 36,
                                width: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.button,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(Icons.map),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Nearest Safety Stations",
                                  style: AppTextStyles.body3,
                                ),
                              ),
                              Container(
                                height: 36,
                                width: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.button,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(Icons.arrow_downward_rounded),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: SizedBox(
                          height: 42,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children:
                                [
                                      'hospital',
                                      'police',
                                      'pharmacy',
                                      'fire_station',
                                    ]
                                    .map(
                                      (type) => Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8,
                                        ),
                                        child: ChoiceChip(
                                          label: Text(type.toUpperCase()),
                                          selected: selectedType == type,
                                          onSelected: (_) {
                                            setState(() => selectedType = type);
                                          },
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _buildPlaceList(scrollController, places),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // floating location & help buttons
          Positioned(
            top: 20,
            right: 20,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'loc',
                  backgroundColor: AppColors.button,
                  onPressed: () async {
                    final loc = await location.getLocation();
                    if (!_isMounted) return;
                    if (loc.latitude != null && loc.longitude != null) {
                      setState(() {
                        liveLat = loc.latitude!;
                        liveLon = loc.longitude!;
                      });
                      mapController.move(LatLng(liveLat, liveLon), 16);
                    }
                  },
                  child: const Icon(Icons.my_location, color: Colors.black),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'help',
                  mini: true,
                  backgroundColor: AppColors.button,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const HelpPopup(),
                    );
                  },
                  child: const Icon(Icons.help_outline, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: const WSABottomBar(currentIndex: 4),
    );
  }

  Widget _buildPlaceList(
    ScrollController controller,
    List<NearbyPlace> places,
  ) {
    if (loadingPlaces) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.loder,
          strokeWidth: 4,
          strokeCap: StrokeCap.round,
        ),
      );
    }

    if (places.isEmpty) {
      return Center(
        child: Text(
          "No nearby ${selectedType}s within 6 km",
          style: AppTextStyles.body1,
        ),
      );
    }

    return ListView.builder(
      controller: controller,
      itemCount: places.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final p = places[index];
        return Card(
          color: AppColors.card,
          elevation: 4,
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
            trailing: IconButton(
              icon: const Icon(Icons.navigation, color: Colors.blue),
              onPressed: () => _getRoute(p.lat, p.lon),
            ),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "How to Use the Map",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📍 Your Location:"),
                  SizedBox(height: 4),
                  Text("Blue pulsing dot shows your current GPS location."),
                  SizedBox(height: 12),
                  Text("🛡 Nearby Places:"),
                  SizedBox(height: 4),
                  Text(
                    "Hospitals, police, pharmacies, and fire stations appear within 6 km.",
                  ),
                  SizedBox(height: 12),
                  Text("🛣 Routes:"),
                  SizedBox(height: 4),
                  Text(
                    "Tap any marker or navigation icon to draw a blue route.",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.button,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
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
