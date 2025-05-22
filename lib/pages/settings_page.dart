//! Not goooood
//? On stand-by
// Overused comment
//todo I have way to much uncompleted code
//* This is okkkk
//. Fix the code

//import files
import 'dart:math';

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
import 'package:http/http.dart' as http;
import 'package:safe_return/Visuals/theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(data: Themes.settingsThemeData, child: Settings());
  }
}

class Settings extends StatefulWidget {
  static List<Contact> selectedContacts = [];

  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
              elevation: 2,
              child: ListTile(
                contentPadding: EdgeInsets.only(left: 10),
                leading: Icon(Icons.account_circle, size: 50),
                minLeadingWidth: 50,
                title: Text("${SignUpState.firstName} ${SignUpState.lastName}"),
                subtitle: StatefulBuilder(builder: (context, setState) {
                  return Text(LoginPageState.email);
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
                    CupertinoPageRoute<Widget>(
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
                              StoredSettings.save(
                                  biometricsValue:
                                      StoredSettings.biometricsValue);
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
                    NotiService().notHomeNotif();
                    sendPersonsList(); //TODO remove this in production, only for debugging so far, no point in having it for test notif
                  },
                ),
              ],
            ),
          )
        ],
      ),
    ]);
  }

  accountSettings() {
    int randomInRange(int min, int max) {
      return Random().nextInt(max - min + 1) + min;
    }

    // go to user account settings
    Navigator.push(
      context,
      CupertinoPageRoute(
        fullscreenDialog: true,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Theme(
            data: Themes.settingsThemeData,
            child: Scaffold(
              appBar: AppBar(title: Text("Account Settings")),
              body: ListView(
                children: [
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, top: 8),
                          child: Text(
                            "Personal Info",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        ListTile(
                          title: SignUpState.firstName.isNotEmpty
                              ? Text(SignUpState.firstName)
                              : Text(
                                  "No first name set",
                                  style: TextStyle(
                                      color:
                                          const Color.fromARGB(104, 0, 0, 0)),
                                ),
                          subtitle: Text("First Name"),
                        ),
                        ListTile(
                          title: SignUpState.lastName.isNotEmpty
                              ? Text(SignUpState.lastName)
                              : Text(
                                  "No last name set",
                                  style: TextStyle(
                                      color:
                                          const Color.fromARGB(104, 0, 0, 0)),
                                ),
                          subtitle: Text("Last Name"),
                        ),
                        ListTile(
                          title: LoginPageState.email.isNotEmpty
                              ? Text(LoginPageState.email)
                              : Text(
                                  "No email set",
                                  style: TextStyle(
                                      color:
                                          const Color.fromARGB(104, 0, 0, 0)),
                                ),
                          subtitle: Text("Email"),
                        ),
                        ListTile(
                          title: LoginPageState.password.isNotEmpty
                              ? Text(
                                  '\u2022' *
                                      (randomInRange(0, 4) +
                                          LoginPageState.passwordLength),
                                )
                              : Text(
                                  "No password set",
                                  style: TextStyle(
                                      color:
                                          const Color.fromARGB(104, 0, 0, 0)),
                                ),
                          subtitle: Text("Password"),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10, top: 8),
                          child: Text(
                            "Privacy and Security",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        ListTile(
                          title: Text("Change Password"),
                          onTap: () {},
                        ),
                        ListTile(
                          title: Text("Change Email"),
                          onTap: () {},
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      title: Text(
                        "Log out",
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () => iosAlert(
                        () {
                          LoginPageState.isLoggedIn = false;
                          StoredSettings.save(
                              isLoggedIn: LoginPageState.isLoggedIn);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                            (Route<dynamic> route) => false,
                          );
                          StoredSettings.logOut();
                        },
                        title: "Log out?",
                        content: "You can log back in any time.",
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    child: ListTile(
                      title: Text(
                        "Delete account",
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () => iosAlert(
                        () {
                          LoginPageState.isLoggedIn = false;
                          StoredSettings.save(
                              isLoggedIn: LoginPageState.isLoggedIn);
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        title: "Delete account?",
                        content:
                            "This will delete all the data on your account. You will need to re-create one to log back in.",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
      CupertinoPageRoute(
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
                          StoredSettings.save(
                              selectedIndex: StoredSettings.selectedIndex,
                              clickN: SosManager.clickN);
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
      CupertinoPageRoute(
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
                      () => iosAlert(
                        () {
                          Navigator.pop(context);
                          whichCodeChange();
                        },
                        title: "Are you sure?",
                        content: SosManager.fakeCode == null ||
                                SosManager.secretCode == null
                            ? "This will set your security code(s)."
                            : "This will change your security code(s).",
                      ),
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
                          CupertinoPageRoute(
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
            SosManager.fakeCode == null || SosManager.secretCode == null
                ? "Which code would you like to set?"
                : "Which code would you like to change?",
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
                child: Text(
                    SosManager.secretCode == null
                        ? "Set real code"
                        : "Change real code",
                    style: TextStyle(
                        color: const Color.fromARGB(255, 0, 120, 255)))),
            CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pop(context);
                  getCodeInput(false);
                },
                child: Text(
                    SosManager.fakeCode == null
                        ? "Set decoy code"
                        : "Change decoy code",
                    style: TextStyle(
                        color: const Color.fromARGB(255, 0, 120, 255)))),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                getCodeInput(false);
                getCodeInput(true);
              },
              child: Text(
                SosManager.fakeCode == null || SosManager.secretCode == null
                    ? "Set both"
                    : "Change both",
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 120, 255),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void iosAlert(Function proceed, {String? title, String? content}) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title ?? ""),
          content: Text(content ?? ""),
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

  static Future<void> sendPersonsList() async {
    Person.encodePerson(Person.persons);
    const ip = String.fromEnvironment("IP");
    Uri url = Uri.parse(
        'http://$ip/auth/verify-email'); //TODO fix to correct endpoint
    final serverResponse =
        await http.post(url, body: {'personsList': Person.encodedPersonString});

    if (serverResponse.statusCode == 200) {
      print(
          "serverResponse.statusCode = ${serverResponse.statusCode} \nServer received request.");
    } else {
      print(
          "serverResponse.statusCode = ${serverResponse.statusCode} \nServer failed to receive request.");
    }
  }
}
