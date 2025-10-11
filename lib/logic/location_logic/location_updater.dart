import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:safe_return/logic/location_logic/get_location.dart';
import 'package:safe_return/logic/timer_logic.dart';
import 'package:safe_return/logic/tokens_logic.dart';
import 'package:safe_return/pages/main_pages/map_page.dart';
import 'package:safe_return/storage.dart/user_path_storage.dart';

@pragma('vm:entry-point')
class LocationCallbackHandler {
  @pragma('vm:entry-point')
  static void callback(LocationDto locationDto) async {
    await LocationServiceRepository.callbackLogger(locationDto);
  }

  @pragma('vm:entry-point')
  static void disposeCallback() async {
    await LocationServiceRepository.dispose();
    // Runs when service stops
    print('Background locator disposed');
  }

  @pragma('vm:entry-point')
  static void initCallback(Map<dynamic, dynamic> data) {
    // Runs once when the service starts
    print('Background locator initialized');
  }

  @pragma('vm:entry-point')
  static void notificationCallback() {
    print('User clicked on the notification');
  }
}

class LocationServiceRepository {
  static const String isolateName = "LocatorIsolate";

  static Future<void> callbackLogger(LocationDto locationDto) async {
    userPathNotifier.value = await UserPathStorage.loadLocationData();
    await TokensLogic.triggerRefreshTokens();

    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send({"type": "location", "contents": locationDto.toJson()});

    print("USERPATH ******* ${userPathNotifier.value.length}");

    logLocationDtoToServer(locationDto);
  }

  static Future<void> dispose() async {
    print("***********Dispose callback handler");

    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send({"type": "dispose"});
  }

  static Future<void> logLocationDtoToServer(LocationDto locationDto) async {
    const String ip = String.fromEnvironment('IP');
    try {
      if (ip == "") {
        print("No ip passed to CLI when run");
      }
      Uri url = Uri.parse('http://$ip/user-status/update-location');

      final response =
          await http.post(url, body: {'locationDto': jsonEncode(locationDto)});
      if (response.statusCode == 200) {
        print('Success: ${response.body}');
      } else {
        print(
            'Failed while updatinglocationdto with status: ${response.statusCode}\n\n\n${response.body}');
      }
    } catch (e) {
      print("Could not connect to server/server not running");
      // print("e: $e");
    }
  }
}

class LocationUpdater extends StatefulWidget {
  const LocationUpdater({super.key});

  @override
  State<LocationUpdater> createState() => LocationUpdaterState();
}

class LocationUpdaterState extends State<LocationUpdater> {
  static bool powerSaving = false;
  static LocationAccuracy locationAccuracy = LocationAccuracy.HIGH;
  static DateTime? lastTokenRefresh;
  ReceivePort port = ReceivePort();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 20,
          width: 20,
          child: InkWell(
            child: Icon(Icons.stop),
            onTap: () async {
              await BackgroundLocator.unRegisterLocationUpdate();
            },
          ),
        ),
        SizedBox(
          height: 20,
          width: 20,
          child: InkWell(
            child: Icon(Icons.abc),
            onTap: () async {
              if (await GetLocation.checkLocationPermissions()) {
                LocationUpdaterState.startLocationService();
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> initLocator() async {
    await initPlatformState();
  }

  Future<void> initPlatformState() async {
    await BackgroundLocator.initialize();
  }

  @override
  void initState() {
    super.initState();
    IsolateNameServer.removePortNameMapping(
        LocationServiceRepository.isolateName);

    IsolateNameServer.registerPortWithName(
        port.sendPort, LocationServiceRepository.isolateName);
    port.listen((dynamic data) {
      print("listened for data: $data");
      if (data != null) {
        if (data["type"] == "dispose") {
          userPathNotifier.value = [];
          UserPathStorage.saveLocationData(userPathNotifier.value);
        } else if (data["type"] == "location") {
          final contents = Map<String, dynamic>.from(data["contents"]);
          final dto = LocationDto.fromJson(contents);
          final currentPos = LatLng(dto.latitude, dto.longitude);
          userPathNotifier.value = [...userPathNotifier.value, currentPos];
          UserPathStorage.saveLocationData(userPathNotifier.value);
        } else {
          print("unexpected data: $data");
        }
      }
    });

    initLocator();
  }

  static void setLocationLogic() {
    lastTokenRefresh = TimerLogic.timeOfTap;
  }

  static void startLocationService() {
    BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        // initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        autoStop: false,
        iosSettings: IOSSettings(
            accuracy: locationAccuracy,
            distanceFilter: 10,
            stopWithTerminate: true),
        androidSettings: AndroidSettings(
            accuracy: LocationAccuracy
                .BALANCED, //TODO not sure which accuracy to use yet. increase accuracy if closer to set time?
            interval: 120,
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
