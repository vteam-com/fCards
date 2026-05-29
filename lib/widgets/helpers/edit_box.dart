import 'package:cards/models/app/app_theme.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/helpers/input_keyboard.dart';
import 'package:flutter/material.dart';

/// A reusable widget for creating a text input field.
///
/// This widget can include a label, a text field, and a trailing widget (e.g., an
/// icon button). It is used for both the room name and player name input fields.
/// When focused it shows the [InputKeyboard.alpha] virtual keyboard below.
class EditBox extends StatefulWidget {
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
  State<EditBox> createState() => _EditBoxState();
}

class _EditBoxState extends State<EditBox> {
late final FocusNode _focusNode;
bool _showKeyboard = false;
@override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _showKeyboard = _focusNode.hasFocus;
      });
    });
  }
@override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
@override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: ConstLayout.startGameScreenMaxWidth,
          padding: const EdgeInsets.all(ConstLayout.paddingM),
          decoration: BoxDecoration(
            color: AppTheme.panelInputZone,
            borderRadius: BorderRadius.circular(ConstLayout.radiusM),
          ),
          child: Row(
            spacing: ConstLayout.sizeM,
            children: [
              if (widget.label != null)
                Text(
                  widget.label!,
                  style: TextStyle(
                    fontSize: ConstLayout.textM,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              Expanded(
                child: TextField(
                  focusNode: _focusNode,
                  controller: widget.controller,
                  onEditingComplete: widget.onSubmitted,
                  onSubmitted: (_) {
                    widget.onSubmitted();
                  },
                  onChanged: (final String text) {
                    final String uppercaseText = text.toUpperCase();
                    widget.controller.value = widget.controller.value.copyWith(
                      text: uppercaseText,
                      selection: TextSelection.collapsed(
                        offset: uppercaseText.length,
                      ),
                      composing: TextRange.empty,
                    );
                    widget.onChanged?.call(text);
                  },
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: ConstLayout.textM,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: widget.prefixIcon,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              ?widget.rightSideChild,
            ],
          ),
        ),
        if (_showKeyboard) InputKeyboard.alpha(onKeyPressed: _handleVirtualKey),
      ],
    );
  }
/// Handles a key press from the virtual [InputKeyboard.alpha].
  ///
  /// Appends letters and spaces to the controller, or removes the last
  /// character when [keyBackspace] is pressed. Fires [EditBox.onChanged].
  void _handleVirtualKey(String key) {
    final String current = widget.controller.text;
    final String updated;
    if (key == keyBackspace) {
      updated = current.isEmpty
          ? current
          : current.substring(0, current.length - 1);
    } else {
      updated = current + key;
    }
    widget.controller.value = widget.controller.value.copyWith(
      text: updated,
      selection: TextSelection.collapsed(offset: updated.length),
      composing: TextRange.empty,
    );
    widget.onChanged?.call(updated);
  }
}
