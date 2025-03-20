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
        body: FutureBuilder(
      future: Location.determinePosition(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("${snapshot.error}"));
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          return _mainBody(snapshot.data!);
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
