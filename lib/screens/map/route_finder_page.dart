import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class RouteFinderPage extends StatefulWidget {
  const RouteFinderPage({super.key});

  @override
  State<RouteFinderPage> createState() => _RouteFinderPageState();
}

class _RouteFinderPageState extends State<RouteFinderPage> {
  final startController = TextEditingController();
  final endController = TextEditingController();

  final MapController mapController = MapController();

  LatLng? startPoint;
  LatLng? endPoint;
  List<Polyline> routes = [];

  bool isLoading = false;

  // ------------------------------------------------------------
  // Get coordinates from place name (Nominatim)
  // ------------------------------------------------------------
  Future<LatLng?> getCoordinates(String place) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$place&format=json&limit=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'WSA2App/1.0'},
      );

      final data = jsonDecode(response.body);
      if (data.isEmpty) return null;

      return LatLng(double.parse(data[0]["lat"]), double.parse(data[0]["lon"]));
    } catch (e) {
      print("Location error: $e");
      return null;
    }
  }

  // ------------------------------------------------------------
  // Get route using Google Directions API
  // ------------------------------------------------------------
  Future<void> fetchRoute() async {
    String start = startController.text.trim();
    String end = endController.text.trim();

    if (start.isEmpty || end.isEmpty) return;

    setState(() => isLoading = true);

    final startLatLng = await getCoordinates(start);
    final endLatLng = await getCoordinates(end);

    if (startLatLng == null || endLatLng == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid location")));
      return;
    }

    startPoint = startLatLng;
    endPoint = endLatLng;

    final apiKey = "YOUR_GOOGLE_DIRECTIONS_API_KEY";

    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/directions/json?"
      "origin=${startLatLng.latitude},${startLatLng.longitude}"
      "&destination=${endLatLng.latitude},${endLatLng.longitude}"
      "&mode=driving"
      "&key=$apiKey",
    );

    final response = await http.get(url);
    final body = jsonDecode(response.body);

    if (body["status"] != "OK") {
      print("Google API Error: ${body["status"]}");
      setState(() => isLoading = false);
      return;
    }

    final route = body["routes"][0];
    final polyline = route["overview_polyline"]["points"];

    List<LatLng> decodedPoints = decodePolyline(polyline);

    routes = [
      Polyline(points: decodedPoints, color: Colors.blue, strokeWidth: 6),
    ];

    print("Distance: ${route['legs'][0]['distance']['text']}");
    print("Duration: ${route['legs'][0]['duration']['text']}");

    setState(() => isLoading = false);

    // Move camera
    mapController.move(startLatLng, 14);
  }

  // ------------------------------------------------------------
  // Decode Google Polylines → LatLng list
  // ------------------------------------------------------------
  List<LatLng> decodePolyline(String poly) {
    List<LatLng> points = [];
    int index = 0, len = poly.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  // ------------------------------------------------------------
  // UI
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pro Route Finder"),
        backgroundColor: Colors.blueAccent,
      ),

      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildInput(startController, "Starting Point"),
                const SizedBox(height: 10),
                _buildInput(endController, "Destination Point"),
                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: fetchRoute,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 30,
                    ),
                  ),
                  child: const Text("Find Route"),
                ),
              ],
            ),
          ),

          if (isLoading) const CircularProgressIndicator(),

          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: LatLng(20.0, 75.0),
                initialZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}",
                ),

                PolylineLayer(polylines: routes),

                MarkerLayer(
                  markers: [
                    if (startPoint != null)
                      Marker(
                        point: startPoint!,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.green,
                          size: 36,
                        ),
                      ),
                    if (endPoint != null)
                      Marker(
                        point: endPoint!,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 36,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(TextEditingController c, String label) {
    return TextField(
      controller: c,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
