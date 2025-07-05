class TimeManager {
  static DateTime? selectedTime;
  static DateTime? timeOfTap;
  // static int? timeElapsed;

  static int? totalTime() {
    if (timeOfTap != null) {
      return selectedTime?.difference(timeOfTap!).inSeconds;
    }
    print("totalT - timetap null");
    return null;
  }

  static int? timeElapsed() {
    if (timeOfTap != null) {
      return DateTime.now().difference(timeOfTap!).inSeconds;
    }
    print("timetap null");
    return null;
  }
}
