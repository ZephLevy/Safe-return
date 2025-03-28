//! Not goooood
//? On stand-by
// Overused comment
//todo I have way to much uncompleted code
//* This is okkkk
//. I WILL KILL MYSELF

// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe_return/utils/contacts/contacts_page.dart';
import 'package:safe_return/utils/sos_manager.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:safe_return/palette.dart';
import 'package:safe_return/utils/stored_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
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
  final dditems = [
    'Single Click',
    'Double Click',
    'Triple Click',
    'Quad-Click',
  ];

  double listIndent = 45;

  @override
  void initState() {
    super.initState();
    StoredSettings.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final List<Options> settingsItems = [
      Options(
          title: "SOS Activation",
          info: "Required number of clicks to activate SOS button",
          trailing: _nextPage()
          //? leading: Icon(Icons.sos_rounded),
          ),
      Options(
        title: "Emergency Contacts",
        trailing: _nextPage(),
      ),
      Options(
        title: "Set Security Codes",
      ),
    ];
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      itemCount: settingsItems.length,
      separatorBuilder: (BuildContext context, int index) => Divider(
        color: Colors.black54,
        thickness: 2,
        indent: listIndent,
        height: 10,
      ),
      itemBuilder: (BuildContext context, int index) {
        final Options item = settingsItems[index];

        return {
              0: Hero(
                tag: "sosActivation",
                child: Material(
                  child: _mainBody(
                    item,
                    onTap: () {
                      _pushToSosActivation(context);
                      setState(() {});
                    },
                  ),
                ),
              ),
              1: Hero(
                tag: "emergencyContacts",
                child: Material(
                  child: _mainBody(item,
                      onTap: () => _pushToContacts(context, item)),
                ),
              ),
              2: _mainBody(
                item,
                onTap: () {
                  getCodeInput(false);
                  getCodeInput(true);
                },
              )
            }[index]
            //
            ??
            _mainBody(item);
      },
    );
  }

  Card _mainBody(Options item, {VoidCallback? onTap}) {
    return Card(
      elevation: 1.5,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(item.title as String),
        trailing: item.trailing,
        leading: item.leading,
        horizontalTitleGap: 8,
        onTap: onTap,
      ),
    );
  }

  Icon _nextPage() {
    return Icon(Icons.arrow_forward_ios_rounded);
  }

  Widget _sosList() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Scaffold(
          appBar: AppBar(
            title: Text("SOS Activation"),
          ),
          body: ListView.separated(
            separatorBuilder: (BuildContext context, int index) => Divider(
              height: 0,
            ),
            itemCount: dditems.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                minTileHeight: 65,
                title: Text(dditems[index]),
                trailing: StoredSettings.selectedIndex == index
                    ? Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.blue.shade600,
                        ),
                      )
                    : null,
                onTap: () => setState(
                  () {
                    StoredSettings.selectedIndex = index;
                    SosManager.clickN = StoredSettings.selectedIndex + 1;
                    StoredSettings.saveSosActivation(
                        StoredSettings.selectedIndex);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _pushToContacts(BuildContext context, Options item) {
    Navigator.push(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => ContactsPage(item: item),
      ),
    );
  }

  void _pushToSosActivation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => _sosList(),
      ),
    );
  }

  //? Widget _homeLocation() {
  //?   return Container(
  //?     height: 3,
  //?     width: 10,
  //?   );
  //? }

  // Widget _sosActButton() { //todo remove this
  //   return // dropdown button
  //       Container(
  //     height: 40,
  //     decoration: BoxDecoration(
  //         border: Border.all(color: const Color.fromARGB(0, 255, 170, 0))),
  //     child: DropdownButton<String>(
  //       autofocus: false,
  //       padding: EdgeInsets.only(left: 8, right: 1),
  //       onTap: () {
  //         HapticFeedback.selectionClick();
  //       },
  //       enableFeedback: true,
  //       borderRadius: BorderRadius.circular(8),
  //       iconSize: 25,
  //       menuWidth: 160,
  //       value: StoredSettings.dvalue,
  //       isExpanded: false,
  //       items: dditems.map(buildMenuItem).toList(),
  //       onChanged: (value) {
  //         setState(() => StoredSettings.dvalue = value);
  //         // print(StoredSettings.dvalue);
  //         // print(value);
  //         // StoredSettings.saveSosActivation(StoredSettings.dvalue);

  //         SosManager.clickN = dditems.indexOf(value ?? "Single Click") + 1;
  //       },
  //     ),
  //   );
  // } //todo remove this

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: TextStyle(fontSize: 16),
        ),
      );

  void getCodeInput(bool fakeCode) {
    TextEditingController textController = TextEditingController();
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(!fakeCode
              ? "Enter a code: if threatened to enter a code, this will silently call an alert"
              : "Enter a code"),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(
                hintText: !fakeCode
                    ? "Enter your decoy code..."
                    : "Enter your real code"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (fakeCode) {
                  SosManager.secretCode = textController.text;
                  await asyncPrefs.setString("secretCode", textController.text);
                } else {
                  SosManager.fakeCode = textController.text;
                  await asyncPrefs.setString("fakeCode", textController.text);
                }
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close dialog
                }
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
