// ignore_for_file: deprecated_member_use
// ignore: fcheck_magic_numbers
import 'dart:ui';
import 'package:cards/models/app/constants_animation.dart';
import 'package:flutter/material.dart';

/// A custom rounded rectangular glass-like button with blur and ripple effects.
///
/// This widget displays a rounded rectangular button with a glassmorphic (frosted glass) appearance,
/// including a blurred background, border, gradient, and ripple effect on tap.
/// The child widget is centered inside the button.
class MyButton extends StatelessWidget {
  /// Creates a [MyButton].
  ///
  /// [onTap] is called when the button is tapped.
  /// [child] is the widget displayed inside the button.
  /// [height] determines the height of the button (default is 44).
  /// [width] determines the width of the button (default is 200).
  /// [borderRadius] determines the corner radius of the button (default is 12).
  /// [padding] adds padding around the button (default is [EdgeInsets.all(0)]).
  const MyButton({
    super.key,
    required this.onTap,
    required this.child,
    this.height = 44,
    this.width = 200,
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(0),
  });

  /// The corner radius of the button.
  final double borderRadius;

  /// The widget displayed at the center of the button.
  final Widget child;

  /// The height of the button.
  final double height;

  /// Called when the button is tapped.
  final VoidCallback? onTap;

  /// Padding around the button.
  final EdgeInsets padding;

  /// The width of the button.
  final double width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Blur whatever is behind the button
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: ConstAnimation.blurSigma,
                  sigmaY: ConstAnimation.blurSigma,
                ),
                child: const SizedBox.shrink(),
              ),
              // Glassy layer
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(
                        ConstAnimation.blackOverlayOpacity,
                      ),
                      Colors.black.withOpacity(
                        ConstAnimation.blackBackgroundOpacity,
                      ),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(
                      ConstAnimation.borderOpacity,
                    ),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                      color: Colors.black.withOpacity(0.8),
                    ),
                    BoxShadow(
                      blurRadius: 6,
                      spreadRadius: 0,
                      offset: const Offset(-2, -2),
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
              // Ink ripple
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  enableFeedback: onTap != null,
                  onTap: onTap,
                  splashColor: Colors.white.withOpacity(
                    ConstAnimation.whiteOverlayOpacity,
                  ),
                  highlightColor: Colors.white.withOpacity(
                    ConstAnimation.whiteHighlightOpacity,
                  ),
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: Center(child: child),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
