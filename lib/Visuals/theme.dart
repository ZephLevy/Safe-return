import 'package:flutter/material.dart';

class Themes {
  static final settingsThemeData = ThemeData(
    cardTheme: CardTheme(
      margin: EdgeInsets.symmetric(horizontal: 15),
      clipBehavior: Clip.antiAlias,
      elevation: 0.5,
    ),
    listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.only(left: 25, right: 20),
        titleTextStyle: TextStyle(fontSize: 17, color: Colors.black),
        subtitleTextStyle: TextStyle(fontSize: 11, color: Colors.black)),
  );
}
