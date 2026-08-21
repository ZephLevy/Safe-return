import 'dart:convert';

import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPathStorage {
  // Save
  static Future<void> save(List<LatLng> userPath) async {
    final asyncPrefs = SharedPreferencesAsync();

    // Convert LatLng objects to Map
    List<Map<String, double>> locationMaps = userPath
        .map((loc) => {'latitude': loc.latitude, 'longitude': loc.longitude})
        .toList();
    // print("locationMaps: $locationMaps");

    // Encode list of maps to JSON
    String jsonString = jsonEncode(locationMaps);

    // print("jsonString: $jsonString");
    await asyncPrefs.setString('path', jsonString);
  }

  // Load
  static Future<List<LatLng>> load() async {
    // print("just loaded: $userPath");

    final asyncPrefs = SharedPreferencesAsync();

    String jsonString = await asyncPrefs.getString('path') ?? "";

    if (jsonString.isNotEmpty) {
      List<dynamic> locationMaps = jsonDecode(jsonString);

      return locationMaps
          .map((map) => LatLng(map['latitude'], map['longitude']))
          .toList();
    }
    return [];
    // print("final result: ${userPathNotifier.value}");
  }
}
