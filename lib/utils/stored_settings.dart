import 'dart:async';
import 'package:safe_return/login_page.dart';
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
    String? newEmail,
    String? newPassword,
    String? firstName,
    String? lastName,
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
    if (newEmail != null) {
      await asyncPrefs.setString('newEmail', newEmail);
    }
    if (newPassword != null) {
      await asyncPrefs.setString('newPassword', newPassword);
    }
    if (firstName != null) {
      await asyncPrefs.setString('firstName', firstName);
    }
    if (lastName != null) {
      await asyncPrefs.setString('lastName', lastName);
    }
  }

  static Future<void> loadAll() async {
    final String storedEncodedPersonString =
        await asyncPrefs.getString('persons') ?? "";
    Person.encodedPersonString = storedEncodedPersonString;

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
    final String zNewEmail = await asyncPrefs.getString('newEmail') ?? "";
    final String zNewPassword = await asyncPrefs.getString('newPassword') ?? "";
    final String zFirstName = await asyncPrefs.getString('firstName') ?? "";
    final String zLastName = await asyncPrefs.getString('lastName') ?? "";

    selectedIndex = zSelectedIndex;
    SosManager.clickN = zClickN;
    biometricsValue = zBiometricsValue;
    LoginPageState.email = zUserEmail;
    LoginPageState.isLoggedIn = zIsLoggedIn;
    SignUpState.newEmail = zNewEmail;
    SignUpState.newPassword = zNewPassword;
    SignUpState.firstName = zFirstName;
    SignUpState.lastName = zLastName;
  }

  static Future<void> logOut() async {
    await asyncPrefs.clear();
    Person.encodedPersonString = "";
    selectedIndex = 1;
    SosManager.clickN = selectedIndex + 1;
    biometricsValue = false;
    LoginPageState.email = "";
    LoginPageState.password = "";
    LoginPageState.isLoggedIn = false;
    SignUpState.newEmail = "";
    SignUpState.newPassword = "";
    SignUpState.firstName = "";
    SignUpState.lastName = "";
  }
}
