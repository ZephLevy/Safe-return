import 'package:flutter/material.dart';

class CustomGradientContainer extends StatelessWidget {
  final double height;
  final List<Color> colors;
  final EdgeInsetsGeometry? margin;
  const CustomGradientContainer(
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
