import 'package:flutter/material.dart';
import 'package:safe_return/logic/location.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: Location.determinePosition(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          throw snapshot.error!;
        } else {
          return Center(child: Text(snapshot.data!.toString()));
        }
      },
    ));
  }
}
