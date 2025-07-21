import 'package:safe_return/utils/time_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerPrefs {
  final asyncPrefs = SharedPreferencesAsync();
  Future<void> saveTimer() async {
    if (TimeManager.selectedTime != null) {
      await asyncPrefs.setString(
          'selectedTime', TimeManager.selectedTime!.toIso8601String());
    }
    // if (TimeManager.shortSelectedTime() != null) {
    //   asyncPrefs.setString(
    //       'shortSelectedTime', TimeManager.shortSelectedTime()!);
    // }
    if (TimeManager.timeOfTap != null) {
      await asyncPrefs.setString(
          'timeOfTap', TimeManager.timeOfTap!.toIso8601String());
    }
    // if (TimeManager.totalTime() != null) {
    //   await asyncPrefs.setInt('totalTime', TimeManager.totalTime()!);
    // }
  }
}
