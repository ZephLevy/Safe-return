import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safe_return/pages/settings_page.dart';
import 'package:safe_return/shared_prefs/stored_settings.dart';
import 'package:safe_return/utils/auth_service.dart';
import 'package:safe_return/utils/sos_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityCodesPage extends StatefulWidget {
  const SecurityCodesPage({super.key});

  @override
  State<SecurityCodesPage> createState() => _SecurityCodesPageState();
}

class _SecurityCodesPageState extends State<SecurityCodesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Security Codes"),
      ),
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: [
          ListTile(
            title: Text(SosManager.secretCode == null
                ? "Set Real Code"
                : "Change Real Code"),
            leading: Icon(
                SosManager.secretCode == null ? Icons.input : Icons.lock_reset),
            onTap: () {
              useBiometricsTo(
                () => SettingsState.adaptiveAlert(
                  context,
                  () {
                    Navigator.pop(context);
                    getCodeInput(true);
                  },
                  title: "Are you sure?",
                  content: SosManager.secretCode == null
                      ? "This will set your real code."
                      : "This will change your real code.",
                ),
              );
            },
          ),
          ListTile(
            title: Text(SosManager.fakeCode == null
                ? "Set Decoy Code"
                : "Change Decoy Code"),
            leading: Icon(
                SosManager.fakeCode == null ? Icons.input : Icons.lock_reset),
            onTap: () {
              useBiometricsTo(
                () => SettingsState.adaptiveAlert(
                  context,
                  () {
                    Navigator.pop(context);
                    getCodeInput(false);
                  },
                  title: "Are you sure?",
                  content: SosManager.fakeCode == null
                      ? "This will set your decoy code."
                      : "This will change your decoy code.",
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
                      builder: (BuildContext context) => viewCodes(),
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
  }

  void useBiometricsTo(Function action) {
    if (StoredSettings.biometricsValue) {
      AuthService.auth(action);
    } else {
      action();
    }
  }

  Widget viewCodes() {
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
                Text(
                  SosManager.secretCode ?? "No real code set",
                  style: TextStyle(color: Color.fromARGB(255, 100, 100, 100)),
                ),
              ],
            ),
          ),
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Your decoy code:"),
                Text(
                  SosManager.fakeCode ?? "No decoy code set",
                  style: TextStyle(
                      color: const Color.fromARGB(255, 100, 100, 100)),
                ),
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
}
