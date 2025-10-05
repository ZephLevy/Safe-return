import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_return/Visuals/palette.dart';
import 'package:safe_return/custom_widgets/custom_container_button.dart';
import 'package:safe_return/logic/location_logic/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';

class HomeSelector extends StatefulWidget {
  const HomeSelector({super.key});

  @override
  State<HomeSelector> createState() => _HomeSelectorState();
}

enum HomeType { location, address, map }

class _HomeSelectorState extends State<HomeSelector> {
  bool reConnecting = false;
  static HomeType homeSelectionType = HomeType.location;
  int addingStep = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Set Home Location"),
        ),
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: switch (addingStep) {
            1 => step1(context),
            2 => step2(),
            3 => step3(),
            _ => Placeholder(),
          },
        ));
  }

  Widget step1(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                  "This is where you can set your home location. We need it to know when you are back home. Without it, we cannot check if you are safe."),
              SizedBox(height: 15),
              Text(
                  "Select which method you would like to set your home location with:"),
              Column(
                children: [
                  RadioListTile.adaptive(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      title: Text("Use current location"),
                      secondary: Icon(Icons.location_pin),
                      value: HomeType.location,
                      groupValue: homeSelectionType,
                      onChanged: (value) {
                        setState(() {
                          homeSelectionType = value!;
                        });
                      }),
                  Divider(height: 0),
                  RadioListTile.adaptive(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      title: Text("Input your address"),
                      secondary: Icon(Icons.text_fields),
                      value: HomeType.address,
                      groupValue: homeSelectionType,
                      onChanged: (value) {
                        setState(() {
                          homeSelectionType = value!;
                        });
                      }),
                  Divider(height: 0),
                  RadioListTile.adaptive(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      title: Text("Select on map"),
                      secondary: Icon(Icons.map),
                      value: HomeType.map,
                      groupValue: homeSelectionType,
                      onChanged: (value) {
                        setState(() {
                          homeSelectionType = value!;
                        });
                      }),
                ],
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 65),
            child: SizedBox(
              height: 50,
              child: CustomInkwell(
                borderRadius: BorderRadius.circular(25),
                color: Colors.lightBlue,
                onTap: () {
                  setState(() {
                    addingStep += 1;
                  });
                },
                child: Text(
                  "Next",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget step2() {
    return switch (homeSelectionType) {
      HomeType.location => useLocation(),
      HomeType.address => useAddress(),
      HomeType.map => useMap(),
    };
  }

  Widget useLocation() {
    return FutureBuilder(
        future: Location.determinePosition(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator.adaptive());
          } else if (snapshot.hasError ||
              snapshot.data == null ||
              !snapshot.hasData) {
            return locationError();
          } else {
            final position = snapshot.data!;
            LatLng currentPosition =
                LatLng(position.latitude, position.longitude);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        "This location will be marked as your home:",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(
                        height: 400,
                        child: FlutterMap(
                          options: MapOptions(
                            minZoom: 4,
                            maxZoom: 20,
                            interactionOptions: InteractionOptions(
                                flags: InteractiveFlag.pinchZoom),
                            initialCenter: currentPosition,
                            initialZoom: 15,
                            cameraConstraint:
                                const CameraConstraint.containLatitude(),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            ),
                            CircleLayer(
                              circles: [
                                CircleMarker(
                                    point: LatLng(currentPosition.latitude,
                                        currentPosition.longitude),
                                    useRadiusInMeter: true,
                                    radius: 100,
                                    color:
                                        const Color.fromARGB(178, 33, 149, 243),
                                    borderColor:
                                        Color.fromARGB(231, 23, 103, 168),
                                    borderStrokeWidth: 5)
                              ],
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: LatLng(
                                      currentPosition.latitude + 0.00001,
                                      currentPosition.longitude),
                                  child: Icon(Icons.location_pin),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text("Pinch to zoom in and out")
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 65),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      spacing: 20,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: CustomInkwell(
                              borderRadius: BorderRadius.circular(25),
                              color: const Color.fromARGB(255, 107, 192, 232),
                              onTap: () {
                                setState(() {
                                  addingStep -= 1;
                                });
                              },
                              child: Text(
                                "Back",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: CustomInkwell(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.lightBlue,
                              onTap: () {
                                _setHomeLocation(currentPosition);
                                setState(() {
                                  addingStep += 1;
                                });
                              },
                              child: Text(
                                "Next",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        });
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

  Widget useAddress() {
    return Placeholder();
  }

  Widget useMap() {
    return Placeholder();
  }

  Widget step3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "All Set!",
                  style: TextStyle(fontSize: 27),
                ),
                Text("You can view your home location in the map page."),
              ],
            ),
          ),
          SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.only(bottom: 65),
            child: SizedBox(
              height: 50,
              child: CustomInkwell(
                borderRadius: BorderRadius.circular(25),
                color: Colors.lightBlue,
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Done",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setHomeLocation(LatLng currentPosition) async {
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    Location.homePosition = currentPosition;

    await asyncPrefs.setDouble("latitude", currentPosition.latitude);
    await asyncPrefs.setDouble("longitude", currentPosition.longitude);
  }
}
