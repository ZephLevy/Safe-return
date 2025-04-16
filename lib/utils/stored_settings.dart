import 'dart:async';
import 'package:safe_return/utils/sos_manager.dart';
import 'package:safe_return/pages/Settings/Emergency%20contacts/persons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoredSettings {
  static int selectedIndex = 1;
  static final SharedPreferencesAsync _asyncPrefs = SharedPreferencesAsync();
  static bool biometricsValue = false;

  static Future<void> saveAll() async {
    Person.encodePerson(Person.persons);
    await _asyncPrefs.setString('persons', Person.encodedPersonString);
    await _asyncPrefs.setInt('selectedIndex', selectedIndex);
    await _asyncPrefs.setInt('clickN', SosManager.clickN);
    await _asyncPrefs.setBool('biometrics', biometricsValue);
  }

  static Future<void> loadAll() async {
    // print("String load: ${Person.encodedPersonString}");
    final String storedEncodedPersonString =
        await _asyncPrefs.getString('persons') ?? "";
    Person.encodedPersonString = storedEncodedPersonString;

    Person.encodedPersonString.isNotEmpty
        ? Person.decodePerson(
            toDecode: Person.encodedPersonString, targetList: Person.persons)
        : print("this is empty: ${Person.encodedPersonString}");

    final int storedSelectedIndex =
        await _asyncPrefs.getInt('selectedIndex') ?? 1;
    final int storedClickN =
        await _asyncPrefs.getInt('clickN') ?? selectedIndex + 1;

    final bool storedBiometricsValue =
        await _asyncPrefs.getBool('biometrics') ?? false;

    selectedIndex = storedSelectedIndex;
    SosManager.clickN = storedClickN;
    biometricsValue = storedBiometricsValue;
  }
}
