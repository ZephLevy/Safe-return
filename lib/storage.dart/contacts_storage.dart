import 'package:safe_return/logic/persons_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsStorage {
  static final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  static Future<void> save({
    List<PersonLogic>? personList,
  }) async {
    if (personList != null) {
      await asyncPrefs.setString(
          'persons', PersonLogic.encodedPersonString(personList));
    }
  }

  static Future<void> load() async {
    String encodedPersonString = await asyncPrefs.getString('persons') ?? "";

    if (encodedPersonString.isNotEmpty) {
      PersonLogic.decodePerson(
          toDecode: encodedPersonString, targetList: PersonLogic.persons);
    }
  }
}
