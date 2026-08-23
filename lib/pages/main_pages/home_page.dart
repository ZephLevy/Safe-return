import 'dart:async';
import 'dart:ui';

import 'package:animate_gradient/animate_gradient.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:http/http.dart' as http;
import 'package:safe_return/Visuals/palette.dart';
import 'package:safe_return/custom_widgets/custom_gradient_container.dart';
import 'package:safe_return/inits/noti_init.dart';
import 'package:safe_return/logic/codes_logic.dart';
import 'package:safe_return/logic/global_vars.dart';
import 'package:safe_return/logic/home_page_updater.dart';
import 'package:safe_return/logic/location_logic/location_updater.dart';
import 'package:safe_return/logic/timer_handler.dart';
import 'package:safe_return/logic/timer_logic.dart';
import 'package:safe_return/pages/main_pages/map_page.dart';
import 'package:safe_return/storage.dart/stored_settings.dart';
import 'package:safe_return/storage.dart/timer_storage.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Duration animationDuration = Duration(milliseconds: 200);
  Curve animationCurve = Curves.easeOut;

  // DateTime date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: isOnlineNotifier,
        builder: (context, isOnline, child) {
          return ValueListenableBuilder(
            valueListenable: showTimerNotifier,
            builder: (context, showTimer, child) {
              return ValueListenableBuilder(
                valueListenable: startSelectedNotifier,
                builder: (context, startSelected, child) {
                  return ValueListenableBuilder(
                    valueListenable: firstLoadNotifier,
                    builder: (context, firstLoad, child) {
                      return ValueListenableBuilder(
                          valueListenable: codeAttemptsNotifier,
                          builder: (context, codeAttempts, child) {
                            return ValueListenableBuilder(
                              valueListenable: initializingTimer,
                              builder: (context, initializingTimer, child) {
                                return Scaffold(
                                  body: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        AnimatedSize(
                                          curve: animationCurve,
                                          duration: animationDuration,
                                          alignment: Alignment.topCenter,
                                          child: MainScreen(),
                                        ),
                                        SizedBox(height: 15),
                                        SetButton(),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          });
                    },
                  );
                },
              );
            },
          );
        });
  }

  static void checkSettingsForStart(context) async {
    if (TimerLogic.validSettingsForStart()) {
      TimerHandler.tryStartTimer(context);
    } else {
      HomeUpdater.startSelected = false;
      HomeUpdater.showTimer = false;
      if (TimerLogic.codesNull()) {
        showTopSnackBar(
          displayDuration: Duration(seconds: 4),
          dismissType: DismissType.onSwipe,
          Overlay.of(context),
          CustomSnackBar.error(
            maxLines: 4,
            icon: Icon(Icons.info_outline_rounded,
                color: Color(0x15000000), size: 120),
            message:
                "Missing Security Code(s):\nYou can configure your codes in the settings page.",
          ),
        );
      } else if (TimerLogic.selectedTimeIsNow()) {
        showTopSnackBar(
          displayDuration: Duration(seconds: 4),
          dismissType: DismissType.onSwipe,
          Overlay.of(context),
          CustomSnackBar.error(
            maxLines: 4,
            icon: Icon(Icons.info_outline_rounded,
                color: Color(0x15000000), size: 120),
            message: "Error starting timer:\nSelect a time that is not now.",
          ),
        );
      } else if (MapsPageState.homePosition == null) {
        showTopSnackBar(
          displayDuration: Duration(seconds: 4),
          dismissType: DismissType.onSwipe,
          Overlay.of(context),
          CustomSnackBar.error(
            maxLines: 4,
            icon: Icon(Icons.info_outline_rounded,
                color: Color(0x15000000), size: 120),
            message:
                "Missing Home Position:\nYou can add your Home Position in the settings page.",
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
    await StoredSettings.load();
    await TimerStorage.loadTimer();
    firstLoadNotifier.value = true;
  }

  double mainContainerHeight() {
    return HomeUpdater.showTimer ? 280 : 220;
  }

  static Future<void> sendTime(DateTime time,
      {required Function onServerSuccess, required onServerFail}) async {
    // IMPORTANT: Use "flutter run --dart-define=IP=[ip]" to set this before running
    // ALSO IMPORTANT: @Grayerhack700 if you don't use nginx then specify port 8080 (eg. localhost:8080)
    // If you are using nginx then it *should* default to port 80
    const String ip = String.fromEnvironment('IP');
    try {
      if (ip == "") {
        print("No ip passed to CLI when run");
        onServerFail();
      }

      Uri url = Uri.parse('http://$ip/user-status/set-time');

      final response = await http.post(url, body: {'time': time.toString()});
      if (response.statusCode == 200) {
        print('Success: response body for set time: ${response.body}');
        onServerSuccess();
      } else {
        print('Failed to send set time with status: ${response.statusCode}');
        onServerFail();
      }
    } catch (e) {
      print("Could not connect to server/server not running");
      onServerFail();
    }
  }

  static void handleAwayFromhome(context) {
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
                  hintText:
                      "You have ${codeAttemptsNotifier.value} attempts left"),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  String text = textController.text;
                  bool canPop = Navigator.canPop(context);
                  if (text == CodesLogic.decoyCode) {
                    alert();
                    if (canPop) Navigator.pop(context);
                    return;
                  } else if (text == CodesLogic.realCode) {
                    if (canPop) Navigator.pop(context);
                    return;
                  }

                  // Got code wrong
                  textController.clear();
                  timeSetButtonState(() => codeAttemptsNotifier.value--);

                  if (codeAttemptsNotifier.value <= 0) {
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

  static void cancelEvent() {
    HomeUpdater.showTimer = false;
    HomeUpdater.startSelected = false;
    TimerLogic.timeOfTap = null;
    // TimeSetterState.isTomorrow = false;
    // TimerLogic.selectedTime = DateTime(
    //     DateTime.now().year,
    //     DateTime.now().month,
    //     DateTime.now().day,
    //     TimerLogic.selectedTime.hour,
    //     TimerLogic.selectedTime.minute,
    //     TimerLogic.selectedTime.second,
    //     TimerLogic.selectedTime.millisecond);

    HomeUpdater.selectedTime = DateTime.now().add(Duration(seconds: 1));

    TimerStorage.saveTimer();
  }

  static void alert() {
    //This is called when we are sure the user is in danger.
    //TODO: implement something
    print("alerted");
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final GlobalKey mainContainerKey = GlobalKey();
  CountDownController timerController = CountDownController();
  bool timeIsSet = false;

  double bHBHeight = 52.75;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 20, top: 15),
      width: double.infinity,
      // height: bHBHeight + mainContainerHeight(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Palette.blue1,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          HomeUpdater.showTimer
              ? HomeTimerState.showBeHomeTime()
              : const Text(
                  textAlign: TextAlign.center,
                  'Be Home By:',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          SizedBox(height: 7),
          CustomGradientContainer(
              height: 1,
              margin: EdgeInsets.symmetric(horizontal: 20),
              colors: [Colors.transparent, Colors.black54, Colors.transparent]),
          SizedBox(height: HomeUpdater.showTimer ? 20 : 15),
          Container(
            key: mainContainerKey,
            child: HomeUpdater.showTimer
                ? HomeTimer(
                    timerController: timerController,
                    onTimerComplete: () {
                      setState(() {
                        HomePageState.cancelEvent();
                      });
                    },
                  )
                : TimeSetter(),
          )
        ],
      ),
    );

    // print(
    //   "s time: ${TimerLogic.selectedTime};   T of tap: ${TimerLogic.timeOfTap};   elpsed: ${TimerLogic.timeElapsed()};   totalT: ${TimerLogic.totalTime()}",
    // );
  }
}

class SetButton extends StatefulWidget {
  const SetButton({super.key});

  @override
  State<SetButton> createState() => _SetButtonState();
}

class _SetButtonState extends State<SetButton> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isOnlineNotifier,
      builder: (context, isOnline, child) {
        return Column(
          children: [
            SizedBox(
              height: 80,
              width: double.infinity,
              child: GestureDetector(
                onTap: () async {
                  if (isOnline) {
                    HomeUpdater.firstLoad = false;

                    if (HomeUpdater.showTimer) {
                      IsolateNameServer.removePortNameMapping(
                          LocationServiceRepository.isolateName);
                      await BackgroundLocator.unRegisterLocationUpdate();

                      setState(() {
                        HomePageState.cancelEvent();
                      });
                    } else {
                      HomePageState.checkSettingsForStart(context);
                    }
                  }
                },
                onTapDown: (details) {
                  HapticFeedback.selectionClick();
                  if (isOnline) {
                    HomeUpdater.startSelected = true;
                  }
                },
                onTapUp: (details) {
                  if (isOnline) {
                    HomeUpdater.startSelected = true;
                    HapticFeedback.heavyImpact();
                  } else {
                    HapticFeedback.selectionClick();
                    HomeUpdater.startSelected = false;
                  }
                },
                onTapCancel: () {
                  if (isOnline) {
                    HomeUpdater.showTimer
                        ? HomeUpdater.startSelected = true
                        : HomeUpdater.startSelected = false;
                  }
                },
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          offset: Offset(-1, 1),
                          blurRadius: 5,
                          spreadRadius: 0,
                          color: const Color.fromARGB(51, 0, 0, 0)),
                      BoxShadow(
                          offset: Offset(1, -1),
                          blurRadius: 5,
                          spreadRadius: 0,
                          color: const Color.fromARGB(51, 0, 0, 0)),
                      BoxShadow(
                          offset: Offset(0, 4),
                          blurRadius: 7,
                          spreadRadius: 2,
                          color: const Color.fromARGB(51, 0, 0, 0)),
                    ],
                  ),
                  child: InnerShadow(
                    shadows: [
                      Shadow(
                        color: Color.fromARGB(30, 0, 0, 0),
                        offset: Offset.zero,
                        blurRadius: 10,
                      ),
                    ],
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: AnimatedSetButton(),
                    ),
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
      },
    );
  }
}

class AnimatedSetButton extends StatefulWidget {
  const AnimatedSetButton({super.key});

  @override
  State<AnimatedSetButton> createState() => _AnimatedSetButtonState();
}

class _AnimatedSetButtonState extends State<AnimatedSetButton>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 5000),
  )..repeat(reverse: true);

  static const List<Color> defaultPrimaryColors = [
    // Colors.red,
    // Colors.green
    Color(0xFF80a6a9),
    Color(0xFFa4d2d5),
    Color(0xFFa4d2d5),
    Color(0xFFa4d2d5),
    Color(0xFF80a6a9),
  ];
  final List<Color> defaultSecondaryColors = [
    Color(0xFFa4d2d5),
    Color(0xFF80a6a9),
    Color(0xFF80a6a9),
    Color(0xFF80a6a9),
    Color(0xFFa4d2d5),
  ];

  final List<Color> cancelPrimaryColors = [
    Color(0xFFb5b5b5),
    Color(0xFFD58486),
    Color(0xFFD58486),
    Color(0xFFD58486),
    Color(0xFFb5b5b5),
  ];

  final List<Color> cancelSecondaryColors = [
    Color(0xFFD59FA8),
    Color(0xFFb5b5b5),
    Color(0xFFb5b5b5),
    Color(0xFFb5b5b5),
    Color(0xFFD59FA8),
  ];

  bool showNormalColors() {
    if (HomeUpdater.showTimer) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimateGradient(
      controller: animationController,
      primaryColors:
          showNormalColors() ? defaultPrimaryColors : cancelPrimaryColors,
      secondaryColors:
          showNormalColors() ? defaultSecondaryColors : cancelSecondaryColors,
      primaryBegin: Alignment.bottomRight,
      primaryEnd: Alignment.bottomLeft,
      secondaryBegin: Alignment.topLeft,
      secondaryEnd: Alignment.topRight,
      animateAlignments: true,
      child: Center(
        child: setButtonChild(),
      ),
    );
  }

  Widget setButtonChild() {
    if (!isOnlineNotifier.value || waitingServerNotifier.value) {
      return CircularProgressIndicator.adaptive();
    }
    return Text(
      HomeUpdater.startSelected ? "Cancel" : "Secure Me",
      style: TextStyle(
        fontSize: 20.5,
        fontWeight: FontWeight.w500,
      ),
    );
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
        // timeIsTomorrowCheckBox(),
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
          initialDateTime: HomeUpdater.selectedTime,
          onDateTimeChanged: (value) {
            HomeUpdater.selectedTime = value;
            // if (timeIsNextDay()) {
            //   setState(() {
            //     TimerLogic.plusDay = true;
            //   });
            // } else {
            //   setState(() {
            //     TimerLogic.plusDay = false;
            //   });
            // }
          },
          mode: CupertinoDatePickerMode.time,
          use24hFormat: true,
        ),
      ),
    );
  }

  // Widget timeIsTomorrowCheckBox() {
  //   return StatefulBuilder(
  //     builder: (context, setState) {
  //       return Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Checkbox.adaptive(
  //             side: BorderSide(
  //                 color: const Color.fromARGB(255, 114, 114, 114), width: 1),
  //             visualDensity: VisualDensity.compact,
  //             value: TimerLogic.plusDay,
  //             onChanged: (value) {
  //               setState(
  //                 () => TimerLogic.plusDay = value!,
  //               );
  //             },
  //           ),
  //           GestureDetector(
  //               onTap: () =>
  //                   setState(() => TimerLogic.plusDay = !TimerLogic.plusDay),
  //               child: const Text("+24h"))
  //         ],
  //       );
  //     },
  //   );
  // }
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
  State<HomeTimer> createState() => HomeTimerState();
}

class HomeTimerState extends State<HomeTimer> {
  bool tryingAgain = false;
  @override
  Widget build(BuildContext context) {
    final int elapsed = TimerLogic.timeElapsed() ?? 0;
    final int total = TimerLogic.totalTime() ?? 0;

    try {
      if (total <= 0 || elapsed > total) {
        throw Exception("Invalid time range: elapsed=$elapsed, total=$total");
      }
      return Center(
        child: Container(
          padding: EdgeInsets.all(10),
          child: CircularCountDownTimer(
            duration: TimerLogic.totalTime() ?? 0,
            initialDuration: TimerLogic.timeElapsed() ?? 0,
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

    HomePageState.cancelEvent();

    await Future.wait([
      TimerStorage.loadTimer(),
      Future.delayed(Duration(seconds: 1)),
    ]);
    setState(() {
      tryingAgain = false;
    });
  }

  static Future<void> setTimerLogic() async {
    TimerLogic.timeOfTap = DateTime.now();
    TimerStorage.saveTimer();
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
            TimerLogic.shortSelectedTime(),
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
