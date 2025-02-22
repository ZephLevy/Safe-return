import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe_return/logic/singletons/sos_manager.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              _sosUi(),
              SizedBox(
                width: double.infinity,
                height: 500,
                child: Menus(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sosUi() {
    return Stack(
      children: [
        //Settings box
        Container(
          margin: EdgeInsets.symmetric(horizontal: 70, vertical: 7),
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
  final items = [
    'Single Click',
    'Double Click',
    'Triple Click',
    'Quad-Click',
  ];
  String? value;

  @override
  void initState() {
    super.initState();
    value = items.first;
  }

  @override
  Widget build(BuildContext context) {
    return //Opening box under settings box
        Container(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 51.5),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: const Color.fromARGB(201, 0, 0, 0), width: 2),
        ),
        borderRadius: BorderRadius.circular(40),
      ),
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        scrollDirection: Axis.vertical,
        children: [
          //child 1 - sos activation
          SizedBox(
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                  border:
                      Border.all(color: const Color.fromARGB(255, 227, 0, 0))),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(0, 11, 233, 66))),
                    margin: EdgeInsets.only(left: 35),
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      children: [
                        //SOS activation text
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromARGB(0, 0, 0, 0))),
                          child: Text(
                            "SOS Activation",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),

                        // dropdown button
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromARGB(0, 0, 0, 0))),
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
                              SosManager().clickN =
                                  items.indexOf(value ?? "Single Click") + 1;
                            },
                          ),
                        ),
                        //desc. text
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: const Color.fromARGB(0, 0, 0, 0))),
                          margin: EdgeInsets.only(bottom: 0, right: 30),
                          child: Text(
                            'How many times you click the "SOS" button to activate it',
                            style: TextStyle(
                                color: const Color.fromARGB(255, 72, 72, 72),
                                fontSize: 12,
                                height: 1),
                          ),
                        ),

                        //inner line separator (gray)
                        Container(
                          // height: 1,
                          margin: EdgeInsets.only(top: 6),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color.fromARGB(81, 0, 0, 0),
                                width: 1.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          /* child: SizedBox(
                            height: 0,
                            width: double.infinity,
                          ), */
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: TextStyle(fontSize: 16),
        ),
      );
}
