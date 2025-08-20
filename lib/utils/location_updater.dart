import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:safe_return/logic/location.dart';

class LocationUpdater extends StatefulWidget {
  const LocationUpdater({super.key});

  @override
  State<LocationUpdater> createState() => LocationUpdaterState();
}

class LocationUpdaterState extends State<LocationUpdater> {
  ReceivePort port = ReceivePort();

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }

  Future<void> initPlatformState() async {
    await BackgroundLocator.initialize();
  }

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        port.sendPort, LocationServiceRepository.isolateName);
    port.listen((dynamic data) {
      // do something with data
      print("data: $data");
    });
    initPlatformState();
  }

  static void startLocationService() {
    print("started");
    BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        // initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        autoStop: false,
        iosSettings: IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 10),
        androidSettings: AndroidSettings(
            accuracy: LocationAccuracy
                .BALANCED, //TODO not sure which accuracy to use yet. increase accuracy if closer to set time?
            interval: 5,
            distanceFilter: 10,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Start Location Tracking',
                notificationMsg: 'Track location in background',
                notificationBigMsg:
                    'Background location is on to keep the app up-to-date with your location. This is required for main features to work properly when the app is not running.',
                notificationIcon: 'ic_launcher',
                notificationIconColor: Colors.grey,
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
  }
}

@pragma('vm:entry-point')
class LocationCallbackHandler {
  @pragma('vm:entry-point')
  static void callback(LocationDto locationDto) async {
    LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
    await myLocationCallbackRepository.callback(locationDto);
  }

  @pragma('vm:entry-point')
  static void initCallback(Map<dynamic, dynamic> data) {
    // Runs once when the service starts
    print('Background locator initialized');
  }

  @pragma('vm:entry-point')
  static void disposeCallback() {
    // Runs when service stops
    print('Background locator disposed');
  }

  @pragma('vm:entry-point')
  static void notificationCallback() {
    print('User clicked on the notification');
  }
}

class LocationServiceRepository {
  static const String isolateName = "LocatorIsolate";

  Future<void> callback(LocationDto locationDto) async {
    print(' location in dart: ${locationDto.toString()}');

    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(locationDto.toJson());
  }

  Future<void> dispose() async {
    print("***********Dispose callback handler");

    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }
}
