import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe_return/palette.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              _sosConfig(),
              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.symmetric(horizontal: 40, vertical: 78),
                child: SizedBox(
                  width: 134,
                  height: 35,
                  child: Menus(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sosConfig() {
    return Stack(
      children: [
        //Settings box
        Container(
          margin: EdgeInsets.symmetric(horizontal: 70, vertical: 20),
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: Center(
            child: Text(
              "Settings",
              style: TextStyle(color: Colors.black, fontSize: 21),
            ),
          ),
        ),
        //Opening box under settings box
        Container(
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 65),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                  color: const Color.fromARGB(201, 0, 0, 0), width: 2),
            ),
            borderRadius: BorderRadius.circular(40),
          ),
          width: double.infinity,
          height: 300,
          child: Container(
            margin: EdgeInsets.only(left: 35, top: 54),
            child: Text(
              'How many times you click the "SOS" button to activate it',
              style: TextStyle(
                  color: const Color.fromARGB(255, 72, 72, 72),
                  fontSize: 11.5,
                  height: 1),
            ),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.symmetric(horizontal: 55, vertical: 81),
          child: Text(
            "SOS Activation",
            style: TextStyle(fontSize: 20),
          ),
        ),
        //inner line separator (gray)
        Container(
          margin: EdgeInsets.only(left: 52, right: 20, top: 140),
          decoration: BoxDecoration(
            border: Border.all(
                color: const Color.fromARGB(81, 0, 0, 0), width: 1.25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 0,
            width: double.infinity,
          ),
        ),
      ],
    );
  }
}

class Menus extends StatefulWidget {
  const Menus({super.key});

  @override
  MenusState createState() => MenusState();
}

class MenusState extends State<Menus> {
  final items = ['Single Click', 'Double Click', 'Triple Click'];
  String? value;

  @override
  void initState() {
    super.initState();
    value = items.first;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Container(
          alignment: Alignment.center,
          child: DropdownButton<String>(
            padding: EdgeInsets.only(left: 8, right: 1),
            onTap: () {
              HapticFeedback.selectionClick();
            },
            enableFeedback: true,
            borderRadius: BorderRadius.circular(8),
            iconSize: 25,
            menuWidth: 160,
            value: value,
            isExpanded: false,
            items: items.map(buildMenuItem).toList(),
            onChanged: (value) {
              setState(() => this.value = value);
              print(value);
            },
          ),
        ),
      );
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: TextStyle(fontSize: 16),
        ),
      );
}
