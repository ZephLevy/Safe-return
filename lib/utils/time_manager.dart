import 'package:intl/intl.dart';
import 'package:safe_return/pages/home_page.dart';

class TimeManager {
  static DateTime selectedTime = DateTime.now();
  static DateTime? timeOfTap;

  static String shortSelectedTime() {
    return TimeSetterState.isTomorrow
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
    if (timeOfTap != null) {
      return selectedTime.difference(timeOfTap!).inSeconds;
    }
    return null;
  }
}
