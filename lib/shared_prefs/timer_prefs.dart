import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:safe_return/utils/time_manager.dart';

class TimerPrefs {
  final asyncPrefs = SharedPreferencesAsync();
  Future<void> saveTimer() async {
    // if (TimeManager.selectedTime != null) {
    //   asyncPrefs.setS
    // }
  }
}
