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

    final int storedSelectedIndex =
        await _asyncPrefs.getInt('selectedIndex') ?? 1;
    final int storedClickN =
        await _asyncPrefs.getInt('clickN') ?? selectedIndex + 1;
    final bool storedBiometricsValue =
        await _asyncPrefs.getBool('biometrics') ?? false;
    final String storedUserEmail =
        await _asyncPrefs.getString('userEmail') ?? "";
    final bool storedIsLoggedIn =
        await _asyncPrefs.getBool('isLoggedIn') ?? false;

    selectedIndex = storedSelectedIndex;
    SosManager.clickN = storedClickN;
    biometricsValue = storedBiometricsValue;
    LoginPageState().emailController.text = storedUserEmail;
    LoginPageState.isLoggedIn = storedIsLoggedIn;
  }
}
