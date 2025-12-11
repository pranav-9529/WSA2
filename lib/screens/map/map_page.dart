// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:location/location.dart';
// import 'package:http/http.dart' as http;
// import 'package:url_launcher/url_launcher.dart';

// class NearbyPlace {
//   final String id;
//   final String name;
//   final String type; // police | hospital | pharmacy | fire_station
//   final double lat;
//   final double lon;
//   final double distanceKm;

//   NearbyPlace({
//     required this.id,
//     required this.name,
//     required this.type,
//     required this.lat,
//     required this.lon,
//     required this.distanceKm,
//   });

//   factory NearbyPlace.fromNominatim(
//     Map<String, dynamic> json,
//     String type,
//     double userLat,
//     double userLon,
//   ) {
//     final double pLat = double.tryParse(json['lat'].toString()) ?? 0.0;
//     final double pLon = double.tryParse(json['lon'].toString()) ?? 0.0;

//     return NearbyPlace(
//       id: json['osm_id']?.toString() ?? '${type}_unknown_${pLat}_$pLon',
//       name:
//           (json['display_name'] as String?)?.split(',').first.trim() ??
//           'Unknown',
//       type: type,
//       lat: pLat,
//       lon: pLon,
//       distanceKm: _haversineKm(userLat, userLon, pLat, pLon),
//     );
//   }

//   static double _haversineKm(
//     double lat1,
//     double lon1,
//     double lat2,
//     double lon2,
//   ) {
//     const double r = 6371.0; // Earth radius (km)
//     final double dLat = _deg2rad(lat2 - lat1);
//     final double dLon = _deg2rad(lon2 - lon1);

//     final double a =
//         sin(dLat / 2) * sin(dLat / 2) +
//         cos(_deg2rad(lat1)) *
//             cos(_deg2rad(lat2)) *
//             sin(dLon / 2) *
//             sin(dLon / 2);

//     final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     return r * c;
//   }

//   static double _deg2rad(double deg) => deg * (pi / 180.0);
// }

// class MapPage extends StatefulWidget {
//   final double lat;
//   final double lon;

//   const MapPage({super.key, required this.lat, required this.lon});

//   @override
//   State<MapPage> createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   final Location location = Location();
//   StreamSubscription<LocationData>? locationSub;

//   double liveLat = 0.0;
//   double liveLon = 0.0;

//   // place buckets (police / hospital / pharmacy / fire_station)
//   final Map<String, List<NearbyPlace>> byType = {
//     'police': [],
//     'hospital': [],
//     'pharmacy': [],
//     'fire_station': [],
//   };

//   String selectedType = 'police';
//   NearbyPlace? selectedPlace;

//   bool loadingPlaces = false;
//   bool locationReady = false;

//   Timer? _refreshTimer;

//   late final DraggableScrollableController _sheetController;
//   @override
//   void initState() {
//     super.initState();
//     liveLat = widget.lat;
//     liveLon = widget.lon;
//     _sheetController = DraggableScrollableController();
//     _initLocation();
//   }

//   @override
//   void dispose() {
//     locationSub?.cancel();
//     _refreshTimer?.cancel();
//     super.dispose();
//   }

//   // ------------------ LOCATION ------------------
//   Future<void> _initLocation() async {
//     bool serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await location.requestService();
//       if (!serviceEnabled) return;
//     }

//     PermissionStatus permission = await location.hasPermission();
//     if (permission == PermissionStatus.denied) {
//       permission = await location.requestPermission();
//       if (permission != PermissionStatus.granted) return;
//     }

//     location.changeSettings(accuracy: LocationAccuracy.high, interval: 1000);

//     // initial one-shot (helps when stream is slow on first frame)
//     final loc = await location.getLocation();
//     setState(() {
//       liveLat = loc.latitude ?? widget.lat;
//       liveLon = loc.longitude ?? widget.lon;
//       locationReady = true;
//     });
//     _schedulePlacesRefresh();

//     // continuous updates
//     locationSub = location.onLocationChanged.listen((data) {
//       setState(() {
//         liveLat = data.latitude ?? widget.lat;
//         liveLon = data.longitude ?? widget.lon;
//         locationReady = true;
//       });
//       _schedulePlacesRefresh();
//     });
//   }

//   void _schedulePlacesRefresh() {
//     _refreshTimer?.cancel();
//     _refreshTimer = Timer(const Duration(milliseconds: 700), () {
//       if (!mounted) return;
//       _fetchAllPlaces();
//     });
//   }

//   // ------------------ OPENSTREETMAP (NOMINATIM) ------------------
//   Future<void> _fetchAllPlaces() async {
//     if (!locationReady) return;

//     setState(() => loadingPlaces = true);

//     try {
//       final targets = {
//         'police': 'police',
//         'hospital': 'hospital',
//         'pharmacy': 'pharmacy',
//         'fire_station': 'fire_station',
//       };

//       for (final entry in targets.entries) {
//         final type = entry.key;
//         final amenity = entry.value;
//         byType[type] = await _fetchPlacesForAmenity(amenity);
//       }
//     } catch (_) {
//       // keep UI alive; in dev you can print error if needed
//     } finally {
//       if (mounted) setState(() => loadingPlaces = false);
//     }
//   }

//   Future<List<NearbyPlace>> _fetchPlacesForAmenity(String amenity) async {
//     final uri = Uri.parse(
//       'https://nominatim.openstreetmap.org/search'
//       '?format=json&limit=50&amenity=$amenity'
//       '&lat=$liveLat&lon=$liveLon',
//     );

//     final res = await http.get(
//       uri,
//       headers: {
//         'User-Agent': 'safecircle-wsa/1.0 (contact: your-email@example.com)',
//         'Accept-Language': 'en',
//       },
//     );

//     if (res.statusCode != 200) return [];

//     final List<dynamic> data = json.decode(res.body) as List<dynamic>;

//     // map + filter by 6 km
//     final places = data
//         .map(
//           (e) => NearbyPlace.fromNominatim(
//             (e as Map<String, dynamic>),
//             amenity,
//             liveLat,
//             liveLon,
//           ),
//         )
//         .where((p) => p.distanceKm <= 6.0) // keep only within 6 km
//         .toList();

//     // sort by distance
//     places.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

//     return places;
//   }

//   // ------------------ UI HELPERS ------------------
//   IconData _iconForType(String type) {
//     switch (type) {
//       case 'police':
//         return Icons.local_police;
//       case 'hospital':
//         return Icons.local_hospital;
//       case 'pharmacy':
//         return Icons.medication;
//       case 'fire_station':
//         return Icons.fire_truck;
//       default:
//         return Icons.place;
//     }
//   }

//   String _labelForType(String type) {
//     switch (type) {
//       case 'police':
//         return 'Police Station';
//       case 'hospital':
//         return 'Hospital';
//       case 'pharmacy':
//         return 'Medical / Pharmacy';
//       case 'fire_station':
//         return 'Fire Station';
//       default:
//         return 'Help';
//     }
//   }

//   Future<void> _openInMaps(NearbyPlace p) async {
//     final uri = Uri.parse(
//       'https://www.google.com/maps/search/?api=1&query=${p.lat},${p.lon}',
//     );
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     }
//   }

//   // ------------------ BUILD ------------------
//   @override
//   Widget build(BuildContext context) {
//     final places = byType[selectedType] ?? [];

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         title: const Text(
//           'Map Location',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//       body: Stack(
//         children: [
//           FlutterMap(
//             options: MapOptions(
//               initialCenter: LatLng(widget.lat, widget.lon),
//               initialZoom: 15,
//               interactionOptions: const InteractionOptions(
//                 flags: InteractiveFlag.all,
//               ),
//               keepAlive: true,
//             ),
//             children: [
//               // UNOFFICIAL GOOGLE TILES (no key required)
//               TileLayer(
//                 urlTemplate:
//                     "https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}",
//                 userAgentPackageName: "com.example.safecircle",
//               ),

//               // live user marker
//               MarkerLayer(
//                 markers: [
//                   Marker(
//                     point: LatLng(liveLat, liveLon),
//                     width: 46,
//                     height: 46,
//                     child: const Icon(
//                       Icons.my_location,
//                       color: Colors.blue,
//                       size: 42,
//                     ),
//                   ),
//                 ],
//               ),

//               // nearby places markers (current tab)
//               MarkerLayer(
//                 markers: places.map((p) {
//                   return Marker(
//                     point: LatLng(p.lat, p.lon),
//                     width: 42,
//                     height: 42,
//                     child: InkWell(
//                       onTap: () {
//                         setState(() {
//                           selectedPlace = p;
//                         });
//                       },
//                       child: Icon(
//                         _iconForType(p.type),
//                         color: Colors.deepOrange,
//                         size: 34,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ],
//           ),

//           // big fancy swipeable bottom sheet (always visible)
//           DraggableScrollableSheet(
//             controller: _sheetController,
//             initialChildSize: 0.18,
//             minChildSize: 0.12,
//             maxChildSize: 0.68,
//             builder: (context, controller) {
//               return Container(
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
//                   boxShadow: [
//                     BoxShadow(
//                       blurRadius: 14,
//                       offset: Offset(0, -4),
//                       color: Colors.black26,
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   children: [
//                     // handle + title
//                     Padding(
//                       padding: const EdgeInsets.only(top: 10, bottom: 6),
//                       child: Column(
//                         children: [
//                           Container(
//                             width: 46,
//                             height: 5,
//                             decoration: BoxDecoration(
//                               color: Colors.black26,
//                               borderRadius: BorderRadius.circular(99),
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           Text(
//                             'Emergency Nearby (tap a marker)',
//                             style: Theme.of(context).textTheme.titleMedium
//                                 ?.copyWith(fontWeight: FontWeight.w700),
//                           ),
//                           const SizedBox(height: 6),
//                         ],
//                       ),
//                     ),

//                     // type tabs
//                     SizedBox(
//                       height: 42,
//                       child: ListView(
//                         controller: controller,
//                         scrollDirection: Axis.horizontal,
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         children: [
//                           for (final type in [
//                             'police',
//                             'hospital',
//                             'pharmacy',
//                             'fire_station',
//                           ])
//                             Padding(
//                               padding: const EdgeInsets.only(right: 10),
//                               child: ChoiceChip(
//                                 label: Text(_labelForType(type)),
//                                 selected: selectedType == type,
//                                 onSelected: (_) {
//                                   setState(() => selectedType = type);
//                                 },
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 6),

//                     // content
//                     Expanded(
//                       child: controller.hasClients
//                           ? _buildPlaceList(controller, places)
//                           : _buildPlaceList(ScrollController(), places),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPlaceList(
//     ScrollController controller,
//     List<NearbyPlace> places,
//   ) {
//     if (loadingPlaces) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (places.isEmpty) {
//       return const Center(
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Text(
//             "No nearby places found right now.\n(If you're indoors or GPS is weak, try moving a bit.)",
//             textAlign: TextAlign.center,
//           ),
//         ),
//       );
//     }

//     return ListView.builder(
//       controller: controller,
//       itemCount: places.length,
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       itemBuilder: (context, i) {
//         final p = places[i];
//         final isActive = selectedPlace?.id == p.id;

//         return Card(
//           margin: const EdgeInsets.symmetric(vertical: 6),
//           elevation: isActive ? 6 : 2,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//           child: InkWell(
//             borderRadius: BorderRadius.circular(14),
//             onTap: () => setState(() => selectedPlace = p),
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     backgroundColor: Colors.black,
//                     child: Icon(_iconForType(p.type), color: Colors.white),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           p.name,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w800,
//                             fontSize: 14,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           "${p.distanceKm.toStringAsFixed(2)} km away",
//                           style: TextStyle(color: Colors.grey[700]),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   if (isActive)
//                     TextButton(
//                       onPressed: () => _openInMaps(p),
//                       child: const Text("Navigate"),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
