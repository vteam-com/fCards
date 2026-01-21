import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cards/utils/scale_helper.dart';

/// Logs a debug message if the app is running in debug mode.
///
/// The [text] parameter specifies the message to be logged.
void debugLog(final String text) {
  if (kDebugMode) {
    print(text);
  }
}

///
/// This widget is used to display a text with custom font size, color, alignment and weight.
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
/// ```
/// TextSize(
///   "Hello, world!",
///   20,
///   color: Colors.blue,
///   align: TextAlign.center,
///   bold: true
/// )
/// ```
// ignore: non_constant_identifier_names
Widget TextSize(
  final String text,
  final num fontSize, {
  final Color? color,
  final TextAlign? align,
  final bool bold = false,
}) {
  return Text(
    text,
    textAlign: align,
    style: ScaleHelper.getScaledTextStyle(
      fontSize: fontSize.toDouble(),
      color: color,
      fontWeight: bold ? FontWeight.bold : null,
      decoration: TextDecoration.none,
    ),
  );
}
