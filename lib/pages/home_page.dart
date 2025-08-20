import 'dart:async';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:safe_return/Visuals/palette.dart';
import 'package:safe_return/logic/location.dart';
import 'package:safe_return/logic/timer_logic.dart';
import 'package:safe_return/shared_prefs/stored_settings.dart';
import 'package:safe_return/shared_prefs/timer_prefs.dart';
import 'package:safe_return/utils/connection.dart';
import 'package:safe_return/utils/noti_service.dart';
import 'package:safe_return/utils/sos_manager.dart';
import 'package:safe_return/utils/time_manager.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: SosButton(
      //   onTap: () => sosClicked(),
      // ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TimerAndClock(),
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

class HomeTimer extends StatefulWidget {
  final CountDownController timerController;

  final VoidCallback onTimerComplete;
  const HomeTimer({
    super.key,
    required this.timerController,
    required this.onTimerComplete,
  });

  @override
  State<HomeTimer> createState() => _HomeTimerState();
}

class SnackBarContent extends StatefulWidget {
  const SnackBarContent({
    super.key,
  });

  @override
  State<SnackBarContent> createState() => _SnackBarContentState();
}

// class SosButton extends StatefulWidget {
//   final Function onTap;
//   final Duration tapTimeThreshold;

//   const SosButton({
//     required this.onTap,
//     this.tapTimeThreshold = const Duration(milliseconds: 500),
//     super.key,
//   });

//   @override
//   State<SosButton> createState() => _SosButtonState();
// }

// class _SosButtonState extends State<SosButton> {
//   Timer? _tapTimer;
//   int _tapCount = 0;

//   void _handleTapUp(TapUpDetails details) {
//     int tapN = SosManager.clickN;
//     if (_tapTimer != null && _tapTimer!.isActive) {
//       _tapCount++;
//     } else {
//       _tapCount = 1;
//     }

//     _tapTimer?.cancel();

//     _tapTimer = Timer(widget.tapTimeThreshold, () {
//       if (_tapCount >= tapN) {
//         widget.onTap();
//       }
//       _tapCount;
//     });
//   }

//   @override
//   void dispose() {
//     _tapTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 96,
//       height: 96,
//       child: Material(
//         color: Color(0xffde001a),
//         shape: CircleBorder(
//           side: BorderSide(
//             color: Palette.blue2,
//             width: 2,
//           ),
//         ),
//         child: InkWell(
//           customBorder: CircleBorder(),
//           onTapUp: (details) => _handleTapUp(details),
//           child: Icon(
//             Icons.sos,
//             size: 55,
//             color: Color(0xfffef5ff),
//           ),
//         ),
//       ),
//     );
//   }
// }

class TimerAndClock extends StatefulWidget {
  const TimerAndClock({super.key});

  @override
  State<TimerAndClock> createState() => TimerAndClockState();
}

class TimerAndClockState extends State<TimerAndClock>
    with TickerProviderStateMixin {
  static Timer? awayTimer;
  static bool showTimer = false;
  static bool firstLoad = false;
  static bool startSelected = false;

  // DateTime date = DateTime.now();
  static int codeAttempts = 3;
  bool waitingServerResponse = false;
  final CountDownController timerController = CountDownController();
  final GlobalKey mainContainerKey = GlobalKey();
  final GlobalKey bHBkey = GlobalKey();

  Duration animationDuration = Duration(milliseconds: 200);
  Curve animationCurve = Curves.easeOut;
  bool timeIsSet = false;

  double bHBHeight = 52.75;
  double setButtonHeight = 50;

  Widget bgBox() {
    if (firstLoad && !showTimer) {
      return Container(
        width: double.infinity,
        height: bHBHeight + mainContainerHeight(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Palette.blue1,
            width: 1.5,
          ),
        ),
      );
    } else {
      return AnimatedContainer(
        curve: animationCurve,
        duration: animationDuration,
        width: double.infinity,
        height: bHBHeight + mainContainerHeight(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Palette.blue1,
            width: 1.5,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(
    //   "s time: ${TimeManager.selectedTime};   T of tap: ${TimeManager.timeOfTap};   elpsed: ${TimeManager.timeElapsed()};   totalT: ${TimeManager.totalTime()}",
    // );

    return Column(
      children: [
        AnimatedSize(
          curve: animationCurve,
          duration: animationDuration,
          alignment: Alignment.topCenter,
          child: Stack(
            children: [
              bgBox(),
              Column(
                children: [
                  _bhb(),
                  SizedBox(
                    key: mainContainerKey,
                    height: mainContainerHeight(),
                    child: showTimer
                        ? HomeTimer(
                            timerController: timerController,
                            onTimerComplete: () {
                              setState(() {
                                cancelEvent();
                              });
                            },
                          )
                        : TimeSetter(),
                  )
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        setButton(context),
      ],
    );
  }

  void checkWhetherToStart() async {
    // setState(
    //   () {
    //     date = TimeManager.selectedTime;
    //   },
    // );

    if (TimerLogic.validForStart()) {
      print('attempting to contact server to send info');
      _tryStartTimer();
    } else {
      setState(() {
        startSelected = false;
        showTimer = false;
      });
      if (TimerLogic.codesNull()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text("Please configure your codes in the settings page"),
            ),
          ),
        );
      } else if (TimerLogic.notValidForStart()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text("Please select a time that is after now!"),
            ),
          ),
        );
      }
    }
  }

  @override
  void initState() {
    initStateAsync();
    super.initState();
  }

  Future<void> initStateAsync() async {
    await StoredSettings.loadAll();
    firstLoad = true;
  }

  double mainContainerHeight() {
    return showTimer ? 280 : 220;
  }

  Widget setButton(BuildContext context) {
    return FutureBuilder<bool>(
        future: Connection.hasInternet(),
        builder: (context, snapshot) {
          bool isOnline = snapshot.data ?? false;

          return Column(
            children: [
              SizedBox(
                height: setButtonHeight,
                child: GestureDetector(
                  onTap: () async {
                    if (isOnline) {
                      setState(() {
                        firstLoad = false;
                      });
                      if (showTimer) {
                        setState(() {
                          cancelEvent();
                        });
                      } else {
                        checkWhetherToStart();
                      }
                    }
                  },
                  onTapDown: (details) {
                    HapticFeedback.selectionClick();
                    if (isOnline) {
                      setState(() {
                        startSelected = true;
                      });
                    }
                  },
                  onTapUp: (details) {
                    if (isOnline) {
                      if (TimerLogic.validTime()) {
                        setState(() => startSelected = true);
                        HapticFeedback.heavyImpact();
                      } else {
                        HapticFeedback.selectionClick();
                        setState(() => startSelected = false);
                      }
                    }
                  },
                  onTapCancel: () {
                    if (isOnline) {
                      setState(() {
                        showTimer
                            ? startSelected = true
                            : startSelected = false;
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Palette.blue1,
                        width: 1.5,
                      ),
                      color: isOnline
                          ? (startSelected ? Palette.blue3 : Palette.blue4)
                          : Colors.grey[400],
                    ),
                    child: Center(
                      child: setButtonChild(isOnline),
                    ),
                  ),
                ),
              ),
              if (!isOnline)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text("Waiting for internet connection"),
                )
            ],
          );
        });
  }

  Widget setButtonChild(bool isOnline) {
    if (!isOnline) {
      return CircularProgressIndicator.adaptive();
    }
    if (waitingServerResponse) {
      return CircularProgressIndicator.adaptive();
    }
    if (startSelected) {
      return Text(
        'Cancel',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Text(
      'Set Time',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _bhb() {
    return Container(
      key: bHBkey,
      height: bHBHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Palette.blue1,
          width: 1.5,
        ),
      ),
      child: SizedBox(
        height: mainContainerHeight(),
        child: Center(
            child: showTimer
                ? _HomeTimerState.showBeHomeTime()
                : Text(
                    'Be Home By:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  )),
      ),
    );
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

  Future<void> _sendTime(DateTime time,
      {required Function onServerSuccess, required onServerFail}) async {
    // IMPORTANT: Use "flutter run --dart-define=IP=[ip]" to set this before running
    // ALSO IMPORTANT: @Grayerhack700 if you don't use nginx then specify port 8080 (eg. localhost:8080)
    // If you are using nginx then it *should* default to port 80
    const String ip = String.fromEnvironment('IP');
    try {
      if (ip == "") {
        print("No ip passed to CLI when run");
        return;
      }

      Uri url = Uri.parse('http://$ip/user-status/set-time');

      final response = await http.post(url, body: {'time': time.toString()});
      if (response.statusCode == 200) {
        print('Success: ${response.body}');
        onServerSuccess();
      } else {
        print('Failed with status: ${response.statusCode}');
        onServerFail();
      }
    } catch (e) {
      print("Could not connect to server/server not running");
      onServerFail();
    }
  }

  Future<void> _tryStartTimer() async {
    setState(() => waitingServerResponse = true);

    await _HomeTimerState.setTimerLogic();
    await _sendTime(TimeManager.selectedTime, onServerSuccess: () {
      setState(() {
        showTimer = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SnackBarContent(),
          duration: Duration(milliseconds: 500),
        ),
      );
      setState(() {
        codeAttempts = 3;
        showTimer = true;
        startSelected = true;
      });
      if (TimeManager.timeOfTap != null) {
        Duration timeTo = TimeManager.totalTimeDuration()!;

        awayTimer = Timer(
          timeTo,
          () async {
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
          },
        );
      }
    }, onServerFail: () {
      cancelEvent();
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 7,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Icon(Icons.warning_amber_rounded),
                  ),
                  Text("An error occured"),
                ],
              ),
              content: Text(
                  "We were unable to connect to the server, please try again.\nIf the error persists, try restarting the app."),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      cancelEvent();
                    },
                    child: Text("Cancel")),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    setState(() {
                      waitingServerResponse = true;
                    });
                    await Future.delayed(Duration(seconds: 1));
                    await _tryStartTimer();
                    print("waiting: $waitingServerResponse");
                    setState(() {
                      waitingServerResponse = false;
                    });
                  },
                  child: Text("Try again"),
                )
              ],
            );
          });
    });
    setState(() {
      waitingServerResponse = false;
    });
  }

  static void alert() {
    //This is called when we are sure the user is in danger.
    //TODO: implement something
    print("alerted");
  }

  static void cancelEvent() {
    showTimer = false;
    startSelected = false;
    TimeManager.timeOfTap = null;
    // TimeSetterState.isTomorrow = false;
    // TimeManager.selectedTime = DateTime(
    //     DateTime.now().year,
    //     DateTime.now().month,
    //     DateTime.now().day,
    //     TimeManager.selectedTime.hour,
    //     TimeManager.selectedTime.minute,
    //     TimeManager.selectedTime.second,
    //     TimeManager.selectedTime.millisecond);

    TimeManager.selectedTime = DateTime.now().add(Duration(seconds: 1));

    TimerPrefs.saveTimer();
  }
}

class TimeSetter extends StatefulWidget {
  const TimeSetter({super.key});

  @override
  State<TimeSetter> createState() => TimeSetterState();
}

class TimeSetterState extends State<TimeSetter> {
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 0,
      children: [
        timeIsTomorrowCheckBox(),
        Divider(
          indent: 20,
          endIndent: 20,
          height: 3,
        ),
        setterUi(),
      ],
    );
  }

  Widget setterUi() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: SizedBox(
        height: 150,
        child: CupertinoDatePicker(
          initialDateTime: TimeManager.selectedTime,
          onDateTimeChanged: (value) {
            TimeManager.selectedTime = value;
            if (timeIsNextDay()) {
              setState(() {
                TimerLogic.isTomorrow = true;
              });
            } else {
              setState(() {
                TimerLogic.isTomorrow = false;
              });
            }
          },
          mode: CupertinoDatePickerMode.time,
          use24hFormat: true,
        ),
      ),
    );
  }

  bool timeIsNextDay() => TimeManager.selectedTime.isBefore(DateTime.now());

  Widget timeIsTomorrowCheckBox() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox.adaptive(
              side: BorderSide(
                  color: const Color.fromARGB(255, 114, 114, 114), width: 1),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize
                  .shrinkWrap, // Shrinks tap target (Android only)

              value: TimerLogic.isTomorrow,
              onChanged: (value) {
                setState(
                  () => TimerLogic.isTomorrow = value!,
                );
              },
            ),
            GestureDetector(
                onTap: () => setState(
                    () => TimerLogic.isTomorrow = !TimerLogic.isTomorrow),
                child: Text("I will be back tomorrow"))
          ],
        );
      },
    );
  }
}

class _HomeTimerState extends State<HomeTimer> {
  bool tryingAgain = false;
  @override
  Widget build(BuildContext context) {
    final int elapsed = TimeManager.timeElapsed() ?? 0;
    final int total = TimeManager.totalTime() ?? 0;

    try {
      if (total <= 0 || elapsed > total) {
        throw Exception("Invalid time range: elapsed=$elapsed, total=$total");
      }
      return Center(
        child: Container(
          padding: EdgeInsets.all(10),
          child: CircularCountDownTimer(
            duration: TimeManager.totalTime() ?? 0,
            initialDuration: TimeManager.timeElapsed() ?? 0,
            controller: widget.timerController,
            width: 200,
            height: 200,
            ringColor: Colors.grey,
            fillColor: Colors.orange,
            backgroundColor: Palette.backgroundColor,
            strokeWidth: 10,
            strokeCap: StrokeCap.round,
            textStyle: TextStyle(fontSize: 24),
            isReverse: true,
            isReverseAnimation: true,
            onComplete: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    widget.onTimerComplete();
                  });
                }
              });
            },
          ),
        ),
      );
    } catch (e) {
      print("Error in timer build: $e");

      return tryingAgain
          ? Center(child: CircularProgressIndicator.adaptive())
          : Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "An error occured, please try again.",
                  style: TextStyle(fontSize: 17.5),
                ),
                Text(
                  "If the error persists, restart the app.",
                  style: TextStyle(fontSize: 16),
                ),
                TextButton(
                  onPressed: () {
                    tryAgain();
                  },
                  child: Text(
                    "Try Again",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            );
    }
  }

  void tryAgain() async {
    setState(() {
      tryingAgain = true;
    });

    TimerAndClockState.cancelEvent();

    await Future.wait([
      TimerPrefs.loadTimer(),
      Future.delayed(Duration(seconds: 1)),
    ]);
    setState(() {
      tryingAgain = false;
    });
  }

  static Future<void> setTimerLogic() async {
    TimeManager.timeOfTap = DateTime.now();
    TimerPrefs.saveTimer();
  }

  static Widget showBeHomeTime() {
    Icon bellIcon = Icon(Icons.notifications_rounded, size: 18.5);
    return Padding(
      padding: EdgeInsets.only(top: 10, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          bellIcon,
          Text(
            TimeManager.shortSelectedTime(),
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
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
  Widget build(BuildContext context) {
    return Center(child: Text(loadingStates[index]));
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

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
}
