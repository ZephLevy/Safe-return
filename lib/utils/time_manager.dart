class TimeManager {
  static DateTime selectedTime = DateTime.now();
  static DateTime now = DateTime.now();
  static int remainingTime = 0;

  static timerCalculations() {
    TimeManager.now = DateTime.now();
    if (TimeManager.selectedTime.isBefore(TimeManager.now)) {
      TimeManager.selectedTime =
          TimeManager.selectedTime.add(Duration(days: 1));
    }
    TimeManager.remainingTime =
        TimeManager.selectedTime.difference(TimeManager.now).inSeconds;
  }
}
