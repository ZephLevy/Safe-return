import 'dart:async';
import 'package:safe_return/login_page.dart';
import 'package:safe_return/pages/home_page.dart';
import 'package:safe_return/utils/sos_manager.dart';
import 'package:safe_return/utils/persons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoredSettings {
  static int selectedIndex = 1;
  static final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  static bool biometricsValue = false;

  static Future<void> save({
    List<Person>? personList,
    int? selectedIndex,
    int? clickN,
    bool? biometricsValue,
    String? userEmail,
    bool? isLoggedIn,
    String? firstName,
    String? lastName,
    bool? showTimer,
  }) async {
    if (personList != null) {
      Person.encodePerson(personList);
    }
    await asyncPrefs.setString('persons', Person.encodedPersonString);
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
    if (showTimer != null) {
      await asyncPrefs.setBool('showTimer', showTimer);
    }
  }

  static Future<void> loadAll() async {
    final String zEncodedPersonString =
        await asyncPrefs.getString('persons') ?? "";
    Person.encodedPersonString = zEncodedPersonString;

    Person.encodedPersonString.isNotEmpty
        ? Person.decodePerson(
            toDecode: Person.encodedPersonString, targetList: Person.persons)
        : null;

    final int zSelectedIndex = await asyncPrefs.getInt('selectedIndex') ?? 1;
    final int zClickN = await asyncPrefs.getInt('clickN') ?? selectedIndex + 1;
    final bool zBiometricsValue =
        await asyncPrefs.getBool('biometrics') ?? false;
    final String zUserEmail = await asyncPrefs.getString('userEmail') ?? "";
    final bool zIsLoggedIn = await asyncPrefs.getBool('isLoggedIn') ?? false;
    final String zFirstName = await asyncPrefs.getString('firstName') ?? "";
    final String zLastName = await asyncPrefs.getString('lastName') ?? "";
    final bool zShowTimer = await asyncPrefs.getBool('showTimer') ?? false;

    selectedIndex = zSelectedIndex;
    SosManager.clickN = zClickN;
    biometricsValue = zBiometricsValue;
    LoginPageState.email = zUserEmail;
    LoginPageState.isLoggedIn = zIsLoggedIn;
    SignUpState.firstName = zFirstName;
    SignUpState.lastName = zLastName;
    TimerAndClockState.showTimer = zShowTimer;
  }

  static Future<void> logOut() async {
    await asyncPrefs.clear();
    SosManager.fakeCode = "";
    SosManager.secretCode = "";
    Person.encodedPersonString = "";
    selectedIndex = 1;
    SosManager.clickN = selectedIndex + 1;
    biometricsValue = false;
    LoginPageState.email = "";
    LoginPageState.password = "";
    LoginPageState.isLoggedIn = false;
    SignUpState.newEmail = "";
    SignUpState.newPassword = ""; //TODO not sure to keep this, just for safety
    SignUpState.firstName = "";
    SignUpState.lastName = "";
    TimerAndClockState.showTimer = false;
  }
}
