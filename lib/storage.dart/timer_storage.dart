import 'package:safe_return/logic/timer_logic.dart';
import 'package:safe_return/pages/main_pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerStorage {
  static Future<void> saveTimer() async {
    final asyncPrefs = SharedPreferencesAsync();
    await asyncPrefs.setString(
        'selectedTime', TimerLogic.selectedTime.toIso8601String());

    await asyncPrefs.setString(
        'timeOfTap', TimerLogic.timeOfTap?.toIso8601String() ?? "");

    await asyncPrefs.setBool('showTimer', TimerAndClockState.showTimer);
    await asyncPrefs.setBool('startSelected', TimerAndClockState.startSelected);
    await asyncPrefs.setBool('isTomorrow', TimerLogic.isTomorrow);
    // codeAttempts = 3; //? idk when to save these i'll handle these later
  }

  static Future<void> loadTimer() async {
    if (TimerAndClockState.showTimer) {
      final asyncPrefs = SharedPreferencesAsync();

      String stringTimeOfTap = await asyncPrefs.getString('timeOfTap') ?? "";

      TimerLogic.timeOfTap = DateTime.tryParse(stringTimeOfTap);

      TimerAndClockState.showTimer =
          await asyncPrefs.getBool('showTimer') ?? false;

      TimerAndClockState.startSelected =
          await asyncPrefs.getBool('startSelected') ?? false;

      TimerLogic.isTomorrow = await asyncPrefs.getBool('isTomorrow') ?? false;

      if (TimerAndClockState.showTimer) {
        String? stringSelectedTime = await asyncPrefs.getString('selectedTime');
        if (stringSelectedTime != null) {
          TimerLogic.selectedTime = DateTime.parse(stringSelectedTime);
        }
      }
    }
  }
}
