import 'package:intl/intl.dart';
import 'package:safe_return/logic/codes_logic.dart';
import 'package:safe_return/logic/home_page_updater.dart';
import 'package:safe_return/pages/main_pages/map_page.dart';

class TimerLogic {
  static bool plusDay = false;
  static DateTime? timeOfTap;

  static bool addDay() {
    DateTime dateExtraDay = HomeUpdater.selectedTime.add(Duration(days: 1));

    if (plusDay) {
      HomeUpdater.selectedTime = DateTime(
          dateExtraDay.year,
          dateExtraDay.month,
          dateExtraDay.day,
          HomeUpdater.selectedTime.hour,
          HomeUpdater.selectedTime.minute,
          HomeUpdater.selectedTime.second,
          HomeUpdater.selectedTime.millisecond);
    }
    return HomeUpdater.selectedTime.isAfter(DateTime.now());
  }

  bool timeIsNextDay() {
    final DateTime now = DateTime.now();
    final DateTime selected = HomeUpdater.selectedTime;

    final nowMinutes = now.hour * 60 + now.minute;
    final selectedMinutes = selected.hour * 60 + selected.minute;

    return selectedMinutes <= nowMinutes;
  }

  static void calculateTime() {
    // if (timeIsNextDay) {}
  }

  static bool codesNull() {
    return CodesLogic.decoyCode == null || CodesLogic.realCode == null;
  }

  static bool selectedTimeIsNow() {
    return TimerLogic.timeIsNow(HomeUpdater.selectedTime, DateTime.now());
  }

  static bool validSettingsForStart() =>
      !codesNull() &&
      MapsPageState.homePosition != null &&
      !selectedTimeIsNow();

  static bool timeIsNow(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour &&
        a.minute == b.minute;
  }

  static String shortSelectedTime() {
    return TimerLogic.plusDay
        ? "${DateFormat.Hm().format(HomeUpdater.selectedTime)}, Tomorrow"
        : DateFormat.Hm().format(HomeUpdater.selectedTime);
  }

  static int? timeElapsed() {
    if (timeOfTap != null) {
      return DateTime.now().difference(timeOfTap!).inSeconds;
    }
    return null;
  }

  static int? totalTime() {
    if (timeOfTap != null) {
      return HomeUpdater.selectedTime.difference(timeOfTap!).inSeconds;
    }
    return null;
  }
}
