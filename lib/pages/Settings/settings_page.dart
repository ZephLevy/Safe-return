//! Not goooood
//? On stand-by
// Overused comment
//todo I have way to much uncompleted code
//* This is okkkk
//. Fix the code

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe_return/pages/Settings/Emergency%20contacts/contacts_page.dart';
import 'package:safe_return/utils/noti_service.dart';
import 'package:safe_return/utils/sos_manager.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:safe_return/utils/stored_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:safe_return/utils/auth_service.dart';

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
                child: Options(title: ""),
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
      {required this.title, this.info, this.leading, this.trailing, super.key});

  @override
  OptionsState createState() => OptionsState();
}

class OptionsState extends State<Options> {
  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //General
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              "General",
              style: TextStyle(fontSize: 24),
            ),
          ),
          SizedBox(height: 10),
          ListTile(
            title: Text("SOS Activation"),
            subtitle: Text(
              "Number of clicks required to activate SOS button",
              style: TextStyle(fontSize: 12),
            ),
            leading: Icon(Icons.sos_outlined),
            trailing: Icon(Icons.arrow_forward_ios_rounded),
            onTap: () => _pushToSosActivation(context),
          ),
          ListTile(
            title: Text("Emergency Contacts"),
            subtitle: Text(
              "These contacts will be alerted if you are not home by the set time",
              style: TextStyle(fontSize: 12),
            ),
            leading: Icon(
              Icons.phone_in_talk,
              size: 22,
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded),
            onTap: () => _pushToContacts(context),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              "Privacy",
              style: TextStyle(fontSize: 24),
            ),
          ),
          ListTile(
            title: Text("Set Security Codes"),
            leading: Icon(
              Icons.vpn_key,
              size: 22,
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded),
            onTap: () {
              _pushToCodes(context);
            },
          ),
          ListTile(
            title: Text("notiffff"),
            onTap: () =>
                NotiService().showNotification(title: "title", body: "body"),
          )
        ],
      ),
    ]);
  }

  Widget _sosList() {
    final dditems = [
      'Single Click',
      'Double Click',
      'Triple Click',
      'Quad-Click',
    ];
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
                    StoredSettings.saveAll();
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _securityCodes() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Security Codes"),
      ),
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          ListTile(
            title: Text(
                SosManager.fakeCode == null || SosManager.secretCode == null
                    ? "Set Codes"
                    : "Change Codes"),
            leading: Icon(
                SosManager.fakeCode == null || SosManager.secretCode == null
                    ? Icons.input
                    : Icons.lock_reset),
            onTap: () {
              getCodeInput(false);
              getCodeInput(true);
            },
          ),
          ListTile(
            title: Text("View Codes"),
            leading: Icon(Icons.visibility),
            onTap: () async {
              _auth(() => _pushToViewCodes(context));
            },
            trailing: Icon(Icons.arrow_forward_ios_rounded),
          )
        ],
      ),
    );
  }

  Widget _viewCodes() {
    print("\nreal: ${SosManager.secretCode} \ndecoy: ${SosManager.fakeCode}");
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Codes"),
      ),
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Your real code:"),
                Text(SosManager.secretCode ?? "no real"),
              ],
            ),
          ),
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Your decoy code:"),
                Text(SosManager.fakeCode ?? "no decoy"),
              ],
            ),
          )
        ],
      ),
    );
  }

  _pushToSosActivation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => _sosList(),
      ),
    );
  }

  _pushToContacts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => ContactsPage(),
      ),
    );
  }

  _pushToCodes(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => _securityCodes()));
  }

  _pushToViewCodes(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (BuildContext context) => _viewCodes()));
  }

  _auth(Function ifTrue) async {
    final AuthService _authService = AuthService();

    bool isAuthenticated = await _authService.authenticateWithBiometrics();
    if (isAuthenticated) {
      print("good");
      ifTrue();
    } else {
      print("noooo");
    }
  }

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
