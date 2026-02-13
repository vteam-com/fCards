import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/helpers/my_text.dart';
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

  /// Builds a zero-padded numeric segment for the date/time display.
  Widget _buildText(final num value, double fontSize) {
    return MyText(
      value.toString().padLeft(ConstLayout.dateCharacterLeftSpacePadding, '0'),
      fontSize: fontSize,
      bold: true,
    );
  }
}
