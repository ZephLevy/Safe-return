//! Not goooood
//? On stand-by
// Overused comment
//todo I have way to much uncompleted code
//* This is okkkk
//. Fix the code
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:random_string/random_string.dart';
import 'package:safe_return/Visuals/theme.dart';
import 'package:safe_return/login_page.dart';
import 'package:safe_return/pages/settings/account_page.dart';
import 'package:safe_return/pages/settings/contacts_page.dart';
import 'package:safe_return/pages/settings/preferred_viewer.dart';
import 'package:safe_return/pages/settings/security_codes_page.dart';
import 'package:safe_return/pages/settings/sos_activation.dart';
import 'package:safe_return/shared_prefs/stored_settings.dart';
import 'package:safe_return/utils/auth_service.dart';
import 'package:safe_return/utils/noti_service.dart';

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
                  title: SignUpState.firstName.isNotEmpty
                      ? Text("${SignUpState.firstName} ${SignUpState.lastName}")
                      : Text("User#${randomAlphaNumeric(7).toUpperCase()}"),
                  subtitle: StatefulBuilder(builder: (context, setState) {
                    return Text(LoginPageState.email);
                  }),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        fullscreenDialog: true,
                        barrierDismissible: true,
                        builder: (BuildContext context) {
                          return AccountPage(); //* OPEN ACCOUNT PAGE
                        },
                      ),
                    );
                  })),
          Card(
            margin: EdgeInsets.only(
                left: 15,
                right: 15,
                bottom: Platform.isAndroid
                    ? 1
                    : 10), //.j aksdjfklasj dlkfaj s;dlfjklasdjf
            child: Column(
              children: [
                ListTile(
                  title: Text("SOS Activation"),
                  subtitle: Text(
                    "Number of clicks required to activate SOS button",
                  ),
                  leading: Icon(Icons.sos_outlined),
                  trailing: Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (BuildContext context) =>
                            SosActivation(), //* OPEN SOS ACTIVATION PAGE
                      ),
                    );
                  },
                ),
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
                      builder: (BuildContext context) =>
                          ContactsPage(), //* OPEN EMERGENCY CONTACTS PAGE
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (Platform
              .isAndroid) //.jdsflka s;dklfj ;alksdfj klasdjf ;lasjd f;lks djfd
            Card(
              margin: EdgeInsets.only(left: 40, right: 15, bottom: 10),
              child: ListTile(
                contentPadding: EdgeInsets.only(left: 15, right: 20),
                minTileHeight: 45,
                titleTextStyle: TextStyle(fontSize: 15, color: Colors.black),
                title: Text("Preferred Contact Viewer"),
                leading: Icon(
                  Icons.view_carousel_outlined,
                  size: 22,
                ),
                trailing: Icon(Icons.arrow_forward_ios_rounded),
                onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute<Widget>(
                    builder: (BuildContext context) =>
                        PreferredViewer(), //* OPEN VIEWTYPE MENU PAGE
                  ),
                ),
              ),
            ),
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
                  onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (BuildContext context) =>
                          SecurityCodesPage(), //* OPEN SECURITY CODES PAGE
                    ),
                  ),
                ),
                ListTile(
                  title: Text("Use Biometrics"),
                  leading: Icon(
                    Icons.fingerprint_rounded,
                    size: 22,
                  ),
                  trailing: Switch.adaptive(
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
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text("Test Notification"),
                  subtitle: Text(
                      "What will be sent if you are not home by the set time."),
                  leading: Icon(Icons.notifications),
                  onTap: () {
                    NotiService().notHomeNotif(); //* SEND TEST NOTIFICATION
                    ContactsPageState
                        .sendPersonsList(); //TODO remove this in production, only for debugging so far, no point in having it for test notif
                  },
                ),
              ],
            ),
          )
        ],
      ),
    ]);
  }

  static void adaptiveAlert(BuildContext context, Function proceed,
      {String? title, String? content}) {
    List<Widget> cupertinoButtons() {
      return [
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
      ];
    }

    List<Widget> materialButtons() {
      return [
        TextButton(
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
        TextButton(
            onPressed: () {
              proceed();
            },
            child: Text("continue", style: TextStyle(color: Colors.red)))
      ];
    }

    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog.adaptive(
          title: Text(title ?? ""),
          content: Text(content ?? ""),
          actions: Platform.isIOS ? cupertinoButtons() : materialButtons(),
        );
      },
    );
  }
}
