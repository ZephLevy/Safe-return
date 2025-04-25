import 'dart:async';
import 'package:safe_return/utils/noti_service.dart';
import 'package:safe_return/utils/sos_manager.dart';
import 'package:safe_return/utils/persons.dart';
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
    await _asyncPrefs.setInt(
        'okVerificationStep', NotiService.okVerificationStep ?? 1);
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
    final int storedOkVerificationStep =
        await _asyncPrefs.getInt('okVerificationStep') ?? 1;

    selectedIndex = storedSelectedIndex;
    SosManager.clickN = storedClickN;
    biometricsValue = storedBiometricsValue;
  }
}
