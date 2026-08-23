//! Not goooood
//? On stand-by
// Overused comment
//todo I have way to much uncompleted code
//* This is okkkk
//. Fix the code
import 'dart:io';

import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:info_widget/info_widget.dart';
import 'package:safe_return/Visuals/theme.dart';
import 'package:safe_return/logic/home_page_updater.dart';
import 'package:safe_return/logic/location_logic/location_updater.dart';
import 'package:safe_return/pages/log_sign_up/login_page.dart';
import 'package:safe_return/pages/log_sign_up/sign_up_page.dart';
import 'package:safe_return/pages/all_settings_pages/account_page.dart';
import 'package:safe_return/pages/all_settings_pages/contacts_page.dart';
import 'package:safe_return/pages/all_settings_pages/home_selector_page.dart';
import 'package:safe_return/pages/all_settings_pages/preferred_viewer_page.dart';
import 'package:safe_return/pages/all_settings_pages/security_codes_page.dart';
import 'package:safe_return/storage.dart/stored_settings.dart';
import 'package:safe_return/inits/auth_init.dart';
import 'package:safe_return/inits/noti_init.dart';
import 'package:safe_return/storage.dart/tracking_storage.dart';

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
                  contentPadding: EdgeInsets.only(left: 10, right: 20),
                  leading: Icon(Icons.account_circle, size: 50),
                  minLeadingWidth: 50,
                  title:
                      // SignUpState.firstName.isNotEmpty
                      // ?
                      Text("${SignUpState.firstName} ${SignUpState.lastName}"),
                  // : Text("User#${randomAlphaNumeric(7).toUpperCase()}"),
                  subtitle: StatefulBuilder(builder: (context, setState) {
                    return Text(LoginPageState.userEmail);
                  }),
                  trailing: Icon(Icons.settings_rounded),
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
                left: 15, right: 15, bottom: Platform.isAndroid ? 1 : 10),
            child: Column(
              children: [
                // ListTile(
                //   title: Text("SOS Activation"),
                //   leading: Icon(Icons.sos_outlined),
                //   trailing: Icon(Icons.arrow_forward_ios_rounded),
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       CupertinoPageRoute(
                //         builder: (BuildContext context) =>
                //             SosActivationPage(), //* OPEN SOS ACTIVATION PAGE
                //       ),
                //     );
                //   },
                // ),
                ListTile(
                  title: Text("Emergency Contacts"),
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
                ListTile(
                  title: Text("Set Home Location"),
                  leading: Icon(Icons.home_rounded),
                  trailing: Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (BuildContext context) => HomeSelector()));
                  },
                ),
                ListTile(
                  title: Text("Power Saving Mode"),
                  // subtitle: Text(
                  //     "When switched on, location tracking will be reduced to save battery, decreasing your security."),
                  leading: Icon(Icons.battery_charging_full),
                  trailing: SizedBox(
                    width: 95,
                    child: Row(
                      spacing: 10,
                      children: [
                        InfoWidget(
                          infoText:
                              "When switched on, location tracking will be reduced to save battery, but decreases your security.",
                          iconData: Icons.info_outline,
                          iconColor: Colors.black87,
                          infoTextStyle: TextStyle(color: Colors.black87),
                        ),
                        Switch.adaptive(
                            value: LocationUpdaterState.powerSaving,
                            onChanged: (value) {
                              setState(() {
                                LocationUpdaterState.powerSaving = value;
                              });
                              TrackingStorage.save(
                                  powerSaving:
                                      LocationUpdaterState.powerSaving);
                              if (LocationUpdaterState.powerSaving) {
                                LocationUpdaterState.locationAccuracy =
                                    LocationAccuracy.POWERSAVE;
                              } else {
                                LocationUpdaterState.locationAccuracy =
                                    LocationAccuracy.BALANCED;
                              }
                            }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (Platform.isAndroid)
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
                  onTap: () {
                    if (!HomeUpdater.showTimer) {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (BuildContext context) =>
                              SecurityCodesPage(), //* OPEN SECURITY CODES PAGE
                        ),
                      );
                    }
                  },
                ),
                ListTile(
                  title: Text("Use Biometrics"),
                  leading: Icon(
                    Icons.fingerprint_rounded,
                    size: 22,
                  ),
                  trailing: SizedBox(
                    width: 95,
                    child: Row(
                      spacing: 10,
                      children: [
                        InfoWidget(
                          iconColor: Colors.black87,
                          iconData: Icons.info_outline,
                          infoText:
                              "Biometrics can be used as an additional security layer, like when changing or viewing your codes. For security reasons, biometrics cannot be used to open the app.",
                          infoTextStyle: TextStyle(color: Colors.black87),
                        ),
                        Switch.adaptive(
                          value: StoredSettings.biometricsValue,
                          onChanged: (bool value) {
                            AuthService.auth(
                              () {
                                setState(
                                  () {
                                    StoredSettings.biometricsValue = value;
                                  },
                                );
                                StoredSettings.save(
                                    biometricsValue:
                                        StoredSettings.biometricsValue);
                              },
                            );
                          },
                        ),
                      ],
                    ),
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
