import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator_2/location_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_return/logic/location_logic/location.dart';
import 'package:safe_return/logic/location_logic/location_updater.dart';
import 'package:safe_return/storage.dart/user_path_storage.dart';
import 'package:safe_return/utils/connection.dart';

final ValueNotifier<List<LatLng>> userPathNotifier =
    ValueNotifier(MapsPageState.userPath);

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});
  @override
  State<MapsPage> createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> {
  bool reConnecting = false;
  static List<LatLng> userPath = [];
  ReceivePort port = ReceivePort();

  // @override
  // void initState() {
  //   super.initState();

  //   IsolateNameServer.registerPortWithName(
  //       port.sendPort, LocationServiceRepository.isolateName);

  //   port.listen((dynamic data) {
  //     print("listened for data: $data");
  //     if (data != null) {
  //       final dto = LocationDto.fromJson(Map<String, dynamic>.from(data));
  //       final currentPos = LatLng(dto.latitude, dto.longitude);
  //       userPathNotifier.value = [...userPathNotifier.value, currentPos];
  //       UserPathStorage.saveLocationData(userPathNotifier.value);
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: Future.wait([
        Location.determinePosition(),
        Connection.hasInternet(),
        UserPathStorage.loadLocationData()
      ]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator.adaptive());
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Center(
            child: reConnecting
                ? CircularProgressIndicator.adaptive()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 30),
                      Text("An error occured"),
                      TextButton(
                          onPressed: (() async {
                            setState(() {
                              reConnecting = true;
                            });

                            await Future.wait([
                              Connection.hasInternet(),
                              Location.determinePosition(),
                              Future.delayed(Duration(seconds: 1))
                            ]);

                            setState(() {
                              reConnecting = false;
                            });
                          }),
                          child: Text("Try Again"))
                    ],
                  ),
          );
        }

        final position = snapshot.data![0] as Position;
        final internetAvailable = snapshot.data![1] as bool;

        if (snapshot.hasError || !internetAvailable) {
          return Center(
            child: reConnecting
                ? CircularProgressIndicator.adaptive()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 30),
                      Text("No internet connection"),
                      TextButton(
                          onPressed: (() async {
                            setState(() {
                              reConnecting = true;
                            });
                            await Future.wait([
                              Connection.hasInternet(),
                              Location.determinePosition(),
                              Future.delayed(Duration(seconds: 1))
                            ]);

                            setState(() {
                              reConnecting = false;
                            });
                          }),
                          child: Text("Try Again"))
                    ],
                  ),
          );
        } else if (snapshot.hasData) {
          return _mainBody(position);
        } else {
          throw Exception("No location returned");
        }
      },
    ));
  }

  Widget _mainBody(Position snapshot) {
    LatLng currentPosition = LatLng(snapshot.latitude, snapshot.longitude);
    List<Marker> markers = [
      Marker(
        width: 80.0,
        height: 80.0,
        point: currentPosition,
        child: Icon(Icons.location_pin, color: Colors.red),
      ),
    ];

    if (Location.homePosition != null) {
      markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: Location.homePosition!,
          child: Icon(
            Icons.home,
            color: Colors.blue,
          ),
        ),
      );
      bool closeToHome = Geolocator.distanceBetween(
              currentPosition.latitude,
              currentPosition.longitude,
              Location.homePosition!.latitude,
              Location.homePosition!.longitude) <
          20;
      if (closeToHome) {
        markers.removeAt(0); //Home and current location don't overlap
      }
    }
    print("full path: ${userPath}");
    return ValueListenableBuilder<List<LatLng>>(
      valueListenable: userPathNotifier,
      builder: (context, path, _) {
        return FlutterMap(
          options: MapOptions(
            interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
            initialCenter: currentPosition,
            initialZoom: 15,
            keepAlive: true,
            cameraConstraint: const CameraConstraint.containLatitude(),
            // interactionOptions:
            //     InteractionOptions(flags: ~InteractiveFlag.rotate)
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),

            PolylineLayer(
              polylines: [
                Polyline(
                  strokeWidth: 4,
                  points: path.isNotEmpty
                      ? path
                      : [
                          currentPosition,
                        ],
                  // points: [
                  //   LatLng(37.332331, -122.031219),
                  //   LatLng(37.332331, -122.031219),
                  //   LatLng(37.332331, -122.031219),
                  //   LatLng(37.332331, 122.031219)
                  // ],
                  color: Colors.blue,
                ),
              ],
            ),

            CurrentLocationLayer(),
            // MarkerLayer(markers: markers),
          ],
        );
      },
    );
  }
}
