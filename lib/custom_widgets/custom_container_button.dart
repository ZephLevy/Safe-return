import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';

class ShrinkTapContainer extends StatelessWidget {
  final void Function()? onTap;
  final Color color;
  final Widget? child;

  const ShrinkTapContainer(
      {this.onTap, required this.color, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return TapBounceContainer(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              spreadRadius: 3,
              blurRadius: 7,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}

class InkwellContainer extends StatelessWidget {
  final Color color;
  final Widget? child;
  final BorderRadius? borderRadius;
  final Function()? onTap;
  const InkwellContainer(
      {required this.color,
      this.borderRadius,
      this.onTap,
      this.child,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            spreadRadius: 3,
            blurRadius: 7,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        borderRadius: borderRadius,
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
          ),
          child: InkWell(
            splashColor: Colors.black12,
            borderRadius: borderRadius,
            onTap: onTap,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
