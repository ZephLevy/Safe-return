import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_return/logic/location.dart';
import 'package:safe_return/utils/connection.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});
  @override
  State<MapsPage> createState() => MapsPageState();
}

class MapsPageState extends State<MapsPage> {
  bool reConnecting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future:
          Future.wait([Location.determinePosition(), Connection.hasInternet()]),
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
    LatLng position = LatLng(snapshot.latitude, snapshot.longitude);
    List<Marker> markers = [
      Marker(
        width: 80.0,
        height: 80.0,
        point: position,
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
              position.latitude,
              position.longitude,
              Location.homePosition!.latitude,
              Location.homePosition!.longitude) <
          20;
      if (closeToHome) {
        markers.removeAt(0); //Home and current location don't overlap
      }
    }

    return FlutterMap(
      options: MapOptions(initialCenter: position, initialZoom: 20),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
