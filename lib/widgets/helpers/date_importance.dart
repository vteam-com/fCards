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
        _buildSmallText(dateTime.year),
        const Text(' . '),
        _buildSmallText(dateTime.month),
        const Text(' . '),
        _buildMediumText(dateTime.day),
        SizedBox(width: ConstLayout.sizeM),
        _buildMediumText(dateTime.hour),
        const Text(':'),
        _buildMediumText(dateTime.minute),
      ],
    );
  }

  /// Builds a zero-padded medium numeric segment for the date/time display.
  Widget _buildMediumText(final num value) {
    return MyText(
      value.toString().padLeft(ConstLayout.dateCharacterLeftSpacePadding, '0'),
      fontSize: ConstLayout.textM,
      bold: true,
    );
  }

  /// Builds a zero-padded small numeric segment for the date display.
  Widget _buildSmallText(final num value) {
    return MyText(
      value.toString().padLeft(ConstLayout.dateCharacterLeftSpacePadding, '0'),
      fontSize: ConstLayout.textS,
      bold: true,
    );
  }
}
