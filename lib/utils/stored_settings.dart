import 'dart:async';
import 'package:safe_return/utils/sos_manager.dart';
import 'package:safe_return/utils/contacts/persons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoredSettings {
  static String? dvalue; //todo remove this
  static int selectedIndex = 1;
  static final SharedPreferencesAsync _asyncPrefs = SharedPreferencesAsync();

  static Future<void> saveAll() async {
    Person.encodePerson(Person.persons);
    await _asyncPrefs.setString('persons', Person.encodedPersonString);
    await _asyncPrefs.setInt('selectedIndex', selectedIndex);
    await _asyncPrefs.setInt('clickN', SosManager.clickN);
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

    selectedIndex = storedSelectedIndex;
    SosManager.clickN = storedClickN;
    print("persons loaded: ${Person.persons}");
    print("persons loaded: ${Person.persons}");
  }
}
