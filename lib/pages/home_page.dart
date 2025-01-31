import 'package:flutter/material.dart';
import 'package:safe_return/palette.dart';
import 'package:flutter/cupertino.dart';

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
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: double.infinity,
                height: 150,
                child: CupertinoDatePicker(
                  onDateTimeChanged: (value) {
                    print(value);
                  },
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: true,
                ),
              ),
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
