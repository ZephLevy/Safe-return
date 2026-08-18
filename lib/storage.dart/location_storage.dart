import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:safe_return/pages/main_pages/map_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationStorage {
  static final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  static Future<void> save({LatLng? homePosition}) async {
    if (homePosition != null) {
      asyncPrefs.setDouble('homeLng', homePosition.longitude);
      asyncPrefs.setDouble('homeLat', homePosition.latitude);
    }
  }

  static Future<void> load() async {
    var homeLng = await asyncPrefs.getDouble('homeLng');
    var homeLat = await asyncPrefs.getDouble('homeLat');
    if (homeLat != null && homeLng != null) {
      MapsPageState.homePosition = LatLng(homeLat, homeLng);
    }
  }

  static Future<void> logOut() async {
    await asyncPrefs.clear();
  }
}
