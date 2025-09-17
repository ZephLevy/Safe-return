import 'package:flutter/material.dart';

class CustomGradient extends StatelessWidget {
  final double height;
  final List<Color> colors;
  final EdgeInsetsGeometry? margin;
  const CustomGradient(
      {required this.height, this.margin, required this.colors, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      margin: margin,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
        ),
      ),
    );
  }
}
