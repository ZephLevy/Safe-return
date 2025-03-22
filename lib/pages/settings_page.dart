//! Not goooood
//? On stand-by
// Overused comment
//todo I have way to much uncompleted code
//* This is okkkk
//. I WILL KILL MYSELF

// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe_return/pages/contacts_page.dart';
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
        trailing: _sosActButton(),
        //? leading: Icon(Icons.sos_rounded),
      ),
      Options(
        title: "Emergency Contacts",
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 20,
        ),
      ),
      Options(
        title: "Set codes",
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
                        builder: (BuildContext context) =>
                            ContactsPage(item: item),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }
        return index == 2
            ? InkWell(
                child: _mainCardBody(item),
                onTap: () {
                  if (index == 2) {
                    getCodeInput(false);
                    getCodeInput(true);
                  }
                },
              )
            : _mainCardBody(item);
      },
    );
  }

  Card _mainCardBody(Options item) {
    return Card(
      child: ListTile(
        title: Text(item.title as String),
        trailing: item.trailing,
        leading: item.leading,
        horizontalTitleGap: 8,
      ),
    );
  }

  //? Widget _homeLocation() {
  //?   return Container(
  //?     height: 3,
  //?     width: 10,
  //?   );
  //? }

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
        value: StoredSettings.dvalue,
        isExpanded: false,
        items: dditems.map(buildMenuItem).toList(),
        onChanged: (value) {
          setState(() => StoredSettings.dvalue = value);
          // print(StoredSettings.dvalue);
          // print(value);
          StoredSettings.saveDropdown(StoredSettings.dvalue);

          SosManager.clickN = dditems.indexOf(value ?? "Single Click") + 1;
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
