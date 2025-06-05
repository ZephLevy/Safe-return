// ignore_for_file: unnecessary_null_comparison

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_return/logic/location.dart';
import 'package:safe_return/utils/noti_service.dart';
import 'package:safe_return/utils/sos_manager.dart';
import 'package:safe_return/utils/time_manager.dart';
import 'package:safe_return/Visuals/palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

final ValueNotifier<bool> isCancelableNotifier = ValueNotifier(false);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: SosButton(
        onTap: () => sosClicked(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TimerAndClock(),
            SizedBox(height: 8),
            TimeSetButton(),
          ],
        ),
      ),
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

class TimerAndClock extends StatefulWidget {
  const TimerAndClock({super.key});

  @override
  State<TimerAndClock> createState() => _TimerAndClockState();
}

class _TimerAndClockState extends State<TimerAndClock>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: AnimatedSize(
        duration: Duration(milliseconds: 100),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Palette.blue1,
                  width: 1.5,
                ),
              ),
            ),
            Column(
              children: [
                _bhb(),
                ValueListenableBuilder<bool>(
                    valueListenable: isCancelableNotifier,
                    builder: (context, isCancelable, child) {
                      return Container(
                        child: isCancelableNotifier.value
                            ? _timer()
                            : _timeSetter(),
                      );
                    })
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bhb() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          // color: Palette.blue1,
          color: const Color.fromARGB(255, 77, 30, 30),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          isCancelableNotifier.value ? 'You must be home by:' : 'Be Home By:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _timeSetter() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        height: 150,
        child: CupertinoDatePicker(
          onDateTimeChanged: (value) {
            TimeManager.selectedTime = value;
          },
          mode: CupertinoDatePickerMode.time,
          use24hFormat: true,
        ),
      ),
    );
  }

  Widget _timer() {
    final CountDownController timerController = CountDownController();
    TimeManager.timerCalculations();
    return Padding(
      padding: const EdgeInsets.all(40),
      child: CircularCountDownTimer(
        duration: TimeManager.timeUntilInSeconds,
        initialDuration: 0,
        controller: timerController,
        width: 200, //TODO get screen height
        height: 200,
        ringColor: Colors.grey,
        fillColor: Colors.orange,
        backgroundColor: Colors.white,
        strokeWidth: 10,
        strokeCap: StrokeCap.round,
        textStyle: TextStyle(fontSize: 24),
        isReverse: true,
        isReverseAnimation: true,
      ),
    );
  }
}

class TimeSetButton extends StatefulWidget {
  const TimeSetButton({super.key});

  @override
  State<TimeSetButton> createState() => TimeSetButtonState();
}

class TimeSetButtonState extends State<TimeSetButton> {
  bool validTime = false;
  bool updateSelected = false;
  bool startSelected = false;
  bool timeIsSet = false;
  DateTime date = DateTime.now();
  static int codeAttempts = 3;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double adjustedScreenWidth = screenWidth - (8 * 2);
    double spaceBetweenButtons = adjustedScreenWidth / 10;
    return SizedBox(
      height: 60,
      child: Row(
        children: [
          //The left button - to update the time
          Material(
              child: IgnorePointer(
            ignoring: !isCancelableNotifier.value,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  updateSelected = !updateSelected;
                });
                checkValidTime(context);
              },
              onTapDown: (details) {
                setState(() {
                  updateSelected = true;
                });
              },
              onTapUp: (details) {
                setState(() {
                  updateSelected = !updateSelected;
                });
              },
              onTapCancel: () {
                setState(() {
                  updateSelected = false;
                });
              },
              child: Stack(
                children: [
                  Container(
                    width:
                        (adjustedScreenWidth / 2) - (spaceBetweenButtons / 2),
                    margin: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Palette.blue1,
                        width: 1.5,
                      ),
                      color: (updateSelected ? Palette.blue3 : Palette.blue4),
                    ),
                    child: Center(
                      child: AutoSizeText(
                        "Update Time",
                        maxLines: 2,
                        minFontSize: 14,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width:
                        (adjustedScreenWidth / 2) - (spaceBetweenButtons / 2),
                    decoration: BoxDecoration(
                        color: isCancelableNotifier.value
                            ? Colors.transparent
                            : Colors.white30),
                  )
                ],
              ),
            ),
          )),
          SizedBox(width: spaceBetweenButtons),
          //Right button - to start and cancel the time
          Material(
            child: GestureDetector(
              onTap: () {
                if (isCancelableNotifier.value == true) {
                  cancelEvent();
                } else if (isCancelableNotifier.value == false) {
                  checkValidTime(context);
                  print("duration: ${TimeManager.timeUntilInSeconds}");
                }
              },
              onTapDown: (details) {
                setState(() {
                  startSelected = true;
                });
              },
              onTapUp: (details) {
                setState(() {
                  validTime ? startSelected = true : startSelected = false;
                });
              },
              onTapCancel: () {
                setState(() {
                  !isCancelableNotifier.value
                      ? startSelected = false
                      : startSelected = true;
                });
              },
              child: Container(
                width: (adjustedScreenWidth / 2) - (spaceBetweenButtons / 2),
                margin: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Palette.blue1,
                    width: 1.5,
                  ),
                  color: startSelected ? Palette.blue3 : Palette.blue4,
                ),
                child: Center(
                  child: Text(
                    startSelected ? 'Cancel' : 'Set Time',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void cancelEvent() {
    setState(() {
      isCancelableNotifier.value = false;
      startSelected = false;
      TimeManager.now = DateTime.now();
      TimeManager.selectedTime = DateTime.now();
    });
  }

  void checkValidTime(BuildContext context) {
    Future.delayed(
      Duration(seconds: 5),
      () async {
        setState(
          () {
            date = TimeManager.selectedTime;
            codeAttempts = 3;
          },
        );
        _scheduleCheck();
        HapticFeedback.mediumImpact();
      },
    );

    // This makes me not want to open source this project purely out of shame
    var timesAreDifferent = (TimeManager.selectedTime != null)
        ? !((TimeManager.selectedTime.hour == DateTime.now().hour &&
            (TimeManager.selectedTime.minute == DateTime.now().minute)))
        : false;
    bool codesNull =
        SosManager.fakeCode == null || SosManager.secretCode == null;

    validTimecheck(timesAreDifferent, codesNull, context);
  }

  void validTimecheck(
      bool timesAreDifferent, bool codesNull, BuildContext context) {
    if (timesAreDifferent && !codesNull) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SnackBarContent(),
          duration: Duration(seconds: 5, milliseconds: 100),
        ),
      );
      TimeManager.timerCalculations();
      setState(() {
        isCancelableNotifier.value = true;
        validTime = true;
        startSelected = true;
      });
    } else if (!timesAreDifferent || !codesNull) {
      setState(() {
        validTime = false;
        startSelected = false;
        isCancelableNotifier.value = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text("Please select a time that is not now!"),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text("Please configure your codes in the settings page"),
          ),
        ),
      );
    }
  }

  void _scheduleCheck() {
    _sendTime(date);
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
      if (distance > radius) _handleAwayFromhome();
    });
  }

  Future<void> _sendTime(DateTime time) async {
    // IMPORTANT: Use "flutter run --dart-define=IP=[ip]" to set this before running
    // ALSO IMPORTANT: @Grayerhack700 if you don't use nginx then specify port 8080 (eg. localhost:8080)
    // If you are using nginx then it *should* default to port 80
    const String ip = String.fromEnvironment('IP');

    if (ip == "") {
      print("No ip passed to CLI when run");
      return;
    }
    Uri url = Uri.parse('http://$ip/setTime');
    final response = await http.post(url, body: {'time': date.toString()});
    if (response.statusCode == 200) {
      print('Success: ${response.body}');
    } else {
      print('Failed with status: ${response.statusCode}');
    }
  }

  void _handleAwayFromhome() {
    NotiService().notHomeNotif();
    TextEditingController textController = TextEditingController();
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, timeSetButtonState) => AlertDialog(
            title: Text(
              "It looks like you're away from your home. Enter your code:",
            ),
            content: TextField(
              controller: textController,
              decoration: InputDecoration(
                  hintText: "You have $codeAttempts attempts left"),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  String text = textController.text;
                  bool canPop = Navigator.canPop(context);
                  if (text == SosManager.fakeCode) {
                    alert();
                    if (canPop) Navigator.pop(context);
                    return;
                  } else if (text == SosManager.secretCode) {
                    if (canPop) Navigator.pop(context);
                    return;
                  }

                  // Got code wrong
                  textController.clear();
                  timeSetButtonState(() => codeAttempts--);

                  if (codeAttempts <= 0) {
                    alert();
                    if (canPop) Navigator.pop(context);
                  }
                },
                child: Text("Enter"),
              ),
            ],
          ),
        );
      },
    );
  }

  static void alert() {
    //This is called when we are sure the user is in danger.
    //TODO: implement something
    print("alerted");
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
