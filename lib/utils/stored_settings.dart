import 'dart:async';
import 'package:safe_return/login_page.dart';
import 'package:safe_return/utils/sos_manager.dart';
import 'package:safe_return/utils/persons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoredSettings {
  static int selectedIndex = 1;
  static final SharedPreferencesAsync _asyncPrefs = SharedPreferencesAsync();
  static bool biometricsValue = false;

  static Future<void> save({
    String? encodedPersonString,
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
    Person.encodePerson(Person.persons);
    if (encodedPersonString != null) {
      await _asyncPrefs.setString('persons', encodedPersonString);
    }
    if (selectedIndex != null) {
      await _asyncPrefs.setInt('selectedIndex', selectedIndex);
    }
    if (clickN != null) {
      await _asyncPrefs.setInt('clickN', clickN);
    }
    if (biometricsValue != null) {
      await _asyncPrefs.setBool('biometrics', biometricsValue);
    }
    if (userEmail != null) {
      await _asyncPrefs.setString('userEmail', userEmail);
    }
    if (isLoggedIn != null) {
      await _asyncPrefs.setBool('isLoggedIn', isLoggedIn);
    }
    if (newEmail != null) {
      await _asyncPrefs.setString('newEmail', newEmail);
    }
    if (newPassword != null) {
      await _asyncPrefs.setString('newPassword', newPassword);
    }
    if (firstName != null) {
      await _asyncPrefs.setString('firstName', firstName);
    }
    if (lastName != null) {
      await _asyncPrefs.setString('lastName', lastName);
    }
  }

  static Future<void> loadAll() async {
    final String storedEncodedPersonString =
        await _asyncPrefs.getString('persons') ?? "";
    Person.encodedPersonString = storedEncodedPersonString;

    Person.encodedPersonString.isNotEmpty
        ? Person.decodePerson(
            toDecode: Person.encodedPersonString, targetList: Person.persons)
        : print("this is empty: ${Person.encodedPersonString}");
    null;

    final int zSelectedIndex = await _asyncPrefs.getInt('selectedIndex') ?? 1;
    final int zClickN = await _asyncPrefs.getInt('clickN') ?? selectedIndex + 1;
    final bool zBiometricsValue =
        await _asyncPrefs.getBool('biometrics') ?? false;
    final String zUserEmail = await _asyncPrefs.getString('userEmail') ?? "";
    final bool zIsLoggedIn = await _asyncPrefs.getBool('isLoggedIn') ?? false;
    final String zNewEmail = await _asyncPrefs.getString('newEmail') ?? "";
    final String zNewPassword =
        await _asyncPrefs.getString('newPassword') ?? "";
    final String zFirstName = await _asyncPrefs.getString('firstName') ?? "";
    final String zLastName = await _asyncPrefs.getString('lastName') ?? "";

    selectedIndex = zSelectedIndex;
    SosManager.clickN = zClickN;
    biometricsValue = zBiometricsValue;
    LoginPageState().emailController.text = zUserEmail;
    LoginPageState.isLoggedIn = zIsLoggedIn;
    SignUpState().newEmailController.text = zNewEmail;
    SignUpState().newPasswordController.text = zNewPassword;
    SignUpState().firstNcontroller.text = zFirstName;
    SignUpState().lastNcontroller.text = zLastName;
  }
}
