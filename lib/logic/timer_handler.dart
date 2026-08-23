import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_return/logic/global_vars.dart';
import 'package:safe_return/logic/home_page_updater.dart';
import 'package:safe_return/logic/location_logic/get_location.dart';
import 'package:safe_return/logic/location_logic/location_updater.dart';
import 'package:safe_return/logic/timer_logic.dart';
import 'package:safe_return/pages/main_pages/home_page.dart';
import 'package:safe_return/pages/main_pages/map_page.dart';

class TimerHandler {
  static Timer? awayTimer;

  static Future<void> tryStartTimer(context) async {
    waitingServerNotifier.value = true;

    await HomeTimerState.setTimerLogic();
    LocationUpdaterState.setLocationLogic();

    await HomePageState.sendTime(HomeUpdater.selectedTime,
        onServerFail: () async {
      //TODO switch the on server fail with the onserver success when ecerything works properly
      //TODO also idk there's somthing else to do i marked here but i forgot
      if (await GetLocation.checkLocationPermissions()) {
        LocationUpdaterState.startLocationService();
      }

      HomeUpdater.codeAttempts = 3;

      HomeUpdater.showTimer = true;
      HomeUpdater.startSelected = true;

      if (TimerLogic.timeOfTap != null) {
        Duration timeTo = TimerLogic.totalTimeDuration()!;

        awayTimer = Timer(
          timeTo,
          () async {
            if (MapsPageState.homePosition == null) return;
            final LatLng homePosition = MapsPageState.homePosition!;
            final Position currentPosition =
                await GetLocation.determinePosition();
            final LatLng currentLatLng =
                LatLng(currentPosition.latitude, currentPosition.longitude);
            MapsPageState.userPath.add(currentLatLng);
            final double distance = Geolocator.distanceBetween(
                homePosition.latitude,
                homePosition.longitude,
                currentPosition.latitude,
                currentPosition.longitude);
            final accuracy = await Geolocator.getLocationAccuracy();
            late int radius;
            if (accuracy == LocationAccuracyStatus.reduced) {
              radius = 5000;
            } else {
              radius = 20;
            }
            if (distance > radius) HomePageState.handleAwayFromhome(context);
          },
        );
      }
    }, onServerSuccess: () {
      HomePageState.cancelEvent();
      return showDialog(
          context: context,
          builder: (context) {
            return TimerError();
          });
    });

    waitingServerNotifier.value = false;
  }
}

class TimerError extends StatefulWidget {
  const TimerError({super.key});

  @override
  State<TimerError> createState() => _TimerErrorState();
}

class _TimerErrorState extends State<TimerError> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 7,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(Icons.warning_amber_rounded),
          ),
          Text("An error occured"),
        ],
      ),
      content: Text(
          "We were unable to connect to the server, please try again.\nIf the error persists, try restarting the app."),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              HomePageState.cancelEvent();
            },
            child: Text(
              "Cancel",
            )),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();

            waitingServerNotifier.tryReconnect(() async {
              await Future.delayed(Duration(seconds: 1));
              if (context.mounted) {
                await TimerHandler.tryStartTimer(context);
              }
              print("waiting: ${waitingServerNotifier.value}");
            });
          },
          child: Text("Try again"),
        )
      ],
    );
  }
}
