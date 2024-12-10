import 'package:flutter/material.dart';

class DateTimeWidget extends StatelessWidget {
  const DateTimeWidget({super.key, required this.dateTime});
  final DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildText(dateTime.year.toString(), fontSize: 12),
        const Text(' . '),
        _buildText(dateTime.month.toString().padLeft(2, '0'), fontSize: 14),
        const Text(' . '),
        _buildText(dateTime.day.toString().padLeft(2, '0'), fontSize: 16),
        SizedBox(
          width: 20,
        ),
        _buildText(dateTime.hour.toString().padLeft(2, '0'), fontSize: 18),
        const Text(':'),
        _buildText(dateTime.minute.toString().padLeft(2, '0'), fontSize: 18),
      ],
    );
  }

  Widget _buildText(String text, {required double fontSize}) {
    return Text(
      text,
      style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
    );
  }
}
