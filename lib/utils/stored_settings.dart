import 'dart:async';
import 'package:safe_return/utils/sos_manager.dart';
import 'package:safe_return/utils/contacts/persons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoredSettings {
  static String? dvalue; //todo remove this
  static int selectedIndex = 1;
  static final SharedPreferencesAsync _asyncPrefs = SharedPreferencesAsync();

  static Future<void> saveAll() async {
    Person.encodePerson();
    await _asyncPrefs.setString('persons', Person.encodedPersonString);
    await _asyncPrefs.setInt('selectedIndex', selectedIndex);
    await _asyncPrefs.setInt('clickN', SosManager.clickN);
  }

  static Future<void> loadAll() async {
    // print("String load: ${Person.encodedPersonString}");

    Person.encodedPersonString.isNotEmpty
        ? Person.decodePerson()
        : print("the string is empty");

    final String storedEncodedPersonString =
        await _asyncPrefs.getString('persons') ?? Person.encodedPersonString;
    final int storedSelectedIndex =
        await _asyncPrefs.getInt('selectedIndex') ?? 1;
    final int storedClickN =
        await _asyncPrefs.getInt('clickN') ?? selectedIndex + 1;

    Person.encodedPersonString = storedEncodedPersonString;
    selectedIndex = storedSelectedIndex;
    SosManager.clickN = storedClickN;
    print("persons loaded: ${Person.persons}");
  }
}
