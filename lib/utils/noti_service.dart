import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:safe_return/utils/stored_settings.dart';

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

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
    return notificationsPlugin.show(id, title, body, category);
  }

  notHomeNotif() {
    StoredSettings.saveAll();
    NotiService().showNotification(
      title: "Are you ok?",
      body:
          "We've detected that you're not back home by your set time. Enter your code to verify you are ok.",
      category: NotificationDetails(),
    );
  }
}
