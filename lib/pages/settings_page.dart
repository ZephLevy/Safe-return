import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe_return/logic/singletons/sos_manager.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
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
              _sosUi(),
              SizedBox(
                width: double.infinity,
                height: 600,
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
  final dditems = [
    'Single Click',
    'Double Click',
    'Triple Click',
    'Quad-Click',
  ];
  String? value;
  double listIndent = 45;

  List<double> itemSize = [55, 55, 55];
  List<double> infoRIndent = [5, 5, 5];

  List<Map<String, dynamic>> entlist = [
    {
      "title": "SOS Activation",
      "info": 'Required number of clicks to activate SOS button',
    },
    {
      "title": "Emergency Contacts",
      "info": "",
    },
    {"title": "Home Location", "info": ""}
  ];

  @override
  void initState() {
    super.initState();
    value = dditems.first;
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
      child: _scroll(),
    );
  }

  Widget _scroll() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      itemCount: entlist.length,
      separatorBuilder: (BuildContext context, int index) => Divider(
        color: Colors.black54,
        thickness: 2,
        indent: listIndent,
        height: 10,
      ),
      itemBuilder: (BuildContext context, int index) {
        // ignore: unused_local_variable
        final item = entlist[index];
        return Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(12)),
          child: SizedBox(
            height: itemSize[index],
            child: Stack(
              children: [
                Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: const Color.fromARGB(0, 255, 64, 128))),
                    width: listIndent,
                    height: itemSize[index],
                    child: _scrollIcon(index)),
                Wrap(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: listIndent),
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromARGB(0, 255, 18, 18))),
                      child: Wrap(
                        spacing: 0,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color:
                                        const Color.fromARGB(0, 0, 255, 21))),
                            child: Text(
                              (entlist[index]["title"]),
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color:
                                        const Color.fromARGB(0, 0, 255, 21))),
                            child: _buildItem(index),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: infoRIndent[index]),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color:
                                        const Color.fromARGB(0, 0, 255, 21))),
                            child: Text(
                              (entlist[index]["info"]),
                              style: TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItem(int index) {
    switch (index) {
      case 0:
        return _sosActButton();
      case 1:
        return _contactPicker();
      case 2:
        return SizedBox(
            height: 20,
            child: Placeholder(color: const Color.fromARGB(255, 53, 1, 242)));
      default:
        return SizedBox(
          height: 20,
          child: Placeholder(
            color: Colors.red,
          ),
        );
    }
  }

  Widget _scrollIcon(int index) {
    switch (index) {
      case 0:
        return Container(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.only(right: 5, left: 3, top: 2, bottom: 2),
          decoration: BoxDecoration(
              shape: BoxShape.circle, border: Border.all(width: 2)),
          child: Center(
            child: Text(
              "SOS",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        );
      default:
        return Placeholder();
    }
  }

  Widget _contactPicker() {
    return ElevatedButton(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(Palette.purple),
        backgroundColor:
            WidgetStatePropertyAll(const Color.fromARGB(255, 253, 246, 255)),
        //  shadowColor:
        //     WidgetStatePropertyAll(const Color.fromARGB(255, 211, 26, 26)),
      ),
      onPressed: () async {
        if (await FlutterContacts.requestPermission()) {
          final contact = await FlutterContacts.openExternalPick();
          if (contact != null) {
            print(contact.phones);
          }
        }
      },
      child: Text("Pick"),
    );
  }

  Widget _sosActButton() {
    return // dropdown button
        Container(
      height: 30,
      decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(0, 255, 170, 0))),
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
        items: dditems.map(buildMenuItem).toList(),
        onChanged: (value) {
          setState(() => this.value = value);
          SosManager().clickN = dditems.indexOf(value ?? "Single Click") + 1;
        },
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
