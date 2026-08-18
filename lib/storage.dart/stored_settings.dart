import 'dart:async';

import 'package:safe_return/logic/location_logic/location_updater.dart';
import 'package:safe_return/logic/persons_logic.dart';
import 'package:safe_return/logic/sos_logic.dart';
import 'package:safe_return/logic/timer_logic.dart';
import 'package:safe_return/pages/log_sign_up/login_page.dart';
import 'package:safe_return/pages/log_sign_up/sign_up_page.dart';
import 'package:safe_return/pages/main_pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';

class StoredSettings {
  static int selectedIndex = 1;
  static final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  static bool biometricsValue = false;

  static Future<void> save({
    int? selectedIndex,
    int? clickN,
    bool? biometricsValue,
    String? userEmail,
    bool? isLoggedIn,
    String? firstName,
    String? lastName,
    bool? showTimer,
    bool? powerSaving,
  }) async {
    if (selectedIndex != null) {
      await asyncPrefs.setInt('selectedIndex', selectedIndex);
    }
    if (clickN != null) {
      await asyncPrefs.setInt('clickN', clickN);
    }
    if (biometricsValue != null) {
      await asyncPrefs.setBool('biometrics', biometricsValue);
    }
    if (userEmail != null) {
      await asyncPrefs.setString('userEmail', userEmail);
    }
    if (isLoggedIn != null) {
      await asyncPrefs.setBool('isLoggedIn', isLoggedIn);
    }
    if (firstName != null) {
      await asyncPrefs.setString('firstName', firstName);
    }
    if (lastName != null) {
      await asyncPrefs.setString('lastName', lastName);
    }
    if (powerSaving != null) {
      await asyncPrefs.setBool('powerSaving', powerSaving);
    }
  }

  static Future<void> loadAll() async {
    selectedIndex = await asyncPrefs.getInt('selectedIndex') ?? 1;

    SosLogic.clickN = await asyncPrefs.getInt('clickN') ?? selectedIndex + 1;
    biometricsValue = await asyncPrefs.getBool('biometrics') ?? false;
    LoginPageState.userEmail = await asyncPrefs.getString('userEmail') ?? "";
    LoginPageState.isLoggedIn = await asyncPrefs.getBool('isLoggedIn') ?? false;
    SignUpState.firstName = await asyncPrefs.getString('firstName') ?? "";
    SignUpState.lastName = await asyncPrefs.getString('lastName') ?? "";
    LocationUpdaterState.powerSaving =
        await asyncPrefs.getBool('powerSaving') ?? false;
  }

  static Future<void> logOut() async {
    await asyncPrefs.clear();
    SosLogic.fakeCode = null;
    SosLogic.realCode = null;
    PersonLogic.persons = [];
    selectedIndex = 1;
    SosLogic.clickN = selectedIndex + 1;
    biometricsValue = false;
    LocationUpdaterState.powerSaving = false;

    LoginPageState.userEmail = "";
    LoginPageState.isLoggedIn = false;
    SignUpState.firstName = "";
    SignUpState.lastName = "";

    TimerAndClockState.showTimer = false;
    TimerLogic.isTomorrow = false;
    TimerLogic.selectedTime = DateTime.now();
    TimerLogic.timeOfTap = null;
  }
}
