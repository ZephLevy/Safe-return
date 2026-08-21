import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_return/Visuals/palette.dart';
import 'package:safe_return/custom_widgets/custom_container_button.dart';
import 'package:safe_return/logic/location_logic/get_location.dart';
import 'package:safe_return/pages/main_pages/map_page.dart';

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
    return Scaffold(
        body: Padding(
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
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
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
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
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
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
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
            ],
          ),
        ),
        bottomNavigationBar: singleBottomButton("Next"));
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
      future: GetLocation.determinePosition(),
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
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SafeArea(
                top: false,
                child: Column(
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
                          initialZoom: 17,
                          cameraConstraint:
                              const CameraConstraint.containLatitude(),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                            subdomains: const ['a', 'b', 'c', 'd'],
                          ),
                          CircleLayer(
                            circles: [
                              CircleMarker(
                                point: LatLng(currentPosition.latitude,
                                    currentPosition.longitude),
                                useRadiusInMeter: true,
                                radius: 100,
                                //TODO make sure the radius is the same as the logic radius in home_page line 616
                                color: const Color.fromARGB(178, 33, 149, 243),
                                borderColor: Color.fromARGB(231, 23, 103, 168),
                                borderStrokeWidth: 2,
                              )
                            ],
                          ),
                          CurrentLocationLayer(),
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
              ),
            ),
            bottomNavigationBar:
                backNextButtons(currentPosition: currentPosition),
          );
        }
      },
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
                    await GetLocation.checkLocationPermissions();
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

  Widget useAddress() {
    TextEditingController streetController = TextEditingController();
    // ignore: unused_local_variable
    TextEditingController cityController = TextEditingController();
    // ignore: unused_local_variable
    TextEditingController postalController = TextEditingController();
    // ignore: unused_local_variable
    TextEditingController countryController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Text(
                textAlign: TextAlign.center,
                "The address you input will be set as your home location",
                softWrap: true,
              ),
              SizedBox(height: 20),
              TextField(
                controller: streetController,
                autofillHints: [AutofillHints.streetAddressLine1],
                decoration: InputDecoration(
                  labelText: "Street",
                  contentPadding: EdgeInsets.only(left: 7),
                ),
              ),
              Row(
                children: [
                  TextField(
                    controller: streetController,
                    autofillHints: [AutofillHints.streetAddressLine1],
                    decoration: InputDecoration(
                      labelText: "Street",
                      contentPadding: EdgeInsets.only(left: 7),
                    ),
                  ),
                  TextField(
                    controller: streetController,
                    autofillHints: [AutofillHints.streetAddressLine1],
                    decoration: InputDecoration(
                      labelText: "Street",
                      contentPadding: EdgeInsets.only(left: 7),
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  void decodeAddress({required String address}) {
    decodeAddress(address: address);
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
              child: InkwellContainer(
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

  Widget singleBottomButton(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: InkwellContainer(
              borderRadius: BorderRadius.circular(25),
              color: Colors.lightBlue,
              onTap: () {
                setState(() {
                  addingStep += 1;
                });
              },
              child: Text(
                text,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget backNextButtons({LatLng? currentPosition}) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 25,
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: InkwellContainer(
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
                child: InkwellContainer(
                  borderRadius: BorderRadius.circular(25),
                  color: Colors.lightBlue,
                  onTap: () async {
                    MapsPageState.homePosition = currentPosition;
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
    );
  }
}
