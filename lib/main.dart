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
    MapPage(),
    HomePage(),
    SettingsPage(),
  ];

  int _selectedIndex = 1;

  void _onButtonSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
              icon: Icon(Icons.location_on, size: iconSize), label: "Map"),
          NavigationDestination(
              icon: Icon(Icons.home_filled, size: iconSize), label: "Home"),
          NavigationDestination(
              icon: Icon(Icons.settings, size: iconSize), label: "Settings"),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) => setState(() {
          _selectedIndex = value;
        }),
        indicatorColor: Palette.blue4,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: Text(
        'Safe Return',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 25,
          color: Palette.blue1,
        ),
      ),
    );
  }
}

class IconButtons extends StatelessWidget {
  final String path;
  final int index;
  final bool isSelected;
  final Function(int) onSelected;

  const IconButtons({
    required this.path,
    required this.index,
    required this.isSelected,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 55,
      height: 55,
      child: GestureDetector(
        onTap: () => onSelected(index), // Notify parent when tapped
        child: AnimatedContainer(
          duration: Duration(milliseconds: 100),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isSelected ? Palette.blue3 : Palette.blue4,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: isSelected ? Offset(0, 0) : Offset(4, 4),
                blurRadius: 10,
              ),
            ],
            border: Border(
              left: BorderSide(color: Palette.blue1, width: 1.5),
              right: BorderSide(color: Palette.blue1, width: 1.5),
              top:
                  BorderSide(color: Palette.blue1, width: isSelected ? 4 : 1.5),
              bottom: BorderSide(
                  color: Palette.blue1, width: !isSelected ? 4 : 1.5),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Palette.blue2, width: 1.5),
              borderRadius: BorderRadius.circular(7.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image(
                image: AssetImage(path),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
