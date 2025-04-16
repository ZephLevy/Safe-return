import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:safe_return/pages/Settings/check_codes.dart';

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  static const platform = MethodChannel('notification_channel');

  static var platformChannelSpecificsCodeInput = NotificationDetails(
      iOS: // categoryIdentifier must match Swift's
          DarwinNotificationDetails(categoryIdentifier: 'TEXT_INPUT_CATEGORY'));
  static String? userInput;

  static var platformChannelSpecificsDelayActions = NotificationDetails(
      iOS: DarwinNotificationDetails(
          categoryIdentifier: 'DELAY_ACTIONS_CATEGORY'));

  //initialize
  Future<void> initNotification() async {
    if (_isInitialized) return; // prevent re-initialization

    //prepare ios init settings
    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    //init settings
    const initSettings = InitializationSettings(
      iOS: initSettingsIOS,
    );

    //initialize the plugin
    await notificationsPlugin.initialize(initSettings);
  }

  //notification details setup
  NotificationDetails notificationDetails() {
    return const NotificationDetails(iOS: DarwinNotificationDetails());
  }

  //show notification
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
    NotificationDetails? category,
  }) async {
    receiveFromChannel();
    return notificationsPlugin.show(id, title, body, category);
  }

  receiveFromChannel() {
    platform.setMethodCallHandler(
      (call) async {
        switch (call.method) {
          case "onCodeInput":
            {
              userInput = call.arguments;
              CheckCodes().checkCodes();
            }
          case "onActionSelected":
            {
              String action = call.arguments;
              showNotification(
                  title: "Got it!", body: "Extended time for $action more");
            }
          default:
            print("no action");
            null;
        }
      },
    );
  }
}
