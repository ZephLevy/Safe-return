import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_return/Visuals/palette.dart';
import 'package:safe_return/logic/location_logic/location.dart';
import 'package:safe_return/pages/log_sign_up/login_page.dart';
import 'package:safe_return/pages/main_pages/home_page.dart';
import 'package:safe_return/pages/main_pages/map_page.dart';
import 'package:safe_return/pages/settings/preferred_viewer.dart';
import 'package:safe_return/pages/main_pages/settings_page.dart';
import 'package:safe_return/storage.dart/stored_settings.dart';
import 'package:safe_return/storage.dart/timer_prefs.dart';
import 'package:safe_return/logic/location_logic/location_updater.dart';
import 'package:safe_return/storage.dart/user_path_storage.dart';
import 'package:safe_return/utils/noti_service.dart';
import 'package:safe_return/utils/sos_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  WidgetsFlutterBinding.ensureInitialized();

  NotiService().initNotification();
  double? latitude = await asyncPrefs.getDouble("latitude");
  double? longitude = await asyncPrefs.getDouble("longitude");
  SosManager.secretCode = await asyncPrefs.getString("secretCode");
  SosManager.fakeCode = await asyncPrefs.getString("fakeCode");
  if (latitude != null && longitude != null) {
    Location.homePosition = LatLng(latitude, longitude);
  }

  try {
    await Location.determinePosition();
  } catch (_) {}
  userPathNotifier.value = await UserPathStorage.loadLocationData();
  await StoredSettings.loadAll();
  await TimerPrefs.loadTimer();
  await PreferredViewerState.loadViewType();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: (LoginPageState.isLoggedIn) ? HomeScreen() : LoginPage(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double iconSize = 28.0;
  final List<Widget> _pages = [
    HomePage(),
    MapsPage(),
    SettingsPage(),
  ];

  final PageController pageController = PageController();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      bottomNavigationBar: _bottomBar(),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) => setState(() {
          _selectedIndex = index;
        }),
        physics: NeverScrollableScrollPhysics(),
        children: _pages,
      ),
    );
  }

  NavigationBar _bottomBar() {
    return NavigationBar(
      destinations: [
        NavigationDestination(
            icon: Icon(Icons.home_filled, size: iconSize), label: "Home"),
        NavigationDestination(
            icon: Icon(Icons.location_on, size: iconSize), label: "Map"),
        NavigationDestination(
            icon: Icon(Icons.settings, size: iconSize), label: "Settings"),
      ],
      selectedIndex: _selectedIndex,
      onDestinationSelected: (value) {
        setState(() {
          _selectedIndex = value;
        });
        pageController.jumpToPage(_selectedIndex);
      },
      indicatorColor: Palette.blue4,
    );
  }

  AppBar _appBar() {
    const List<String> titles = ["", "Map", "Settings"];

    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        titles[_selectedIndex],
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 25,
          color: Palette.blue1,
        ),
      ),
      actions: [
        (_selectedIndex == 1)
            ? Row(
                children: [
                  LocationUpdater(),
                  // Padding(
                  //   padding: const EdgeInsets.only(right: 8.0),
                  //   child: IconButton(
                  //       tooltip: "Update home location to current location",
                  //       onPressed: () {
                  //         _setHomeLocation();
                  //       },
                  //       icon: Icon(Icons.home)),
                  // ),
                ],
              )
            : SizedBox.shrink(),
      ],
    );
  }
}
