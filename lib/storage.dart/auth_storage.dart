import 'package:flutter/cupertino.dart';
import 'package:safe_return/pages/log_sign_up/login_page.dart';
import 'package:safe_return/pages/log_sign_up/sign_up_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage extends ChangeNotifier {
  static final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

  static Future<void> save({
    String? userEmail,
    bool? isLoggedIn,
    String? firstName,
    String? lastName,
  }) async {
    if (userEmail != null) {
      await asyncPrefs.setString('userEmail', userEmail);
    }
    if (isLoggedIn != null) {
      await asyncPrefs.setBool('isLoggedIn', isLoggedIn);
    }
    if (firstName != null) {
      await asyncPrefs.setString('firstName', firstName);
    }
    if (lastName != null) {
      await asyncPrefs.setString('lastName', lastName);
    }
  }

  static Future<void> load() async {
    LoginPageState.userEmail = await asyncPrefs.getString('userEmail') ?? "";
    LoginPageState.isLoggedIn = await asyncPrefs.getBool('isLoggedIn') ?? false;
    SignUpState.firstName = await asyncPrefs.getString('firstName') ?? "";
    SignUpState.lastName = await asyncPrefs.getString('lastName') ?? "";
  }
}
