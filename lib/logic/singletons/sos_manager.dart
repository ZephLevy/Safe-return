class SosManager {
  static final SosManager _instance = SosManager._internal();

  factory SosManager() {
    return _instance;
  }
  SosManager._internal();
  int clickN = 3;
}
