import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe_return/pages/time_manager.dart';
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
          TimeSetButton(),
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
                    TimeManager().selectedTime = value;
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

class TimeSetButton extends StatefulWidget {
  const TimeSetButton({super.key});

  @override
  State<TimeSetButton> createState() => _TimeSetButtonState();
}

class _TimeSetButtonState extends State<TimeSetButton> {
  bool isSelected = false;
  DateTime date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: double.infinity,
      child: Material(
        child: GestureDetector(
          onTap: () {
            setState(() {
              date = TimeManager().selectedTime;
              isSelected = false;
              HapticFeedback.mediumImpact();
            });
            print(date);
          },
          onTapDown: (details) {
            setState(() {
              isSelected = true;
            });
          },
          child: Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Palette.blue1,
                width: 1.5,
              ),
              color: isSelected ? Palette.blue3 : Palette.blue4,
            ),
            child: SizedBox.expand(
              child: Center(
                child: Text(
                  'Set',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
