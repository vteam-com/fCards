// ignore_for_file: deprecated_member_use
// ignore: fcheck_magic_numbers
import 'package:cards/widgets/buttons/my_button.dart';

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
    super.height = 44,
    super.width = 200,
    super.borderRadius = 13,
    super.padding,
  });
}
