import 'package:flutter/material.dart';
import 'package:safe_return/logic/global_vars.dart';

class HomeUpdater {
  static bool get showTimer => showTimerNotifier.value;
  static set showTimer(bool value) => showTimerNotifier.value = value;

  static bool get firstLoad => firstLoadNotifier.value;
  static set firstLoad(bool value) => firstLoadNotifier.value = value;

  static bool get startSelected => startSelectedNotifier.value;
  static set startSelected(bool value) => startSelectedNotifier.value = value;

  static int get codeAttempts => codeAttemptsNotifier.value;
  static set codeAttempts(int value) => codeAttemptsNotifier.value = value;

  static DateTime get selectedTime => selectedTimeNotifier.value;
  static set selectedTime(DateTime value) => selectedTimeNotifier.value = value;
}

class WaitingServer extends ValueNotifier<bool> {
  WaitingServer() : super(false);

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

class InitializingTimer extends ValueNotifier<bool> {
  InitializingTimer() : super(false);

  Future<void> isInitializing(Future<dynamic> Function() attempt) async {
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
