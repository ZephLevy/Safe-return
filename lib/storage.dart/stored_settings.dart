import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

class StoredSettings {
  static final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  static bool biometricsValue = false;

  static Future<void> save({
    bool? biometricsValue,
  }) async {
    if (biometricsValue != null) {
      await asyncPrefs.setBool('biometrics', biometricsValue);
    }
  }

  static Future<void> load() async {
    biometricsValue = await asyncPrefs.getBool('biometrics') ?? false;
  }

  static Future<void> logOut() async {
    await asyncPrefs.clear();
    biometricsValue = false;
  }
}
