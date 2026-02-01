import 'package:cards/models/app/constants.dart';
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
        _buildText(dateTime.year, Constants.textS),
        const Text(' . '),
        _buildText(dateTime.month, Constants.textS),
        const Text(' . '),
        _buildText(dateTime.day, Constants.textM),
        SizedBox(width: Constants.sizeM),
        _buildText(dateTime.hour, Constants.textM),
        const Text(':'),
        _buildText(dateTime.minute, Constants.textM),
      ],
    );
  }

  Widget _buildText(final num value, double fontSize) {
    return TextSize(
      value.toString().padLeft(Constants.datePaddingLength, '0'),
      fontSize,
      bold: true,
    );
  }
}
