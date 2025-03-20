import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_return/logic/location.dart';
import 'package:flutter_map/flutter_map.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (Location.lastKnownPosition == null)
          ? FutureBuilder(
              future: Location.determinePosition(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("${snapshot.error}"));
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData) {
                  return _mainBody(snapshot.data!);
                } else {
                  throw Exception("No location returned");
                }
              },
            )
          : Center(
              child: Text(Location.lastKnownPosition.toString()),
            ),
    );
  }

  Widget _mainBody(Position snapshot) {
    var position = LatLng(snapshot.latitude, snapshot.longitude);
    return FlutterMap(
      options: MapOptions(initialCenter: position, initialZoom: 20),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: position,
              child: Icon(Icons.location_pin, color: Colors.red),
            ),
          ],
        ),
      ],
    );
  }
}
