import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_return/Visuals/palette.dart';
import 'package:safe_return/custom_widgets/custom_container_button.dart';
import 'package:safe_return/logic/location_logic/location.dart';
import 'package:safe_return/utils/connection.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';

final ValueNotifier<List<LatLng>> userPathNotifier =
    ValueNotifier(MapsPageState.userPath);

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});
  @override
  State<MapsPage> createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> {
  static List<LatLng> userPath = [];
  bool reConnecting = false;
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
        Connection.hasInternet(),
        Location.checkLocationPermissions(),
        Location.determinePosition(),
      ]),
      builder: (context, snapshot) {
        if (reConnecting) {
          return Center(child: CircularProgressIndicator.adaptive());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator.adaptive());
        } else if (snapshot.hasError ||
            !snapshot.hasData ||
            snapshot.data == null) {
          return locationError();
        }
        final internetAvailable = snapshot.data![0] as bool;
        final position = snapshot.data![2] as Position;

        if (!internetAvailable) {
          return noInternet();
        } else if (snapshot.hasData) {
          return _mainBody(position);
        } else {
          throw Exception("No location returned");
        }
      },
    ));
  }

  Widget noInternet() {
    return Center(
      child: Column(
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
  }

  Widget locationError() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 30),
                  Text(
                    "An error occurred",
                    style: TextStyle(fontSize: 23),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Check that your location permission is set to "Always".',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'You can request permission with the button below.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              TextButton(
                  onPressed: () async {
                    await Location.checkLocationPermissions();
                  },
                  child: Text(
                    "Request Permission",
                    style: TextStyle(fontSize: 16),
                  )),
              SizedBox(height: 50),
              Text(
                textAlign: TextAlign.center,
                '''
If that doesn't work, change the location permission to "Always" in settings''',
                style: TextStyle(fontSize: 16),
              ),
              TextButton(
                  onPressed: () async {
                    await Geolocator.openLocationSettings();
                  },
                  child: Text(
                    "Open settings",
                    style: TextStyle(fontSize: 16),
                  ))
            ],
          ),
        ),
        TapBounceContainer(
            onTap: () async {
              setState(() {
                reConnecting = true;
              });

              try {
                await Location.determinePosition();
              } catch (_) {}
              await Future.delayed(Duration(milliseconds: 500));

              setState(() {
                reConnecting = false;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
              child: SizedBox(
                height: 40,
                child: TapContainerBuild(
                  color: Palette.blue3,
                  child: Text(
                    "Try Again",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ))
      ],
    ));
  }

  Widget _mainBody(Position snapshot) {
    LatLng currentPosition = LatLng(snapshot.latitude, snapshot.longitude);
    List<Marker> markers = [];

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
      // bool closeToHome = Geolocator.distanceBetween(
      //         currentPosition.latitude,
      //         currentPosition.longitude,
      //         Location.homePosition!.latitude,
      //         Location.homePosition!.longitude) <
      //     20;
      // if (closeToHome) {
      //   markers.removeAt(0); //Home and current location don't overlap
      // }
    }
    print("full path: ${userPath}");

    return FlutterMap(
      options: MapOptions(
        interactionOptions: InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
        initialCenter: currentPosition,
        initialZoom: 15,
        cameraConstraint: const CameraConstraint.containLatitude(),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),

        ValueListenableBuilder<List<LatLng>>(
          valueListenable: userPathNotifier,
          builder: (context, path, _) {
            return PolylineLayer(
              polylines: [
                Polyline(
                  strokeWidth: 4,
                  points: path.isNotEmpty
                      ? path
                      : [
                          currentPosition,
                        ],
                  color: Colors.blue,
                ),
              ],
            );
          },
        ),
        MarkerLayer(markers: markers),

        CurrentLocationLayer(),
        // MarkerLayer(markers: markers),
      ],
    );
  }
}
