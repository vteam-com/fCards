import 'package:cards/models/app/app_theme.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:flutter/material.dart';

/// A reusable widget for creating a text input field.
///
/// This widget can include a label, a text field, and a trailing widget (e.g., an
/// icon button). It is used for both the room name and player name input fields.
class EditBox extends StatelessWidget {
  /// Creates an [EditBox] widget.
  ///
  /// [label] is the text to display as the label for the input field (optional).
  /// [controller] is the text editing controller for the text field.
  /// [onSubmitted] is the callback function to execute when the text field is submitted.
  /// [errorStatus] is the error text to display (currently unused).
  /// [rightSideChild] is the widget to display on the right side of the input field.
  /// [prefixIcon] is an optional icon to display at the beginning of the text field.
  /// [onChanged] is an optional callback function called when the text changes.
  const EditBox({
    super.key,
    this.label,
    required this.controller,
    required this.onSubmitted,
    required this.errorStatus,
    required this.rightSideChild,
    this.prefixIcon,
    this.onChanged,
  });

  /// The text editing controller for the text field.
  final TextEditingController controller;

  /// The error text to display (currently unused).
  final String errorStatus;

  /// The text to display as the label for the input field.
  final String? label;

  /// Optional callback function called when the text changes.
  final Function(String)? onChanged;

  /// The callback function to execute when the text field is submitted.
  final Function() onSubmitted;

  /// An optional icon to display at the beginning of the text field.
  final Widget? prefixIcon;

  /// The widget to display on the right side of the input field.
  final Widget? rightSideChild;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ConstLayout.startGameScreenMaxWidth,
      padding: const EdgeInsets.all(ConstLayout.sizeM),
      decoration: BoxDecoration(
        color: AppTheme.panelInputZone,
        borderRadius: BorderRadius.circular(ConstLayout.radiusM),
      ),
      child: Row(
        spacing: ConstLayout.sizeM,
        children: [
          if (label != null)
            Text(
              label!,
              style: TextStyle(
                fontSize: ConstLayout.textM,
                fontWeight: FontWeight.bold,
              ),
            ),

          Expanded(
            child: TextField(
              controller: controller,
              onEditingComplete: onSubmitted,
              onSubmitted: (_) {
                onSubmitted();
              },
              onChanged: (final String text) {
                final String uppercaseText = text.toUpperCase();
                controller.value = controller.value.copyWith(
                  text: uppercaseText,
                  selection: TextSelection.collapsed(
                    offset: uppercaseText.length,
                  ),
                  composing: TextRange.empty,
                );
                onChanged?.call(text);
              },
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 21.0, // ConstLayout.textL
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                prefixIcon: prefixIcon,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          ?rightSideChild,
        ],
      ),
    );
  }
}
