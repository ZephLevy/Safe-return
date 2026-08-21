import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safe_return/logic/location_logic/get_location.dart';

class CurrentPosition extends ValueNotifier<Position?> {
  CurrentPosition() : super(null);

  StreamSubscription<Position>? _subscription;

  bool hasError = false;

  Future<void> init() async {
    //get inital position
    try {
      value = await GetLocation.determinePosition();
      print("got position");
      hasError = false;
    } catch (e) {
      hasError = true;
      print("error determining position: $e");
      notifyListeners();
    }

    //keep it updated live
    _subscription = Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.best, distanceFilter: 0))
        .listen((position) {
      print("stream giving position");
      value = position; //notifies listening widgets
    }, onError: (error) {
      print("Position stream error: $error");
      hasError = true;
      notifyListeners();
    });
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null; // so init() knows it needs to restart next time
    value = null; // clear stale position — optional, see note below
  }

  void disposeNotifier() {
    _subscription?.cancel();
    dispose();
  }
}
