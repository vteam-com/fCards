import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
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
      MyButtonRectangle(
        width: 100, // Reasonable width for a dialog button
        height: 44,
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Text(
          'Ok',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    ];
  }
  showDialog(
    context: context,
    builder: (BuildContext _) {
      return AlertDialog(
        title: Text(
          title,
          style: TextStyle(fontSize: ConstLayout.textXL),
          textAlign: TextAlign.center,
        ),
        content: content,
        actions: buttons,
      );
    },
  );
}
