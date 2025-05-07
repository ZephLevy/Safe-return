//! Not goooood
//? On stand-by
// Overused comment
//todo I have way to much uncompleted code
//* This is okkkk
//. Fix the code

//import files
import 'package:safe_return/utils/contacts_page.dart';
import 'package:safe_return/utils/noti_service.dart';
import 'package:safe_return/utils/sos_manager.dart';
import 'package:safe_return/utils/stored_settings.dart';
import 'package:safe_return/utils/auth_service.dart';
import 'package:safe_return/utils/persons.dart';
import 'package:safe_return/login_page.dart';

//import dependency/other packages
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as notif;
import 'package:http/http.dart' as http;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Settings();
  }
}

class Settings extends StatefulWidget {
  static List<Contact> selectedContacts = [];

  const Settings({required, super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return ListTileTheme(
      data: ListTileThemeData(
          contentPadding: EdgeInsets.only(left: 25, right: 20),
          titleTextStyle: TextStyle(fontSize: 17, color: Colors.black),
          subtitleTextStyle: TextStyle(fontSize: 11, color: Colors.black)),
      child: CardTheme(
        clipBehavior: Clip.antiAlias,
        elevation: 0.5,
        child: ListView(children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                    elevation: 2,
                    child: ListTile(
                      contentPadding: EdgeInsets.only(left: 10),
                      leading: Icon(Icons.account_circle, size: 50),
                      minLeadingWidth: 50,
                      title: Text("Account"),
                      subtitle: StatefulBuilder(builder: (context, setState) {
                        return Text(LoginPageState().email);
                      }),
                      onTap: () => accountSettings(),
                    )),
                SizedBox(height: 10),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                          title: Text("SOS Activation"),
                          subtitle: Text(
                            "Number of clicks required to activate SOS button",
                          ),
                          leading: Icon(Icons.sos_outlined),
                          trailing: Icon(Icons.arrow_forward_ios_rounded),
                          onTap: () => _sosList()),
                      ListTile(
                        title: Text("Emergency Contacts"),
                        subtitle: Text(
                          "These contacts will be alerted if you are not home by the set time",
                        ),
                        leading: Icon(
                          Icons.phone_in_talk,
                          size: 22,
                        ),
                        trailing: Icon(Icons.arrow_forward_ios_rounded),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<Widget>(
                            builder: (BuildContext context) => ContactsPage(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text("Security Codes"),
                        leading: Icon(
                          Icons.vpn_key,
                          size: 22,
                        ),
                        trailing: Icon(Icons.arrow_forward_ios_rounded),
                        onTap: () => _securityCodes(),
                      ),
                      ListTile(
                        title: Text("Use Biometrics"),
                        leading: Icon(
                          Icons.fingerprint_rounded,
                          size: 22,
                        ),
                        trailing: CupertinoSwitch(
                          value: StoredSettings.biometricsValue,
                          onChanged: (bool value) {
                            AuthService.auth(
                              () {
                                setState(
                                  () {
                                    StoredSettings.biometricsValue = value;
                                    StoredSettings.saveAll();
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text("Test Notification"),
                        subtitle: Text(
                            "What will be sent if you are not home by the set time."),
                        leading: Icon(Icons.notifications),
                        onTap: () {
                          notHomeNotif();
                          sendCallHTTP();
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }

  accountSettings() {
    // go to user account settings
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return ListTileTheme(
            data: ListTileThemeData(),
            child: CardTheme(
              child: Scaffold(
                appBar: AppBar(title: Text("Account")),
                body: ListView(
                  children: [
                    ListTile(
                      title: Text("Change Email"),
                    ),
                    ListTile(
                      title: Text("Change Password"),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  notHomeNotif() {
    StoredSettings.saveAll();
    NotiService().showNotification(
      title: "Are you ok?",
      body:
          "We've detected you're not back home. Enter your code to verify you are ok.",
      category: notif.NotificationDetails(),
    );
  }

  _sosList() {
    final dditems = [
      'Single Click',
      'Double Click',
      'Triple Click',
      'Quad-Click',
    ];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                appBar: AppBar(
                  title: Text("SOS Activation"),
                ),
                body: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(
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
        },
      ),
    );
  }

  _securityCodes() {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Security Codes"),
            ),
            body: ListView(
              physics: NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  title: Text(SosManager.fakeCode == null ||
                          SosManager.secretCode == null
                      ? "Set Codes"
                      : "Change Codes"),
                  leading: Icon(SosManager.fakeCode == null ||
                          SosManager.secretCode == null
                      ? Icons.input
                      : Icons.lock_reset),
                  onTap: () {
                    useBiometricsTo(
                      () {
                        iosAlert(
                          () {
                            Navigator.pop(context);
                            whichCodeChange();
                          },
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  title: Text("View Codes"),
                  leading: Icon(Icons.visibility),
                  onTap: () async {
                    useBiometricsTo(
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => _viewCodes(),
                          ),
                        );
                      },
                    );
                  },
                  trailing: Icon(Icons.arrow_forward_ios_rounded),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void useBiometricsTo(Function action) {
    if (StoredSettings.biometricsValue) {
      AuthService.auth(action);
    } else {
      action();
    }
  }

  whichCodeChange() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(
            "Which code would you like to change?",
            style: TextStyle(fontSize: 13.5),
          ),
          cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel", style: TextStyle(color: Colors.red))),
          actions: [
            CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  getCodeInput(true);
                },
                child: Text("Change real code",
                    style: TextStyle(
                        color: const Color.fromARGB(255, 0, 120, 255)))),
            CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  getCodeInput(false);
                },
                child: Text("Change decoy code",
                    style: TextStyle(
                        color: const Color.fromARGB(255, 0, 120, 255)))),
            CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  getCodeInput(false);
                  getCodeInput(true);
                },
                child: Text("Change both",
                    style: TextStyle(
                        color: const Color.fromARGB(255, 0, 120, 255)))),
          ],
        );
      },
    );
  }

  void iosAlert(Function proceed) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Are you sure?"),
          content: Text("This will change your security code(s)."),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "cancel",
                style: TextStyle(
                    color: const Color.fromARGB(255, 0, 120, 255),
                    fontWeight: FontWeight.w500),
              ),
            ),
            CupertinoDialogAction(
                onPressed: () {
                  proceed();
                },
                child: Text("continue", style: TextStyle(color: Colors.red)))
          ],
        );
      },
    );
  }

  Widget _viewCodes() {
    // print("\nreal: ${SosManager.secretCode} \ndecoy: ${SosManager.fakeCode}");
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

  void getCodeInput(bool fakeCode) {
    TextEditingController textController = TextEditingController();
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    showDialog(
      barrierDismissible: false,
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

  Future<void> sendCallHTTP() async {
    const serverUrl = String.fromEnvironment("IP");
    final serverResponse = await http.post(
      //TODO fix to correct endpoint?
      Uri.parse(serverUrl),
      //TODO remove this?
      // headers: {'Content-Type': 'application/json'},
      body: json.encode({'phoneandname': Person.persons}),
    );

    if (serverResponse.statusCode == 200) {
      print(
          "serverResponse.statusCode = ${serverResponse.statusCode} \nServer received request.");
    } else {
      print(
          "serverResponse.statusCode = ${serverResponse.statusCode} \nServer failed to receive request.");
    }
  }
}
