import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_return/Visuals/palette.dart';
import 'package:safe_return/Visuals/theme.dart';
import 'package:safe_return/custom_widgets/custom_container_button.dart';
import 'package:safe_return/logic/connection_logic.dart';
import 'package:safe_return/logic/location_logic/get_location.dart';

final ValueNotifier<List<LatLng>> userPathNotifier =
    ValueNotifier(MapsPageState.userPath);

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});
  @override
  State<MapsPage> createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> {
  static LatLng? homePosition;
  static List<Marker> markers = [];
  static List<LatLng> userPath = [];
  bool reConnecting = false;
  ReceivePort port = ReceivePort();
  final MapController _mapController = MapController();

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
        ConnectionLogic.hasInternet(),
        GetLocation.checkLocationPermissions(),
        GetLocation.determinePosition(),
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
                  ConnectionLogic.hasInternet(),
                  GetLocation.determinePosition(),
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
                setState(() {
                  reConnecting = true;
                });

                try {
                  await GetLocation.determinePosition();
                } catch (_) {}
                await Future.delayed(Duration(milliseconds: 500));

                setState(() {
                  reConnecting = false;
                });
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
  }

  Widget _mainBody(Position snapshot) {
    LatLng currentPosition = LatLng(snapshot.latitude, snapshot.longitude);

    // if (GetLocation.homePosition != null) {
    //   markers.add(
    //     Marker(
    //       width: 80.0,
    //       height: 80.0,
    //       point: GetLocation.homePosition!,
    //       child: Icon(
    //         Icons.home,
    //         color: Colors.blue,
    //       ),
    //     ),
    //   );
    // bool closeToHome = Geolocator.distanceBetween(
    //         currentPosition.latitude,
    //         currentPosition.longitude,
    //         Location.homePosition!.latitude,
    //         Location.homePosition!.longitude) <
    //     20;
    // if (closeToHome) {
    //   markers.removeAt(0); //Home and current location don't overlap
    // }
    // }
    print("full path: $userPath");

    return Theme(
      data: Themes.settingsThemeData,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
              initialCenter: currentPosition,
              initialZoom: 15,
              cameraConstraint: const CameraConstraint.containLatitude(),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
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
              MarkerLayer(markers: [
                if (MapsPageState.homePosition != null)
                  Marker(
                    point: MapsPageState.homePosition!,
                    child: Icon(Icons.home_filled),
                  )
              ]),
              CurrentLocationLayer(),
            ],
          ),
          Positioned(
            bottom: 15,
            right: 15,
            child: Column(
              children: [
                FloatingActionButton(
                  elevation: 5,
                  foregroundColor: const Color.fromARGB(255, 82, 101, 114),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(17),
                  ),
                  child: Icon(
                    Icons.home_rounded,
                    size: 30,
                  ),
                  onPressed: () async {
                    if (homePosition != null) {
                      _mapController.move(homePosition!, 15);
                    } else {
                      await noHomePos();
                    }
                  },
                ),
                SizedBox(height: 15),
                FloatingActionButton(
                  elevation: 5,
                  foregroundColor: Colors.blue[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(17),
                  ),
                  child: Icon(
                    Icons.my_location,
                    size: 30,
                  ),
                  onPressed: () async {
                    await GetLocation.determinePosition();
                    _mapController.move(currentPosition, 15);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> noHomePos() {
    return showAdaptiveDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("No home location"),
            content: Text(
                "You don't currently have a set home location. \nYou can set it in the app settings."),
            actions: [
              //? i can't be bothered to implement this right now
              // TextButton(
              //   onPressed: () {},
              //   style: TextButton.styleFrom(
              //     padding: EdgeInsets.zero,
              //     minimumSize: Size(0, 0),
              //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              //   ),
              //   child: Text(
              //     'Bring me there',
              //     style: TextStyle(
              //       color: Colors.blue,
              //     ),
              //   ),
              // ),

              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Ok")),
            ],
          );
        });
  }
}
