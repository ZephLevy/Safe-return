import 'package:safe_return/logic/home_page_updater.dart';
import 'package:safe_return/logic/timer_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerStorage {
  static Future<void> saveTimer() async {
    final asyncPrefs = SharedPreferencesAsync();
    await asyncPrefs.setString(
        'selectedTime', HomeUpdater.selectedTime.toIso8601String());

    await asyncPrefs.setString(
        'timeOfTap', TimerLogic.timeOfTap?.toIso8601String() ?? "");

    await asyncPrefs.setBool('showTimer', HomeUpdater.showTimer);
    await asyncPrefs.setBool('startSelected', HomeUpdater.startSelected);
    await asyncPrefs.setBool('isTomorrow', TimerLogic.plusDay);
    // codeAttempts = 3; //TODO idk when to save these i'll handle these later
  }

  static Future<void> loadTimer() async {
    if (HomeUpdater.showTimer) {
      final asyncPrefs = SharedPreferencesAsync();

      String stringTimeOfTap = await asyncPrefs.getString('timeOfTap') ?? "";

      TimerLogic.timeOfTap = DateTime.tryParse(stringTimeOfTap);

      HomeUpdater.showTimer = await asyncPrefs.getBool('showTimer') ?? false;

      HomeUpdater.startSelected =
          await asyncPrefs.getBool('startSelected') ?? false;

      TimerLogic.plusDay = await asyncPrefs.getBool('isTomorrow') ?? false;

      if (HomeUpdater.showTimer) {
        String? stringSelectedTime = await asyncPrefs.getString('selectedTime');
        if (stringSelectedTime != null) {
          HomeUpdater.selectedTime = DateTime.parse(stringSelectedTime);
        }
      }
    }
  }
}
