import 'package:flutter/material.dart';

/// A widget for displaying text with custom font size, color, alignment, and weight.
///
/// This widget provides a convenient way to display text with consistent styling
/// across your application. It wraps Flutter's Text widget with simplified parameters.
///
/// The [text] parameter specifies the text to be displayed.
///
/// The [fontSize] parameter specifies the font size of the text. It can be an integer or a double.
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
///   fontSize: 20,
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
  });

  /// The alignment of the text.
  final TextAlign? align;

  /// Whether the text should be bold.
  final bool bold;

  /// The color of the text.
  final Color? color;

  /// The font size of the text.
  final num fontSize;

  /// The text to be displayed.
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(
        fontSize: fontSize.toDouble(),
        color: color,
        fontWeight: bold ? FontWeight.bold : null,
        decoration: TextDecoration.none,
      ),
    );
  }
}
