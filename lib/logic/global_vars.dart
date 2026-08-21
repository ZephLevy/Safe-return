import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_return/inits/noti_init.dart';
import 'package:safe_return/logic/connection_logic.dart';
import 'package:safe_return/logic/location_logic/current_position.dart';
import 'package:safe_return/pages/main_pages/map_page.dart';

final isOnlineNotifier = IsOnlineNotifier();
final reconnectingNotifier = ReconnectingNotifier();
final currentPositionNotifier = CurrentPosition();
final notiService = NotiService();
final ValueNotifier<List<LatLng>> userPathNotifier =
    ValueNotifier(MapsPageState.userPath);
