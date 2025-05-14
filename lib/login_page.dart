import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe_return/main.dart';
import 'package:http/http.dart' as http;
import 'package:safe_return/utils/stored_settings.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final RegExp emailValidator = RegExp(
      r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
      r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
      r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
      r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
      r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
      r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
      r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])');
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  static var password = LoginPageState().passwordController.text;
  static var email = LoginPageState().emailController.text;
  static bool isLoggedIn = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
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
                    onPressed: _login,
                    child: Text("Login")),
                CupertinoButton(
                  padding: EdgeInsets.only(top: 20),
                  minSize: 0,
                  onPressed: () {
                    resetLoginForms();
                    noAccount();
                  },
                  child: Text(
                    "No account? Create one here!",
                    style: TextStyle(fontSize: 17),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(150, 40),
                    ),
                    onPressed: () {
                      print(emailController.text);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen()));
                    },
                    child: Text("Force Login [debugging only]",
                        style: TextStyle(fontSize: 15, color: Colors.red))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void resetLoginForms() {
    _formKey.currentState?.reset();
  }

  void noAccount() {
    Navigator.push(
        context,
        CupertinoPageRoute(
            fullscreenDialog: true, builder: (context) => SignUp()));
  }

  Future<void> _login() async {
    const ip = String.fromEnvironment("IP");
    if (_formKey.currentState!.validate()) {
      email = emailController.text;
      password = passwordController.text;
      print(email);
      print(password);
      isLoggedIn = true; //todo this should be inside statusCode == 200
      StoredSettings.save(
          isLoggedIn:
              isLoggedIn); //todo this should be inside statusCode == 200
      if (ip.isNotEmpty) {
        StoredSettings.save(userEmail: email);
        final response = await http.post(Uri.parse("http://$ip/signIn"),
            body: {"email": email, "password": password});
        if (response.statusCode == 200) {
          if (mounted) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomeScreen()));
            print(response.statusCode);
          }
        } else {
          print("error: code ${response.statusCode}");
        }
      }
      print("huh");
    }
  }
}

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

  static var firstName = SignUpState().firstNcontroller.text;
  static var lastName = SignUpState().lastNcontroller.text;
  static var newPassword = SignUpState().newPasswordController.text;
  static var newEmail = SignUpState().newEmailController.text;
  static var confirmPassword = SignUpState().confirmPasswordController.text;

  @override
  void dispose() {
    newEmailController.dispose();
    newPasswordController.dispose();
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
                  controller: firstNcontroller,
                  decoration: InputDecoration(labelText: "First Name"),
                  keyboardType: TextInputType.emailAddress,
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
                    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                      return 'Include at least one special character';
                    }
                    if (value.contains(' ')) {
                      return 'No spaces allowed';
                    }

                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
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
      newPassword = newPasswordController.text;
      firstName = firstNcontroller.text;
      lastName = lastNcontroller.text;
      StoredSettings.save(
          newEmail: newEmail,
          newPassword: newPassword,
          firstName: firstName,
          lastName: lastName);
      emailVerification();
      // Navigator.pop(
      //     context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  emailVerification() {
    Navigator.push(context, CupertinoPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          // title: Text("Email Verification"),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "Almost done!",
                style: TextStyle(fontSize: 25),
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
                "Wrong one? Change it here.",
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
                onChanged: (value) {
                  print(value);
                },
                onCompleted: (value) {
                  print("Completed: $value");
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
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
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
    }));
  }
}
