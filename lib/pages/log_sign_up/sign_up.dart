import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:safe_return/logic/tokens.dart';
import 'package:safe_return/login_page.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  final signUpformKey = GlobalKey<FormState>();
  final firstNcontroller = TextEditingController();
  final lastNcontroller = TextEditingController();
  final newEmailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  static String firstName = "";
  static String lastName = "";
  static String newPassword = "";
  static String newEmail = "";
  static String confirmPassword = "";
  static String emailCode = "";

  @override
  void dispose() {
    firstNcontroller.dispose();
    lastNcontroller.dispose();
    newEmailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Account")),
      body: Form(
        key: signUpformKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  autocorrect: true,
                  autofillHints: [AutofillHints.givenName],
                  controller: firstNcontroller,
                  decoration: InputDecoration(labelText: "First Name"),
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a first name';
                    }
                    if (value.trim().split(' ').length > 1) {
                      return 'First name must only be one word';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  autocorrect: true,
                  autofillHints: [AutofillHints.familyName],
                  controller: lastNcontroller,
                  decoration: InputDecoration(
                      labelText: "Last Name", helperText: "Optional"),
                  validator: (value) {
                    if (value != null) {
                      if (value.trim().split(' ').length > 1) {
                        return 'Last name must only be one word';
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  autocorrect: false,
                  autofillHints: [AutofillHints.email],
                  controller: newEmailController,
                  decoration: InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email address';
                    }
                    if (LoginPageState().emailValidator.hasMatch(value)) {
                      return null;
                    }
                    return 'Invalid email address';
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  maxLength: 30,
                  autocorrect: false,
                  autofillHints: [AutofillHints.newPassword],
                  controller: newPasswordController,
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                      return 'Include at least one uppercase letter';
                    }
                    if (!RegExp(r'[a-z]').hasMatch(value)) {
                      return 'Include at least one lowercase letter';
                    }
                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                      return 'Include at least one digit';
                    }

                    if (value.contains(' ')) {
                      return 'No spaces allowed';
                    }

                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  maxLength: 30,
                  autocorrect: false,
                  autofillHints: null,
                  controller: confirmPasswordController,
                  decoration: InputDecoration(labelText: "Confirm Password"),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value != newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(150, 40),
                    ),
                    onPressed: () {
                      signUp();
                    },
                    child:
                        Text("Create Account", style: TextStyle(fontSize: 15))),
                ElevatedButton(
                    onPressed: () => emailVerification(),
                    child: Text("debug force sign up"))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signUp() {
    if (signUpformKey.currentState!.validate()) {
      newEmail = newEmailController.text;
      sendEmailUseCheck(
        () {
          SignUpState.newEmail = newEmailController.text;
          SignUpState.newPassword = newPasswordController.text;
          firstName = firstNcontroller.text;
          lastName = lastNcontroller.text;
          emailVerification();
        },
      );
    }
  }

  emailVerification() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "Almost done!",
                    style: TextStyle(fontSize: 30),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Text(
                    "Verification code sent to: \n${SignUpState.newEmail}",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.center,
                  child: Text(
                    "Wrong email? Change it here.",
                    style: TextStyle(fontSize: 15),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: PinCodeTextField(
                    useHapticFeedback: true,
                    hapticFeedbackTypes: HapticFeedbackTypes.light,
                    beforeTextPaste: (text) {
                      if (text != null && RegExp(r'^\d{6}$').hasMatch(text)) {
                        return true;
                      } else {
                        return false;
                      }
                    },
                    appContext: context,
                    length: 6,
                    onChanged: (value) {},
                    onCompleted: (value) {
                      // print("Completed: $value");
                      emailCode = value;
                      // print(emailCode);
                    },
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeFillColor: Colors.white,
                      selectedFillColor: Colors.white,
                      inactiveFillColor: Colors.grey.shade200,
                      activeColor: Colors.blue,
                      selectedColor: Colors.black,
                      inactiveColor: Colors.grey,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    animationType: AnimationType.fade,
                    enableActiveFill: true,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: Size(160, 40)),
                    onPressed: () async {
                      await sendNewAccountData(() {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      });
                    },
                    child: Text(
                      "Verify",
                      style: TextStyle(fontSize: 18),
                    )),
                CupertinoButton(
                  child: Text("Didn't receive a code? Click here."),
                  onPressed: () => print("resend code"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> sendNewAccountData(if200) async {
    const ip = String.fromEnvironment("IP");
    Uri url = Uri.parse('http://$ip/auth/signup');
    Map<String, String> body = {
      'firstName': firstName,
      'lastName': lastName,
      'email': newEmail,
      'password': newPassword,
      'emailCode': emailCode,
    };

    final response = await http.post(
      url,
      body: jsonEncode(body),
      headers: {'Content-Type': 'application/json'},
    );
    // print(newEmail);
    // print(firstName);
    // print(lastName);
    // print(newPassword);
    // print(emailCode);
    if (response.statusCode == 200) {
      // print(newEmail);
      firstName = "";
      lastName = "";
      newEmail = "";
      newPassword = "";
      emailCode = "";
      //TODO get tokens
      print("successful verification code: ${response.statusCode}");
      print("body: ${response.body}");
      Tokens.signUpTokens = response.body;
      Tokens.accessToken = jsonDecode(response.body)['access_token'];
      Tokens.refreshToken = jsonDecode(response.body)['refresh_token'];

      if200();
    } else if (response.statusCode == 400) {
      print("one or more values are null");
    } else if (response.statusCode == 409) {
      print("email already in use");
    } else if (response.statusCode == 401) {
      print("missing fields");
    } else {
      print("internal server error :) ${response.statusCode}");
    }
  }

  Future<void> sendEmailUseCheck(if200) async {
    const ip = String.fromEnvironment("IP");
    Uri url = Uri.parse('http://$ip/auth/verify-email');
    final response = await http.post(
      url,
      body: jsonEncode({
        'email': newEmail,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    print(newEmail);
    if (response.statusCode == 200) {
      //TODO get tokens
      print("email not in use, successful: ${response.statusCode}");

      if200();
    } else if (response.statusCode == 401) {
      print("one or more values are null");
      print(response.body);
    } else if (response.statusCode == 409) {
      print("email already in use");
    } else if (response.statusCode == 500) {
      print("internal server error (status ${response.statusCode})");
    } else {
      print(
          "An error occured while signing you up, please try again. ${response.statusCode}");
    }
  }
}
