// ignore_for_file: deprecated_member_use

import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/buttons/my_button.dart';

/// A custom circular glass-like button with blur and ripple effects.
///
/// This widget displays a circular button with a glassmorphic (frosted glass) appearance,
/// including a blurred background, border, gradient, and ripple effect on tap.
/// The child widget is centered inside the button.
class MyButtonRound extends MyButton {
  /// Creates a [MyButtonRound].
  ///
  /// [onTap] is called when the button is tapped.
  /// [child] is the widget displayed inside the button.
  /// [size] determines the diameter of the button (default is 44).
  /// [padding] adds padding around the button (default is [EdgeInsets.all(0)]).
  const MyButtonRound({
    super.key,
    required super.onTap,
    required super.child,
    double size = ConstLayout.buttonHeight,
    super.padding,
  }) : super(width: size, height: size, isRound: true);
}
