import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:safe_return/logic/location.dart';
import 'package:safe_return/pages/home_page.dart';
import 'package:safe_return/pages/map_page.dart';
import 'package:safe_return/pages/settings_page.dart';
import 'package:safe_return/palette.dart';
import 'package:safe_return/utils/sos_manager.dart';
import 'package:safe_return/utils/stored_settings.dart';
import 'package:safe_return/utils/contacts/persons.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  WidgetsFlutterBinding.ensureInitialized();
  double? latitude = await asyncPrefs.getDouble("latitude");
  double? longitude = await asyncPrefs.getDouble("longitude");
  SosManager.secretCode = await asyncPrefs.getString("secretCode");
  SosManager.fakeCode = await asyncPrefs.getString("fakeCode");
  if (latitude != null && longitude != null) {
    Location.homePosition = LatLng(latitude, longitude);
  }

  await StoredSettings.loadAll();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
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
    MapPage(),
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
    const List<String> titles = ["Safe Return", "Map", "Settings"];

    return AppBar(
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
            ? Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Tooltip(
                  message: "Update the home location",
                  child: IconButton(
                      onPressed: () {
                        _setHomeLocation();
                      },
                      icon: Icon(Icons.home)),
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }

  Future<void> _setHomeLocation() async {
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    final Position location = await Location.determinePosition();

    await asyncPrefs.setDouble("latitude", location.latitude);
    await asyncPrefs.setDouble("longitude", location.longitude);
  }
}
