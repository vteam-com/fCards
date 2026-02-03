// ignore: fcheck_magic_numbers
import 'dart:math';
import 'package:cards/models/app/constants_animation.dart';
import 'package:flutter/material.dart';

/// Whether the [WiggleWidget] should wiggle or not.
class WiggleWidget extends StatefulWidget {
  ///
  const WiggleWidget({super.key, required this.child, this.wiggle = true});

  ///
  final Widget child;

  ///
  final bool wiggle;

  @override
  WiggleWidgetState createState() => WiggleWidgetState();
}

///
class WiggleWidgetState extends State<WiggleWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  final Random _random = Random();

  Animation<double>? _wiggleAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      duration: const Duration(
        milliseconds: ConstAnimation.wiggleAnimationDuration,
      ),
      vsync: this,
    ); // Repeat the animation back and forth

    _controller!.value = _random.nextDouble();
    _controller!.repeat(reverse: true);

    // Define the wiggle animation with a slight rotation angle
    _wiggleAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller
        ?.dispose(); // Clean up the controller when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.wiggle) {
      if (_wiggleAnimation != null) {
        return AnimatedBuilder(
          animation: _wiggleAnimation!,
          builder: (context, child) {
            return Transform.rotate(
              angle: _wiggleAnimation!.value,
              child: child,
            );
          },
          child: widget.child,
        );
      }
    }
    return widget.child;
  }
}
