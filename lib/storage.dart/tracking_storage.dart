import 'dart:async';

import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:safe_return/logic/location_logic/location_updater.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackingStorage {
  static final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  static Future<void> save({
    bool? powerSaving,
    LocationAccuracy? locationAccuracy,
  }) async {
    if (powerSaving != null) {
      await asyncPrefs.setBool('powerSaving', powerSaving);
    }
    // if (locationAccuracy != null) {
    //   await asyncPrefs.setString(
    //       'locationAccuracy', jsonEncode(locationAccuracy));
    // }
  }

  static Future<void> load() async {
    LocationUpdaterState.powerSaving =
        await asyncPrefs.getBool('powerSaving') ?? false;
    // LocationUpdaterState.locationAccuracy = jsonDecode(
    //     await asyncPrefs.getString('locationAccuracy') ??
    //         jsonEncode(LocationAccuracy.BALANCED));
  }

  static Future<void> logOut() async {
    await asyncPrefs.clear();

    LocationUpdaterState.powerSaving = false;
  }
}
