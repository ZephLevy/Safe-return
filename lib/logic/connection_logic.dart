import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class IsOnlineNotifier extends ValueNotifier<bool> {
  IsOnlineNotifier() : super(false);

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Future<void> init() async {
    //returns a list of which connectivity types device is connected to (e.g. could return: [Connectivity.wifi, Connectivity.mobile])
    final initial = await Connectivity().checkConnectivity();
    value = _hasAConnection(initial);
    print("inital connection: $value, $initial");

    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      value = _hasAConnection(results);
      print("results: $results");
      print("value: $value");
    });
  }

  bool _hasAConnection(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.other) ||
        results.contains(ConnectivityResult.ethernet);
  }

  void disposeNotifier() {
    _subscription?.cancel();
    dispose();
  }
}

class ReconnectingNotifier extends ValueNotifier<bool> {
  ReconnectingNotifier() : super(false);

  Future<void> tryReconnect(Future<dynamic> Function() attempt) async {
    if (value) return;

    value = true;

    try {
      await attempt();
      value = false;
    } catch (e) {
      value = false;
    }
  }
}
