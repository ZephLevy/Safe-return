import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_return/Visuals/theme.dart';
import 'package:safe_return/logic/global_vars.dart';
import 'package:safe_return/logic/internet_error.dart';
import 'package:safe_return/logic/location_logic/location_error.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});
  @override
  State<MapsPage> createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> {
  static LatLng? homePosition;
  static List<Marker> markers = [];
  static List<LatLng> userPath = [];
  ReceivePort port = ReceivePort();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    currentPositionNotifier.init();
  }

  @override
  void dispose() {
    super.dispose();
    currentPositionNotifier.stop();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: isOnlineNotifier,
        builder: (context, isOnline, child) {
          return ValueListenableBuilder(
            valueListenable: reconnectingNotifier,
            builder: (context, reConnecting, child) {
              return ValueListenableBuilder<Position?>(
                valueListenable: currentPositionNotifier,
                builder: (context, currentPosition, child) {
                  if (currentPositionNotifier.hasError) {
                    return LocationError();
                  }
                  if (reConnecting || currentPosition == null) {
                    return Center(child: CircularProgressIndicator.adaptive());
                  }

                  if (!isOnline) {
                    return InternetError();
                  } else {
                    return _mainBody(LatLng(
                        currentPosition.latitude, currentPosition.longitude));
                  }
                },
              );
            },
          );
        });
  }

  Widget _mainBody(LatLng currentPosition) {
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
        barrierDismissible: true,
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
