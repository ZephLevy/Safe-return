import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends ChangeNotifier {
  String password = "";
  String userEmail = "";
  bool isLoggedIn = false;
  int passwordLength = 0;

  final asyncPrefs = SharedPreferencesAsync();
}
