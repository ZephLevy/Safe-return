import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:safe_return/logic/location_logic/location_updater.dart';

class Tokens {
  static String? signUpTokens;
  static String? newTokenPair;
  static String? accessToken;
  static String? refreshToken;

  static Future<void> getTokens() async {
    const String ip = String.fromEnvironment('IP');
    try {
      if (ip == "") {
        print("No ip passed to CLI when run");
      }
      Uri url = Uri.parse('http://$ip/user-status/update-location');
      //TODO put correct endpoint

      final response = await http.post(url, body: Tokens.refreshToken);
      if (response.statusCode == 200) {
        print('Success: ${response.body}');
        Tokens.accessToken = jsonDecode(response.body)['access_token'];
        Tokens.refreshToken = jsonDecode(response.body)['refresh_token'];
      } else {
        print('Failed to refresh tokens with status: ${response.statusCode}');
      }
    } catch (e) {
      print("Could not connect to server/server not running");
      print("e: $e");
    }
    return;
  }

  static Future<void> triggerRefreshTokens() async {
    if (LocationUpdaterState.lastTokenRefresh != null) {
      bool needsRefresh =
          DateTime.now().difference(LocationUpdaterState.lastTokenRefresh!) >
              Duration(minutes: 25);

      if (needsRefresh) {
        await getTokens();
      } else {}
    } else {}
  }
}
