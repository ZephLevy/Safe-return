import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safe_return/main.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  static bool isLoggedIn = false;
  late final email = _emailController.text;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final password = _passwordController.text;
      const ip = String.fromEnvironment("IP");
      print(email);

      if (ip.isNotEmpty) {
        final response = await http.post(Uri.parse("http://$ip/signIn"),
            body: {"email": email, "password": password});
        if (response.statusCode == 200) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeScreen()));
          print(response.statusCode);
        } else {
          print("no ip passed");
        }
      }
      print("huh");

      // Later this shouldn't push
    }
  }

  @override
  Widget build(BuildContext context) {
    final RegExp emailValidator = RegExp(
        r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])');
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
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
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
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
                  print("no account");
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
                    print(email);
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => HomeScreen()));
                  },
                  child: Text("Force Login [debugging only]",
                      style: TextStyle(fontSize: 15, color: Colors.red))),
            ],
          ),
        ),
      ),
    );
  }
}
