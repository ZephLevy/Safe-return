import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class GetLocation {
  static LatLng? homePosition;

  static Future<Position> determinePosition() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled return an error message
      return Future.error('Location services are disabled.');
    }

    // If permissions are granted, return the current location
    if (await checkLocationPermissions()) {
      return await Geolocator.getCurrentPosition();
    }
    return Future.error("An error occured, couldn't get location.");
  }

  static Future<bool> checkLocationPermissions() async {
    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();

    // print(permission);

    if (permission != LocationPermission.always) {
      LocationPermission permission = await Geolocator.requestPermission();
      print("requestedPermission: $permission");

      if (permission != LocationPermission.always) {
        return false;
      }
    }
    return true;
  }
}
