//! Not goooood
//? Crappppp code
// Overused comment
//todo I have way to much uncompleted code
//* This is okkkk
//. I WILL KILL MYSELF

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
                child: Options(),
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

class Options extends StatefulWidget {
  final String? title;
  final String? info;
  final Widget? leading;
  final Widget? trailing;
  static List<Contact> selectedContacts = [];

  const Options(
      {this.title, this.info, this.leading, this.trailing, super.key});

  @override
  OptionsState createState() => OptionsState();
}

class OptionsState extends State<Options> {
  Options getOption(int index) {
    switch (index) {
      case 0:
        return Options(
          title: "SOS Activation",
          info: "Required number of clicks to activate SOS button",
          trailing: _sosActButton(),
          leading: Icon(Icons.sos_rounded),
        );

      case 1:
        return Options(
          title: "Emergency Contacts",
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 20,
          ),
        );
      case 2:
        return Options(
          title: "Home Location",
        );
      default:
        return Options(title: "default", info: "default");
    }
  }

  final dditems = [
    'Single Click',
    'Double Click',
    'Triple Click',
    'Quad-Click',
  ];
//*declared dropdown
  String? value;

//*declared listview builder + separator indent
  double listIndent = 45;

//*declared contact picker
  List<String> contactPhone = [];
  List<String> contactName = [];

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
      itemCount: 3,
      separatorBuilder: (BuildContext context, int index) => Divider(
        color: Colors.black54,
        thickness: 2,
        indent: listIndent,
        height: 10,
      ),
      itemBuilder: (BuildContext context, int index) {
//*declared for switch properties in Option
        final Options item = getOption(index);

        if (index == 1) {
          return Hero(
            tag: "iceContacts",
            child: Material(
              child: Card(
                child: ListTile(
                  title: Text(item.title as String),
                  trailing: item.trailing,
                  leading: item.leading,
                  horizontalTitleGap: 8,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<Widget>(
                        builder: (BuildContext context) {
                          return Scaffold(
                            appBar: AppBar(
//todo center add icon with title and back button
//? modify back button
                              actions: [
                                Padding(
                                  padding: EdgeInsets.only(right: 32),
                                  child: InkWell(
                                    radius: 24,
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: _multipleContacts,
                                    child: Icon(
                                      Icons.add,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ],
                              title: Text(item.title as String),
                            ),
                            body: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 700,
                                  child: ListView.separated(
                                    itemCount: contactName.length,
                                    separatorBuilder:
                                        (BuildContext context, int index) =>
                                            Divider(),
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return ListTile(
                                        title: Text(contactName[index]),
                                        trailing: Text(contactPhone[index]),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }
        return Card(
          child: ListTile(
            title: Text(item.title as String),
            trailing: item.trailing,
            leading: item.leading,
            horizontalTitleGap: 8,
          ),
        );

        /* Container(
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
                              (item.title as String),
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
                              (item.info ?? "nothing here!"),
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
        ); */
      },
    );
  }

  void _multipleContacts() async {
    if (await FlutterContacts.requestPermission()) {
//*declared contant info when selected
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null) {
        print("Selected contacts:");
        for (var p in contact.phones) {
          print("${contact.displayName}: ${p.number}");
          setState(
            () {
              contactName.add(contact.displayName);
              contactPhone.add(p.number);
            },
          );
        }
        print(contactName);
        print(contactPhone);
      }
    }
  }

  //*  Widget _buildItem(int index) {
  //*   switch (index) {
  //*    case 0:
  //*      return _sosActButton();
  //*    case 1:
  //*      return _contactPicker();
  //*    case 2:
  //*      return SizedBox(
  //*          height: 20,
  //*          child: Placeholder(color: const Color.fromARGB(255, 53, 1, 242)));
  //*    default:
  //*      return SizedBox(
  //*        height: 20,
  //*        child: Placeholder(
  //*         color: Colors.red,
  //*       ),
  //*     );
  //* }
  //* }

  Widget _sosActButton() {
    return // dropdown button
        Container(
      height: 40,
      decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(0, 255, 170, 0))),
      child: DropdownButton<String>(
        autofocus: false,
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
