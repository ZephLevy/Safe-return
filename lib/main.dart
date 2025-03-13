import 'package:flutter/material.dart';
import 'package:safe_return/pages/home_page.dart';
import 'package:safe_return/pages/map_page.dart';
import 'package:safe_return/pages/settings_page.dart';
import 'package:safe_return/palette.dart';

void main() {
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
        children: _pages,
        onPageChanged: (index) => setState(() {
          _selectedIndex = index;
        }),
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
        pageController.animateToPage(
          _selectedIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
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
    );
  }
}
