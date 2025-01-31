class TimeManager {
  static final TimeManager _instance = TimeManager._internal();

  factory TimeManager() {
    return _instance;
  }

  TimeManager._internal();
  DateTime selectedTime = DateTime.now();
}
