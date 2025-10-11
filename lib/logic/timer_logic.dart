import 'package:intl/intl.dart';
import 'package:safe_return/logic/sos_logic.dart';

class TimerLogic {
  static bool isTomorrow = false;
  static DateTime selectedTime = DateTime.now();
  static DateTime? timeOfTap;

  static bool validTime() {
    DateTime? dateTomorrow = selectedTime.add(Duration(days: 1));

    if (isTomorrow) {
      selectedTime = DateTime(
          dateTomorrow.year,
          dateTomorrow.month,
          dateTomorrow.day,
          selectedTime.hour,
          selectedTime.minute,
          selectedTime.second,
          selectedTime.millisecond);
    }
    return selectedTime.isAfter(DateTime.now());
  }

  static bool notValidForStart() {
    return TimerLogic.codesNull() ||
        !TimerLogic.validTime() ||
        TimerLogic.timeIsNow(selectedTime, DateTime.now());
  }

  static bool codesNull() {
    return SosLogic.fakeCode == null || SosLogic.secretCode == null;
  }

  static bool validForStart() => !codesNull() && validTime();

  static bool timeIsNow(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }

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
