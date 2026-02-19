// ignore_for_file: deprecated_member_use

import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/buttons/my_button.dart';
import 'package:flutter/material.dart';

/// A custom rounded rectangular glass-like button with blur and ripple effects.
///
/// This widget displays a rounded rectangular button with a glassmorphic (frosted glass) appearance,
/// including a blurred background, border, gradient, and ripple effect on tap.
/// The child widget is centered inside the button.
class MyButtonRectangle extends MyButton {
  /// Creates a [MyButtonRectangle].
  ///
  /// [onTap] is called when the button is tapped.
  /// [child] is the widget displayed inside the button.
  /// [height] determines the height of the button (default is 44).
  /// [width] determines the width of the button (default is 200).
  /// [borderRadius] determines the corner radius of the button (default is 12).
  /// [padding] adds padding around the button (default is [EdgeInsets.all(0)]).
  const MyButtonRectangle({
    super.key,
    required super.onTap,
    required super.child,
    super.height = ConstLayout.buttonHeight,
    super.width = ConstLayout.buttonWidth,
    super.borderRadius = ConstLayout.radiusM,
    super.padding,
  });

  const MyButtonRectangle.action({
    super.key,
    required super.onTap,
    required super.child,
    double super.height = ConstLayout.buttonHeight,
    double super.width = ConstLayout.buttonWidth,
    double super.borderRadius = ConstLayout.radiusL,
    super.padding = EdgeInsets.zero,
  }) : super.action();
}
