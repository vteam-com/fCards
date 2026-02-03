import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/helpers/misc.dart';
import 'package:flutter/material.dart';

/// A widget that displays a formatted date and time
///
/// Takes a [DateTime] object and displays it in the format:
/// YYYY . MM . DD   HH:MM
///
/// Example:  final DateTime dateTime;
class DateTimeWidget extends StatelessWidget {
  ///
  const DateTimeWidget({super.key, required this.dateTime});

  ///
  final DateTime dateTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildText(dateTime.year, ConstLayout.textS),
        const Text(' . '),
        _buildText(dateTime.month, ConstLayout.textS),
        const Text(' . '),
        _buildText(dateTime.day, ConstLayout.textM),
        SizedBox(width: ConstLayout.sizeM),
        _buildText(dateTime.hour, ConstLayout.textM),
        const Text(':'),
        _buildText(dateTime.minute, ConstLayout.textM),
      ],
    );
  }

  Widget _buildText(final num value, double fontSize) {
    return TextSize(
      value.toString().padLeft(ConstLayout.datePaddingLength, '0'),
      fontSize,
      bold: true,
    );
  }
}
