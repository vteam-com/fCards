import 'package:cards/models/app/constants_layout.dart';
import 'package:flutter/material.dart';

/// A widget for displaying text with custom font size, color, alignment, and weight.
///
/// This widget provides a convenient way to display text with consistent styling
/// across your application. It wraps Flutter's Text widget with simplified parameters.
///
/// The [text] parameter specifies the text to be displayed.
///
/// The [fontSize] parameter specifies the font size of the text.
/// Use only [ConstLayout.textS], [ConstLayout.textM], or [ConstLayout.textL].
///
/// The [color] parameter specifies the color of the text.
///
/// The [align] parameter specifies the alignment of the text.
///
/// The [bold] parameter specifies whether the text should be bold or not.
///
/// Example:
/// ```dart
/// MyText(
///   "Hello, world!",
///   fontSize: ConstLayout.textM,
///   color: Colors.blue,
///   align: TextAlign.center,
///   bold: true
/// )
/// ```
class MyText extends StatelessWidget {
  /// Creates a MyText widget.
  const MyText(
    this.text, {
    super.key,
    required this.fontSize,
    this.color,
    this.align,
    this.bold = false,
  }) : assert(
         fontSize == ConstLayout.textS ||
             fontSize == ConstLayout.textM ||
             fontSize == ConstLayout.textL,
       );

  /// The alignment of the text.
  final TextAlign? align;

  /// Whether the text should be bold.
  final bool bold;

  /// The color of the text.
  final Color? color;

  /// The font size of the text.
  final double fontSize;

  /// The text to be displayed.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, textAlign: align, style: _buildTextStyle());
  }

  /// Returns a text style that resolves to one of the three app font sizes.
  TextStyle _buildTextStyle() {
    if (fontSize == ConstLayout.textL) {
      return TextStyle(
        fontSize: ConstLayout.textL,
        color: color,
        fontWeight: bold ? FontWeight.bold : null,
        decoration: TextDecoration.none,
      );
    }
    if (fontSize == ConstLayout.textM) {
      return TextStyle(
        fontSize: ConstLayout.textM,
        color: color,
        fontWeight: bold ? FontWeight.bold : null,
        decoration: TextDecoration.none,
      );
    }

    return TextStyle(
      fontSize: ConstLayout.textS,
      color: color,
      fontWeight: bold ? FontWeight.bold : null,
      decoration: TextDecoration.none,
    );
  }
}
