import 'package:flutter/material.dart';
import 'package:safe_return/logic/global_vars.dart';

class InternetError extends StatefulWidget {
  const InternetError({super.key});

  @override
  State<InternetError> createState() => _InternetErrorState();
}

class _InternetErrorState extends State<InternetError> {
  @override
  Widget build(BuildContext context) {
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
