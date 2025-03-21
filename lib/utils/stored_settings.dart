// ignore_for_file: avoid_print
import 'package:shared_preferences/shared_preferences.dart';

class StoredSettings {
  static List<String> contactPhone = [];
  static List<String> contactName = [];
  static final SharedPreferencesAsync _asyncPrefs = SharedPreferencesAsync();

  static Future<void> saveContacts(
      List<String> contactPhone, List<String> contactName) async {
    await _asyncPrefs.setStringList('selectedPhones', contactPhone);
    await _asyncPrefs.setStringList('selectedNames', contactName);
    print("saved your data!");
  }

  static Future<void> loadContacts() async {
    print("grabbed it!");
    final List<String> storedPhone =
        await _asyncPrefs.getStringList('selectedPhones') ?? [];
    final List<String> storedName =
        await _asyncPrefs.getStringList('selectedNames') ?? [];
    contactPhone = storedPhone;
    contactName = storedName;
    print("phone: $contactPhone");
    print("name: $contactName");
    print("stored ph: $storedPhone");
    print("stored name: $storedName");
  }
}
