import 'dart:convert';
import 'package:http/http.dart' as http;

class NearbyService {
  static Future<List<String>> fetchNearby({
    required double lat,
    required double lon,
    required String type,
  }) async {
    final query =
        '''
[out:json][timeout:25];
node(around:10000,$lat,$lon)["amenity"="$type"];
out;
''';

    try {
      final response = await http
          .post(
            Uri.parse("https://overpass-api.de/api/interpreter"),
            body: {"data": query},
          )
          .timeout(const Duration(seconds: 30));

      // 🔴 IMPORTANT
      if (response.statusCode != 200) {
        print("Overpass error: ${response.statusCode}");
        return [];
      }

      final data = jsonDecode(response.body);

      if (data["elements"] == null) return [];

      return List<String>.from(
        (data["elements"] as List).map(
          (e) => e["tags"]?["name"]?.toString() ?? "Unnamed $type",
        ),
      );
    } catch (e) {
      print("Nearby fetch error ($type): $e");
      return [];
    }
  }
}
