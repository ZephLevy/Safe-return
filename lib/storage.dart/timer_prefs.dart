import 'package:safe_return/logic/timer_logic.dart';
import 'package:safe_return/pages/main_pages/home_page.dart';
import 'package:safe_return/utils/time_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerPrefs {
  static Future<void> loadTimer() async {
    if (TimerAndClockState.showTimer) {
      final asyncPrefs = SharedPreferencesAsync();

      String stringTimeOfTap = await asyncPrefs.getString('timeOfTap') ?? "";

      TimeManager.timeOfTap = DateTime.tryParse(stringTimeOfTap);

      TimerAndClockState.showTimer =
          await asyncPrefs.getBool('showTimer') ?? false;

      TimerAndClockState.startSelected =
          await asyncPrefs.getBool('startSelected') ?? false;

      TimerLogic.isTomorrow = await asyncPrefs.getBool('isTomorrow') ?? false;

      if (TimerAndClockState.showTimer) {
        String? stringSelectedTime = await asyncPrefs.getString('selectedTime');
        if (stringSelectedTime != null) {
          TimeManager.selectedTime = DateTime.parse(stringSelectedTime);
        }
      }
    }
  }

  static Future<void> saveTimer() async {
    final asyncPrefs = SharedPreferencesAsync();
    await asyncPrefs.setString(
        'selectedTime', TimeManager.selectedTime.toIso8601String());

    await asyncPrefs.setString(
        'timeOfTap', TimeManager.timeOfTap?.toIso8601String() ?? "");

    await asyncPrefs.setBool('showTimer', TimerAndClockState.showTimer);
    await asyncPrefs.setBool('startSelected', TimerAndClockState.startSelected);
    await asyncPrefs.setBool('isTomorrow', TimerLogic.isTomorrow);
    // codeAttempts = 3; //? idk when to save these i'll handle these later
  }
}
