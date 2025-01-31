import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Example")),
        body: Center(
            child: Container(
                width: 100,
                height: 100,
                margin: EdgeInsets.all(20),
                color: const Color.fromARGB(255, 42, 77, 255))),
      ),
    );
  }
}
