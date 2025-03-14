import 'package:flutter/material.dart';
import 'package:safe_return/logic/location.dart';

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
                  return Center(child: Text(snapshot.data.toString()));
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
}
