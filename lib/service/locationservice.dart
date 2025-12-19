import 'package:location/location.dart';

class LocationService {
  static Future<LocationData?> getCurrentLocation() async {
    try {
      final Location location = Location();

      // ✅ Ensure service is enabled
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return null;
      }

      // ✅ Ensure permission is granted
      PermissionStatus permission = await location.hasPermission();
      if (permission == PermissionStatus.denied) {
        permission = await location.requestPermission();
        if (permission != PermissionStatus.granted) return null;
      }

      // ✅ Force high accuracy
      await location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 1000,
        distanceFilter: 5,
      );

      // ✅ Timeout protection (IMPORTANT)
      return await location.getLocation().timeout(const Duration(seconds: 10));
    } catch (e) {
      print("Location error: $e");
      return null;
    }
  }
}
