import 'package:safe_return/pages/home_page.dart';
import 'package:safe_return/utils/time_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerPrefs {
  static Future<void> saveTimer() async {
    final asyncPrefs = SharedPreferencesAsync();
    if (TimeManager.selectedTime != null) {
      await asyncPrefs.setString(
          'selectedTime', TimeManager.selectedTime!.toIso8601String());
    }

    if (TimeManager.timeOfTap != null) {
      await asyncPrefs.setString(
          'timeOfTap', TimeManager.timeOfTap!.toIso8601String());
    }

    await asyncPrefs.setBool('showTimer', TimerAndClockState.showTimer);
    await asyncPrefs.setBool('validTime', TimerAndClockState.validTime);
    await asyncPrefs.setBool('startSelected', TimerAndClockState.startSelected);
    await asyncPrefs.setBool('isTomorrow', TimeSetterState.isTomorrow);
    // codeAttempts = 3; //? idk when to save these i'll handle these later
  }

  static Future<void> loadTimer() async {
    final asyncPrefs = SharedPreferencesAsync();
    String? stringSelectedTime = await asyncPrefs.getString('selectedTime');
    if (stringSelectedTime != null) {
      TimeManager.selectedTime = DateTime.tryParse(stringSelectedTime);
    }

    String? stringTimeOfTap = await asyncPrefs.getString('timeOfTap');
    if (stringTimeOfTap != null) {
      TimeManager.timeOfTap = DateTime.tryParse(stringTimeOfTap);
    }

    TimerAndClockState.showTimer =
        await asyncPrefs.getBool('showTimer') ?? false;

    TimerAndClockState.validTime =
        await asyncPrefs.getBool('validTime') ?? false;

    TimerAndClockState.startSelected =
        await asyncPrefs.getBool('startSelected') ?? false;

    TimeSetterState.isTomorrow =
        await asyncPrefs.getBool('isTomorrow') ?? false;
  }
}
