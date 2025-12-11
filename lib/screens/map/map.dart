// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:location/location.dart';
// import 'package:safecircle/screens/map/reportedAreas.dart';
// //import 'package:safecircle/services/colors.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// // ------------------------ MODEL ------------------------
// class ReportedArea {
//   final double lat;
//   final double lon;
//   final String color;
//   final String name;

//   ReportedArea({
//     required this.lat,
//     required this.lon,
//     required this.color,
//     required this.name,
//   });

//   factory ReportedArea.fromJson(Map<String, dynamic> json) {
//     return ReportedArea(
//       lat: json['lat'],
//       lon: json['lon'],
//       color: json['color'],
//       name: json['name'],
//     );
//   }
// }

// // ------------------------ MAIN METHOD ------------------------
// void main() {
//   runApp(
//     MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: MapPage(lat: 20.0, lon: 75.0), // default for debugging
//     ),
//   );
// }

// // ------------------------ MAP PAGE ------------------------
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

//   List<ReportedArea> reportedAreas = [];

//   bool isDayTime(DateTime now) => now.hour >= 6 && now.hour < 18;

//   @override
//   void initState() {
//     super.initState();
//     liveLat = widget.lat;
//     liveLon = widget.lon;
//     initLocation();
//     fetchReportedAreas();
//   }

//   // ------------------- LIVE LOCATION -------------------
//   Future<void> initLocation() async {
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

//     locationSub = location.onLocationChanged.listen((data) {
//       setState(() {
//         liveLat = data.latitude ?? widget.lat;
//         liveLon = data.longitude ?? widget.lon;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     locationSub?.cancel();
//     super.dispose();
//   }

//   // ------------------- FETCH REPORTED AREAS -------------------
//   Future<void> fetchReportedAreas() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://your-api.com/reported-areas'),
//       );
//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         setState(() {
//           reportedAreas = data.map((e) => ReportedArea.fromJson(e)).toList();
//         });
//       } else {
//         print("Failed to fetch areas: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error fetching areas: $e");
//     }
//   }

//   // ------------------- UI -------------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         foregroundColor: Colors.white,
//         backgroundColor: Colors.black,
//         title: const Text(
//           'Map Location',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),

//       // ---------- MAP ----------
//       body: FlutterMap(
//         options: MapOptions(
//           initialCenter: LatLng(widget.lat, widget.lon),
//           initialZoom: 15,
//           interactionOptions: const InteractionOptions(
//             flags: InteractiveFlag.all,
//           ),
//         ),
//         children: [
//           TileLayer(
//             urlTemplate: "https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}",
//             userAgentPackageName: 'com.example.safecircle',
//           ),

//           // Live user location
//           MarkerLayer(
//             markers: [
//               Marker(
//                 point: LatLng(liveLat, liveLon),
//                 width: 50,
//                 height: 50,
//                 child: const Icon(
//                   Icons.location_on,
//                   color: Colors.blue,
//                   size: 45,
//                 ),
//               ),
//             ],
//           ),

//           // Reported dangerous/safe areas
//           CircleLayer(
//             circles: reportedAreas.map((area) {
//               Color circleColor;
//               switch (area.color) {
//                 case "red":
//                   circleColor = Colors.red.withOpacity(0.3);
//                   break;
//                 case "green":
//                   circleColor = Colors.green.withOpacity(0.3);
//                   break;
//                 default:
//                   circleColor = Colors.blue.withOpacity(0.3);
//               }
//               return CircleMarker(
//                 point: LatLng(area.lat, area.lon),
//                 color: circleColor,
//                 borderStrokeWidth: 2,
//                 borderColor: circleColor,
//                 radius: 500,
//               );
//             }).toList(),
//           ),
//         ],
//       ),

//       // ---------- REPORT AREA BUTTON ----------
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.red,
//         child: const Icon(Icons.warning, color: Colors.white),
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const ReportAreaPage()),
//           );
//         },
//       ),
//     );
//   }
// }
