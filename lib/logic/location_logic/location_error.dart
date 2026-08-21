import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safe_return/Visuals/palette.dart';
import 'package:safe_return/custom_widgets/custom_container_button.dart';
import 'package:safe_return/logic/global_vars.dart';

class LocationError extends StatefulWidget {
  const LocationError({super.key});

  @override
  State<LocationError> createState() => _LocationErrorState();
}

class _LocationErrorState extends State<LocationError> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: reconnectingNotifier,
        builder: (context, reConnecting, child) {
          if (reConnecting) {
            return Center(child: CircularProgressIndicator.adaptive());
          }
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 70),
                    Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 31),
                        Text(
                          "An error occurred",
                          style: TextStyle(fontSize: 24),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    Text(
                      'Check that your location permission is set to "Always".',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      "You can change the permission in the app settings",
                      style: TextStyle(fontSize: 16),
                    ),
                    TextButton(
                      onPressed: () async {
                        await Geolocator.openLocationSettings();
                      },
                      child: Text(
                        "Open settings",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                child: SizedBox(
                  height: 40,
                  child: ShrinkTapContainer(
                    onTap: () async {
                      currentPositionNotifier.stop();

                      print("reconnecting");
                      reconnectingNotifier.tryReconnect(
                        () async {
                          await currentPositionNotifier.init();
                          await Future.delayed(Duration(seconds: 1));
                        },
                      );
                    },
                    color: Palette.blue3,
                    child: Text(
                      "Try Again",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              )
            ],
          ));
        });
  }
}
