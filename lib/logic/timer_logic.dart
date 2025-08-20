import 'package:safe_return/utils/sos_manager.dart';
import 'package:safe_return/utils/time_manager.dart';

class TimerLogic {
  static bool isTomorrow = false;

  static bool validTime() {
    DateTime? dateTomorrow = TimeManager.selectedTime.add(Duration(days: 1));

    if (isTomorrow) {
      TimeManager.selectedTime = DateTime(
          dateTomorrow.year,
          dateTomorrow.month,
          dateTomorrow.day,
          TimeManager.selectedTime.hour,
          TimeManager.selectedTime.minute,
          TimeManager.selectedTime.second,
          TimeManager.selectedTime.millisecond);
    }
    return TimeManager.selectedTime.isAfter(DateTime.now());
  }

  static bool notValidForStart() {
    return TimerLogic.codesNull() ||
        !TimerLogic.validTime() ||
        TimerLogic.timeIsNow(TimeManager.selectedTime, DateTime.now());
  }

  static bool codesNull() {
    return SosManager.fakeCode == null || SosManager.secretCode == null;
  }

  static bool validForStart() => !codesNull() && validTime();

  static bool timeIsNow(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }
}
