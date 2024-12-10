import 'package:flutter/material.dart';

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
