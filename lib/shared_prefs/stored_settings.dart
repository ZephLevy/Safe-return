import 'dart:async';
import 'package:safe_return/login_page.dart';
import 'package:safe_return/pages/home_page.dart';
import 'package:safe_return/utils/sos_manager.dart';
import 'package:safe_return/utils/persons.dart';
import 'package:safe_return/utils/time_manager.dart';
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
  }

  static Future<void> loadAll() async {
    final String zEncodedPersonString =
        await asyncPrefs.getString('persons') ?? "";
    Person.encodedPersonString = zEncodedPersonString;

    Person.encodedPersonString.isNotEmpty
        ? Person.decodePerson(
            toDecode: Person.encodedPersonString, targetList: Person.persons)
        : null;

    // final int zSelectedIndex = await asyncPrefs.getInt('selectedIndex') ?? 1;
    selectedIndex = await asyncPrefs.getInt('selectedIndex') ?? 1;

    SosManager.clickN = await asyncPrefs.getInt('clickN') ?? selectedIndex + 1;
    biometricsValue = await asyncPrefs.getBool('biometrics') ?? false;
    LoginPageState.email = await asyncPrefs.getString('userEmail') ?? "";
    LoginPageState.isLoggedIn = await asyncPrefs.getBool('isLoggedIn') ?? false;
    SignUpState.firstName = await asyncPrefs.getString('firstName') ?? "";
    SignUpState.lastName = await asyncPrefs.getString('lastName') ?? "";
  }

  static Future<void> logOut() async {
    await asyncPrefs.clear();
    SosManager.fakeCode = null;
    SosManager.secretCode = null;
    Person.encodedPersonString = "";
    Person.persons = [];
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
    TimeSetterState.isTomorrow = false;
    TimeManager.selectedTime = null;
    TimeManager.timeOfTap = null;
  }
}
