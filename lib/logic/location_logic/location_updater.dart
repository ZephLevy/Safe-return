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
import 'package:safe_return/logic/global_vars.dart';
import 'package:safe_return/logic/location_logic/get_location.dart';
import 'package:safe_return/logic/timer_logic.dart';
import 'package:safe_return/logic/tokens_logic.dart';
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
    userPathNotifier.value = await UserPathStorage.load();
    await TokensLogic.triggerRefreshTokens();

    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send({"type": "location", "contents": locationDto.toJson()});
  }

  static Future<void> dispose() async {
    print("***********Dispose callback handler");

    final SendPort? send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send({"type": "dispose"});
  }
}

class LocationUpdater extends StatefulWidget {
  const LocationUpdater({super.key});

  @override
  State<LocationUpdater> createState() => LocationUpdaterState();
}

class LocationUpdaterState extends State<LocationUpdater> {
  static bool powerSaving = false;
  static LocationAccuracy locationAccuracy = LocationAccuracy.BALANCED;
  static double? speed;
  static int androidInterval = 10;

  static DateTime? lastTokenRefresh;

  List<LatLng> tmpPath = [];
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
    port.listen(
      (dynamic data) {
        // print("listened for data: $data");
        if (data != null) {
          //disose function triggered
          if (data["type"] == "dispose") {
            userPathNotifier.value = [];
            tmpPath.clear();
            UserPathStorage.save(userPathNotifier.value);
          } else if (data["type"] == "location") {
            //location logger (callbackLogger) function triggered

            final contents = Map<String, dynamic>.from(data["contents"]);
            print(contents);
            final locationDto = LocationDto.fromJson(contents);
            speed = contents["speed"];
            final currentPos =
                LatLng(locationDto.latitude, locationDto.longitude);

            userPathNotifier.value = [...userPathNotifier.value, currentPos];
            print("USERPATH ******* ${userPathNotifier.value.length}");
            UserPathStorage.save(userPathNotifier.value);
            tmpPath.add(currentPos);

            if (tmpPath.length == 10) {
              logLocationDtoToServer(locationDto);
              tmpPath.clear();
            }
            print(speed! * 5);
          } else {
            print("unexpected data: $data");
          }
        }
      },
    );

    initLocator();
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
            showsBackgroundLocationIndicator: true,
            accuracy: locationAccuracy,
            distanceFilter: speed != null ? (speed! * 5) : 10,
            stopWithTerminate: false),
        androidSettings: AndroidSettings(
            accuracy:
                locationAccuracy, //TODO not sure which accuracy to use yet. increase accuracy if closer to set time?
            interval: LocationUpdaterState.androidInterval,
            distanceFilter: speed != null ? (speed! * 5) : 10,
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
