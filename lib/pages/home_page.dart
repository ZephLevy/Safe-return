import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_return/logic/location.dart';
import 'package:safe_return/utils/sos_manager.dart';
import 'package:safe_return/utils/time_manager.dart';
import 'package:safe_return/palette.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SosButton(
        onTap: () => sosClicked(),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _timeSetter(),
          TimeSetButton(),
        ],
      ),
    );
  }

  Widget _timeSetter() {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Palette.blue1,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              'Be Home By:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Palette.blue1,
              width: 1.5,
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 200,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                height: 150,
                child: CupertinoDatePicker(
                  onDateTimeChanged: (value) {
                    TimeManager.selectedTime = value;
                  },
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  void sosClicked() {
    HapticFeedback.heavyImpact();
    print("Sos button registered a click!");
  }
}

class SosButton extends StatefulWidget {
  final Function onTap;
  final Duration tapTimeThreshold;

  const SosButton({
    required this.onTap,
    this.tapTimeThreshold = const Duration(milliseconds: 500),
    super.key,
  });

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> {
  Timer? _tapTimer;
  int _tapCount = 0;

  void _handleTapUp(TapUpDetails details) {
    int tapN = SosManager.clickN;
    if (_tapTimer != null && _tapTimer!.isActive) {
      _tapCount++;
    } else {
      _tapCount = 1;
    }

    _tapTimer?.cancel();

    _tapTimer = Timer(widget.tapTimeThreshold, () {
      if (_tapCount >= tapN) {
        widget.onTap();
      }
      _tapCount;
    });
  }

  @override
  void dispose() {
    _tapTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 96,
      height: 96,
      child: Material(
        color: Color(0xffde001a),
        shape: CircleBorder(
          side: BorderSide(
            color: Palette.blue2,
            width: 2,
          ),
        ),
        child: InkWell(
          customBorder: CircleBorder(),
          onTapUp: (details) => _handleTapUp(details),
          child: Icon(
            Icons.sos,
            size: 55,
            color: Color(0xfffef5ff),
          ),
        ),
      ),
    );
  }
}

class TimeSetButton extends StatefulWidget {
  const TimeSetButton({super.key});

  @override
  State<TimeSetButton> createState() => _TimeSetButtonState();
}

class _TimeSetButtonState extends State<TimeSetButton> {
  bool isSelected = false;
  DateTime date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: Material(
        child: GestureDetector(
          onTap: () {
            Future.delayed(Duration(seconds: 5), () async {
              if (TimeManager.selectedTime != null) {
                setState(() {
                  date = TimeManager.selectedTime!;
                });
                _scheduleCheck();
                HapticFeedback.mediumImpact();
              }
            });
            setState(() {
              isSelected = false;
            });

            // This makes me not want to open source this project purely out of shame
            var timesAreDifferent = (TimeManager.selectedTime != null)
                ? !((TimeManager.selectedTime!.hour == DateTime.now().hour &&
                    (TimeManager.selectedTime!.minute ==
                        DateTime.now().minute)))
                : false;

            if (TimeManager.selectedTime != null && timesAreDifferent) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: SnackBarContent(),
                  duration: Duration(seconds: 5, milliseconds: 100),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Center(
                    child: Text("Please select a time that is not now!"),
                  ),
                ),
              );
            }
          },
          onTapDown: (details) {
            setState(() {
              isSelected = true;
            });
          },
          child: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Palette.blue1,
                width: 1.5,
              ),
              color: isSelected ? Palette.blue3 : Palette.blue4,
            ),
            child: SizedBox.expand(
              child: Center(
                child: Text(
                  'Set',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _scheduleCheck() {
    Duration timeTo = date.difference(DateTime.now());
    Future.delayed(timeTo, () async {
      if (Location.homePosition == null) return;
      final LatLng homePosition = Location.homePosition!;
      final Position currentPosition = await Location.determinePosition();
      final double distance = Geolocator.distanceBetween(
          homePosition.latitude,
          homePosition.longitude,
          currentPosition.latitude,
          currentPosition.longitude);
      final accuracy = await Geolocator.getLocationAccuracy();
      late int radius;
      if (accuracy == LocationAccuracyStatus.reduced) {
        radius = 5000;
      } else {
        radius = 20;
      }
      if (distance > radius) _alert();
    });
  }

  void _alert() {
    print("Alerted");
  }
}

class SnackBarContent extends StatefulWidget {
  const SnackBarContent({
    super.key,
  });

  @override
  State<SnackBarContent> createState() => _SnackBarContentState();
}

class _SnackBarContentState extends State<SnackBarContent> {
  final List<String> loadingStates = [
    "Setting Event",
    "Setting Event.",
    "Setting Event..",
    "Setting Event..."
  ];
  int index = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      Duration(milliseconds: 250),
      (timer) {
        if (mounted) {
          setState(
            () {
              index = (index + 1) %
                  loadingStates
                      .length; //This loops index over the possible list values
            },
          );
        }
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(loadingStates[index]));
  }
}
