import 'package:flutter/material.dart';

/// Displays a custom dialog with a title, content, and optional buttons.
///
/// This function creates an [AlertDialog] with the provided [title], [content], and
/// [buttons]. If no [buttons] are provided, a default "Ok" button is added that
/// dismisses the dialog.
///
/// The [context] parameter is required and is used to display the dialog.
///
/// Example usage:
///
/// myDialog(
///   context: context,
///   title: 'My Dialog',
///   content: Text('This is the content of the dialog.'),
///   buttons: [
///     ElevatedButton(
///       onPressed: () {
///         // Handle button press
///       },
///       child: Text('Cancel'),
///     ),
///     ElevatedButton(
///       onPressed: () {
///         // Handle button press
///       },
///       child: Text('OK'),
///     ),
///   ],
/// );
///
void myDialog({
  required final BuildContext context,
  required final String title,
  required final Widget content,
  List<Widget> buttons = const [],
}) {
  if (buttons.isEmpty) {
    buttons = [
      ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text('Ok'),
      ),
    ];
  }
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: TextStyle(fontSize: 30),
          textAlign: TextAlign.center,
        ),
        content: content,
        actions: buttons,
      );
    },
  );
}
