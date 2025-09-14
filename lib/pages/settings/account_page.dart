import 'package:flutter/material.dart';
import 'package:safe_return/Visuals/theme.dart';
import 'package:safe_return/pages/log_sign_up/login_page.dart';
import 'package:safe_return/pages/log_sign_up/sign_up.dart';
import 'package:safe_return/storage.dart/stored_settings.dart';
import 'package:safe_return/pages/main_pages/settings_page.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
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
                                color: const Color.fromARGB(104, 0, 0, 0)),
                          ),
                    subtitle: Text("First Name"),
                  ),
                  ListTile(
                    title: SignUpState.lastName.isNotEmpty
                        ? Text(SignUpState.lastName)
                        : Text(
                            "No last name set",
                            style: TextStyle(
                                color: const Color.fromARGB(104, 0, 0, 0)),
                          ),
                    subtitle: Text("Last Name"),
                  ),
                  ListTile(
                    title: LoginPageState.userEmail.isNotEmpty
                        ? Text(LoginPageState.userEmail)
                        : Text(
                            "No email set",
                            style: TextStyle(
                                color: const Color.fromARGB(104, 0, 0, 0)),
                          ),
                    subtitle: Text("Email"),
                  ),
                  ListTile(
                    title: Text('\u2022' * 20),
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
                onTap: () => SettingsState.adaptiveAlert(
                  context,
                  () {
                    LoginPageState.isLoggedIn = false;
                    StoredSettings.save(isLoggedIn: LoginPageState.isLoggedIn);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginPage()),
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
                onTap: () => SettingsState.adaptiveAlert(
                  context,
                  () {
                    LoginPageState.isLoggedIn = false;
                    StoredSettings.save(isLoggedIn: LoginPageState.isLoggedIn);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginPage()),
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
  }
}
