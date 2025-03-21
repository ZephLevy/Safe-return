// ignore_for_file: avoid_print
import 'package:shared_preferences/shared_preferences.dart';

class StoredSettings {
  static List<String> contactPhone = [];
  static List<String> contactName = [];
  static String? dvalue;
  static final SharedPreferencesAsync _asyncPrefs = SharedPreferencesAsync();

  static Future<void> saveContacts(
      List<String> contactPhone, List<String> contactName) async {
    await _asyncPrefs.setStringList('selectedPhones', contactPhone);
    await _asyncPrefs.setStringList('selectedNames', contactName);
    await _asyncPrefs.setString('dropdown value', dvalue ?? "Double Click");
    // print("saved your data!");
  }

  static Future<void> saveDropdown(String? value) async {
    await _asyncPrefs.setString('dropdown value', dvalue ?? "Double Click");
    // print("saved your data!");
  }

  static Future<void> loadAll() async {
    // print("grabbed it!");
    final List<String> storedPhone =
        await _asyncPrefs.getStringList('selectedPhones') ?? [];
    final List<String> storedName =
        await _asyncPrefs.getStringList('selectedNames') ?? [];
    final String storedDropdown =
        await _asyncPrefs.getString('dropdown value') ?? "null";
    contactPhone = storedPhone;
    contactName = storedName;
    dvalue = storedDropdown;
    print("stored phone: $storedPhone");
    print("stored name: $storedName");
    print("stored value: $storedDropdown");
    print("drop: $dvalue");
  }
}
