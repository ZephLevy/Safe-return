import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_return/inits/noti_init.dart';
import 'package:safe_return/logic/connection_logic.dart';
import 'package:safe_return/logic/home_page_updater.dart';
import 'package:safe_return/logic/location_logic/current_position.dart';
import 'package:safe_return/pages/all_settings_pages/home_selector_page.dart';
import 'package:safe_return/pages/main_pages/map_page.dart';

final isOnlineNotifier = IsOnlineNotifier();
final reconnectingNotifier = ReconnectingNotifier();
final currentPositionNotifier = CurrentPosition();
final mapLoadNotifier = MapLoadNotifier();
final notiService = NotiService();
final initializingTimer = InitializingTimer();
final ValueNotifier<List<LatLng>> userPathNotifier =
    ValueNotifier(MapsPageState.userPath);

final waitingServerNotifier = WaitingServer();
final ValueNotifier<bool> showTimerNotifier = ValueNotifier(false);
final ValueNotifier<bool> firstLoadNotifier = ValueNotifier(false);
final ValueNotifier<bool> startSelectedNotifier = ValueNotifier(false);
final ValueNotifier<int> codeAttemptsNotifier = ValueNotifier(3);
final ValueNotifier<DateTime> selectedTimeNotifier =
    ValueNotifier(DateTime.now());
