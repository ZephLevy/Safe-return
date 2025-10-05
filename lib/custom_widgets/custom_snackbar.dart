//Copyright (c) 2020, LanarsInc
// All rights reserved.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/safe_area_values.dart';
import 'package:top_snackbar_flutter/tap_bounce_container.dart';

typedef ControllerCallback = void Function(AnimationController);

/// Possible triggers to dismiss the snackbar.
enum DismissType { onTap, onSwipe, none }

/// Possible vertical positions for the snackbar.
enum SnackBarPosition { top, bottom }

OverlayEntry? _previousEntry;

/// Displays a widget above the current contents of the app, with animation.
void showTopSnackBar(
  OverlayState overlayState,
  Widget child, {
  Duration animationDuration = const Duration(milliseconds: 1200),
  Duration reverseAnimationDuration = const Duration(milliseconds: 350),
  Duration displayDuration = const Duration(milliseconds: 3000),
  VoidCallback? onTap,
  bool persistent = false,
  ControllerCallback? onAnimationControllerInit,
  EdgeInsets padding = const EdgeInsets.all(16),
  Curve curve = Curves.elasticOut,
  Curve reverseCurve = Curves.linearToEaseOut,
  SafeAreaValues safeAreaValues = const SafeAreaValues(),
  List<DismissType> dismissTypes = const [
    DismissType.onTap,
    DismissType.onSwipe
  ],
  SnackBarPosition snackBarPosition = SnackBarPosition.top,
  List<DismissDirection> dismissDirection = const [DismissDirection.up],
  VoidCallback? onDismissed,
}) {
  late OverlayEntry _overlayEntry;

  _overlayEntry = OverlayEntry(
    builder: (_) {
      return _TopSnackBar(
        child: child,
        onDismissed: () {
          if (overlayState.mounted) _overlayEntry.remove();
          _previousEntry = null;
          onDismissed?.call();
        },
        animationDuration: animationDuration,
        reverseAnimationDuration: reverseAnimationDuration,
        displayDuration: displayDuration,
        onTap: onTap,
        persistent: persistent,
        onAnimationControllerInit: onAnimationControllerInit,
        padding: padding,
        curve: curve,
        reverseCurve: reverseCurve,
        safeAreaValues: safeAreaValues,
        dismissTypes: dismissTypes,
        snackBarPosition: snackBarPosition,
        dismissDirections: dismissDirection,
      );
    },
  );

  // Remove previous snackbar if exists
  if (_previousEntry != null && _previousEntry!.mounted) {
    _previousEntry?.remove();
  }

  overlayState.insert(_overlayEntry);
  _previousEntry = _overlayEntry;
}

/// Internal widget that controls snackbar animations and dismissal.
class _TopSnackBar extends StatefulWidget {
  const _TopSnackBar({
    Key? key,
    required this.child,
    required this.onDismissed,
    required this.animationDuration,
    required this.reverseAnimationDuration,
    required this.displayDuration,
    required this.padding,
    required this.curve,
    required this.reverseCurve,
    required this.safeAreaValues,
    required this.dismissDirections,
    required this.snackBarPosition,
    this.onTap,
    this.persistent = false,
    this.onAnimationControllerInit,
    this.dismissTypes = const [DismissType.onTap, DismissType.onSwipe],
  }) : super(key: key);

  final Widget child;
  final VoidCallback onDismissed;
  final Duration animationDuration;
  final Duration reverseAnimationDuration;
  final Duration displayDuration;
  final VoidCallback? onTap;
  final ControllerCallback? onAnimationControllerInit;
  final bool persistent;
  final EdgeInsets padding;
  final Curve curve;
  final Curve reverseCurve;
  final SafeAreaValues safeAreaValues;
  final List<DismissType> dismissTypes;
  final List<DismissDirection> dismissDirections;
  final SnackBarPosition snackBarPosition;

  @override
  _TopSnackBarState createState() => _TopSnackBarState();
}

class _TopSnackBarState extends State<_TopSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Offset> _offsetAnimation;
  late final Tween<Offset> _offsetTween;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
      reverseDuration: widget.reverseAnimationDuration,
    );

    _animationController.addStatusListener(
      (status) {
        if (status == AnimationStatus.completed && !widget.persistent) {
          _timer = Timer(widget.displayDuration, () {
            if (mounted) _animationController.reverse();
          });
        }
        if (status == AnimationStatus.dismissed) {
          _timer?.cancel();
          widget.onDismissed();
        }
      },
    );

    widget.onAnimationControllerInit?.call(_animationController);

    _offsetTween = (widget.snackBarPosition == SnackBarPosition.top)
        ? Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        : Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero);

    _offsetAnimation = _offsetTween.animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.curve,
        reverseCurve: widget.reverseCurve,
      ),
    );

    if (mounted) _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.snackBarPosition == SnackBarPosition.top
          ? widget.padding.top
          : null,
      bottom: widget.snackBarPosition == SnackBarPosition.bottom
          ? widget.padding.bottom
          : null,
      left: widget.padding.left,
      right: widget.padding.right,
      child: SlideTransition(
        position: _offsetAnimation,
        child: SafeArea(
          top: widget.safeAreaValues.top,
          bottom: widget.safeAreaValues.bottom,
          left: widget.safeAreaValues.left,
          right: widget.safeAreaValues.right,
          minimum: widget.safeAreaValues.minimum,
          maintainBottomViewPadding:
              widget.safeAreaValues.maintainBottomViewPadding,
          child: _buildDismissibleChild(),
        ),
      ),
    );
  }

  Widget _buildDismissibleChild() {
    Widget childWidget = widget.child;

    // Handle onTap
    if (widget.dismissTypes.contains(DismissType.onTap)) {
      childWidget = TapBounceContainer(
        onTap: () {
          widget.onTap?.call();
          if (mounted) _animationController.reverse();
        },
        child: childWidget,
      );
    }

    // Handle onSwipe
    if (widget.dismissTypes.contains(DismissType.onSwipe)) {
      for (final direction in widget.dismissDirections) {
        childWidget = Dismissible(
          key: UniqueKey(),
          direction: direction,
          dismissThresholds: const {DismissDirection.up: 0.2},
          confirmDismiss: (dir) async {
            if (mounted) {
              await _animationController.reverse();
            }
            return false;
          },
          child: childWidget,
        );
      }
    }

    // Handle   ne (optional, just ensures onTap works)
    if (widget.dismissTypes.contains(DismissType.none)) {
      childWidget = TapBounceContainer(
        onTap: () => widget.onTap?.call(),
        child: childWidget,
      );
    }

    return childWidget;
  }
}
