import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:safe_return/palette.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _sosButton(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _timeSetter(),
        ],
      ),
    );
  }

  Widget _timeSetter() {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Palette.blue1,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              'Be Home By:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Palette.blue1,
              width: 1.5,
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 200,
            child: Center(
              child: Scaffold(),
            ),
          ),
        )
      ],
    );
  }

  FloatingActionButton _sosButton() {
    return FloatingActionButton.large(
      onPressed: () {},
      backgroundColor: Color(0xffB20000),
      child: Icon(
        Icons.sos,
        size: 55,
        color: Palette.blue1,
      ),
    );
  }
}

class Time extends StatelessWidget {
  final int index;
  const Time({required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(1),
        child: Text(
          index.toString(),
        ),
      ),
    );
  }
}
