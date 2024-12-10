import 'package:cards/misc.dart';
import 'package:flutter/material.dart';

class DateTimeWidget extends StatelessWidget {
  const DateTimeWidget({super.key, required this.dateTime});
  final DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildText(dateTime.year, 14),
        const Text(' . '),
        _buildText(dateTime.month, 16),
        const Text(' . '),
        _buildText(dateTime.day, 18),
        SizedBox(width: 20),
        _buildText(dateTime.hour, 18),
        const Text(':'),
        _buildText(dateTime.minute, 18),
      ],
    );
  }

  Widget _buildText(final num value, double fontSize) {
    return TextSize(
      value.toString().padLeft(2, '0'),
      fontSize,
      bold: true,
    );
  }
}
