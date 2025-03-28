// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:safe_return/utils/sos_manager.dart';
import 'package:safe_return/utils/contacts/persons.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoredSettings {
  static List<String> contactPhone = [];
  static List<String> contactName = [];
  static String? dvalue; //todo remove this
  static int selectedIndex = 1;
  static final SharedPreferencesAsync _asyncPrefs = SharedPreferencesAsync();

  static Future<void> saveContacts(List<String> contactPhone,
      List<String> contactName, String encodePersonString) async {
    // await _asyncPrefs.setStringList('selectedPhones', contactPhone);
    // await _asyncPrefs.setStringList('selectedNames', contactName);
    await _asyncPrefs.setString('persons', Person.encodePersonString);

    // print("saved your data!");
  }

  static Future<void> saveSosActivation(int selectedIndex) async {
    await _asyncPrefs.setInt('selectedIndex', selectedIndex);
    await _asyncPrefs.setInt('clickN', SosManager.clickN);
    // print("saved your data!");
  }

  static Future<void> loadAll() async {
    // print("grabbed it!");
    final String storedEncodedPersonString =
        await _asyncPrefs.getString('persons') ?? "im null!";
    // final List<String> storedPhone =
    //     await _asyncPrefs.getStringList('selectedPhones') ?? [];
    // final List<String> storedName =
    //     await _asyncPrefs.getStringList('selectedNames') ?? [];
    final int storedSelectedIndex =
        await _asyncPrefs.getInt('selectedIndex') ?? 1;
    final int storedClickN =
        await _asyncPrefs.getInt('clickN') ?? selectedIndex + 1;

    Person.encodePersonString = storedEncodedPersonString;
    // contactPhone = storedPhone;
    // contactName = storedName;
    selectedIndex = storedSelectedIndex;
    SosManager.clickN = storedClickN;
  }
}
