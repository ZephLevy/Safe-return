import 'package:safe_return/logic/home_page_updater.dart';
import 'package:safe_return/logic/timer_logic.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerStorage {
  static Future<void> saveTimer() async {
    final asyncPrefs = SharedPreferencesAsync();
    await asyncPrefs.setString(
        'selectedTime', HomeUpdater.selectedTime.toIso8601String());

    if (TimerLogic.timeOfTap != null) {
      await asyncPrefs.setString(
          'timeOfTap', TimerLogic.timeOfTap!.toIso8601String());
    }

    await asyncPrefs.setBool('showTimer', HomeUpdater.showTimer);
    await asyncPrefs.setBool('isTomorrow', TimerLogic.plusDay);
    // codeAttempts = 3; //TODO idk when to save these i'll handle these later
  }

  static Future<void> loadTimer() async {
    final asyncPrefs = SharedPreferencesAsync();

    TimerLogic.timeOfTap =
        DateTime.tryParse(await asyncPrefs.getString('timeOfTap') ?? "");

    HomeUpdater.showTimer = await asyncPrefs.getBool('showTimer') ?? false;

    TimerLogic.plusDay = await asyncPrefs.getBool('isTomorrow') ?? false;

    HomeUpdater.selectedTime =
        DateTime.tryParse(await asyncPrefs.getString('selectedTime') ?? "") ??
            DateTime.now();
  }
}
