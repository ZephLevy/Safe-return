import 'package:intl/intl.dart';
import 'package:safe_return/logic/timer_logic.dart';

class TimeManager {
  static DateTime selectedTime = DateTime.now();
  static DateTime? timeOfTap;

  static String shortSelectedTime() {
    return TimerLogic.isTomorrow
        ? "${DateFormat.Hm().format(selectedTime)}, Tomorrow"
        : DateFormat.Hm().format(selectedTime);
  }

  static int? timeElapsed() {
    if (timeOfTap != null) {
      return DateTime.now().difference(timeOfTap!).inSeconds;
    }
    return null;
  }

  static int? totalTime() {
    return totalTimeDuration()?.inSeconds;
  }

  static Duration? totalTimeDuration() {
    if (timeOfTap != null) {
      return selectedTime.difference(timeOfTap!);
    }
    return null;
  }
}
