import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectionLogic {
  static Future<bool> hasInternet() async {
    //returns a list of which connectivity types device is connected to (e.g. could return: [Connectivity.wifi, Connectivity.mobile])
    var connectivityResult = await Connectivity().checkConnectivity();

    //if the device is connected to the internet with any connectivity type, return true
    return connectivityResult.any((r) => r != ConnectivityResult.none);
  }
}
