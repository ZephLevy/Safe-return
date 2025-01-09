import 'package:flutter/material.dart';
import 'package:safe_return/palette.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _sosButton(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _timeLeft()
        ],
      )
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

  Widget _timeLeft() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      width: double.infinity,
      child: Card(
        color: Color(0xffD6D6D6), //TODO: make this a different color when user is on trip
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20) 
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Time left: []',
              style: TextStyle(fontSize: 18)
            ),
          ),
        ),
      ),
    );
  }
}
