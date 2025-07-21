import 'package:intl/intl.dart';

class TimeManager {
  static DateTime? selectedTime;
  static DateTime? timeOfTap;

  static int? totalTime() {
    if (timeOfTap != null) {
      return selectedTime?.difference(timeOfTap!).inSeconds;
    }
    return null;
  }

  static int? timeElapsed() {
    if (timeOfTap != null) {
      return DateTime.now().difference(timeOfTap!).inSeconds;
    }
    return null;
  }

  static String? shortSelectedTime() {
    if (selectedTime != null) {
      return DateFormat.Hm().format(selectedTime!);
    }
    return null;
  }
}
