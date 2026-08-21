import 'package:flutter/material.dart';
import 'package:safe_return/logic/global_vars.dart';

class InternetError {
  static Widget noInternet(bool reConnecting) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, size: 30),
          Text("No internet connection"),
          TextButton(
              onPressed: (() async {
                reconnectingNotifier.tryReconnect(() async {
                  await Future.delayed(Duration(seconds: 1));
                });
              }),
              child: Text("Try Again"))
        ],
      ),
    );
  }
}
