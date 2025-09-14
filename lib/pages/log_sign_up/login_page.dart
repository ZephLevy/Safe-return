import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:safe_return/main.dart';
import 'package:safe_return/pages/log_sign_up/sign_up.dart';
import 'package:safe_return/storage.dart/stored_settings.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final RegExp emailValidator = RegExp(
      r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-l0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])');
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  static String password = "";
  static String userEmail = "";
  static bool isLoggedIn = false;
  static int passwordLength = 0;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        actions: [
          CupertinoButton(
              padding: EdgeInsets.only(right: 20),
              onPressed: () {
                skipLoginAlert(
                  () {
                    isLoggedIn = true;
                    StoredSettings.save(isLoggedIn: isLoggedIn);
                    StoredSettings.logOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                );
              },
              child: Text("Skip", style: TextStyle(fontSize: 17))),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  autocorrect: false,
                  autofillHints: [AutofillHints.email],
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email address';
                    }
                    if (emailValidator.hasMatch(value)) {
                      return null;
                    }
                    return 'Invalid email address';
                  },
                ),
                TextFormField(
                  maxLength: 30,
                  autocorrect: false,
                  autofillHints: [AutofillHints.password],
                  controller: passwordController,
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }

                    return null;
                  },
                ),
                SizedBox(height: 35),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: Size(150, 40),
                      textStyle: TextStyle(fontSize: 17)),
                  onPressed: () {
                    _login;
                  },
                  child: Text("Login"),
                ),
                SizedBox(height: 10),
                CupertinoButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    signUp();
                  },
                  child: Text(
                    "No account? Create one here!",
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void skipLoginAlert(Function proceed) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Are you sure?"),
          content: Text(
              "By skipping, any data will not be saved to the cloud. If you lose your phone or uninstall the app, all app data will be lost."),
          actions: [
            CupertinoDialogAction(
                onPressed: () {
                  proceed();
                },
                child: Text("Skip and continue as guest",
                    style: TextStyle(color: Colors.red, fontSize: 16.5))),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "cancel",
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 120, 255),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void signUp() {
    _formKey.currentState?.reset();
    Navigator.push(
        context,
        CupertinoPageRoute(
            fullscreenDialog: true, builder: (context) => SignUp()));
  }

  Future<void> _login() async {
    const ip = String.fromEnvironment("IP");
    if (_formKey.currentState!.validate()) {
      userEmail = emailController.text;
      password = passwordController.text;

      if (ip.isNotEmpty) {
        StoredSettings.save(userEmail: userEmail);
        final response = await http.post(
          Uri.parse("http://$ip/logIn"),
          body: {
            "email": userEmail,
            "password": password,
          },
        );
        if (response.statusCode == 200) {
          int randomInRange(int min, int max) {
            return Random().nextInt(max - min + 1) + min;
          }

          if (password.isNotEmpty) {
            passwordLength =
                randomInRange(1, 5) + (LoginPageState.password.length);
          }
          password = "";
          isLoggedIn = true;
          StoredSettings.save(isLoggedIn: isLoggedIn);
          if (mounted) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
          }
        } else {
          print("error: code ${response.statusCode}");
        }
      }
      print("not connected to server");
    }
  }
}
