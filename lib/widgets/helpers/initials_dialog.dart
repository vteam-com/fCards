// ignore_for_file: deprecated_member_use

import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/helpers/input_keyboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A dialog that collects up to two initials using an OTP-style two-slot input.
///
/// Returns the entered initials string via [Navigator.pop], or null if dismissed.
class InitialsDialog extends StatefulWidget {
  ///
  const InitialsDialog({required this.initialValue, super.key});

  /// Pre-filled value shown when the dialog opens.
  final String initialValue;

  @override
  State<InitialsDialog> createState() => _InitialsDialogState();
}

class _InitialsDialogState extends State<InitialsDialog> {
  int _activeSlot = 0;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  static const int _maxLength = 2;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _normalize(widget.initialValue));
    _controller.selection = const TextSelection.collapsed(offset: 0);
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setActiveSlot(0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AppLocalizations localizations = AppLocalizations.of(context);
    final bool disableSystemKeyboard =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    return AlertDialog(
      title: Text(localizations.playerName),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListenableBuilder(
              listenable: Listenable.merge([_controller, _focusNode]),
              builder: (_, _) {
                final value = _normalize(_controller.text);
                final first = value.isNotEmpty ? value[0] : '';
                final second = value.length >= _maxLength ? value[1] : '';
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSlot(
                      value: first,
                      isActive: _activeSlot == 0,
                      colorScheme: colorScheme,
                      onTap: () => _setActiveSlot(0),
                    ),
                    SizedBox(width: ConstLayout.sizeM),
                    _buildSlot(
                      value: second,
                      isActive: _activeSlot == 1,
                      colorScheme: colorScheme,
                      onTap: () => _setActiveSlot(1),
                    ),
                  ],
                );
              },
            ),
            SizedBox(
              width: ConstLayout.sizeXS,
              height: ConstLayout.sizeXS,
              child: Opacity(
                opacity: ConstLayout.sizeXS / ConstLayout.paddingM,
                child: Focus(
                  onKeyEvent: (_, KeyEvent event) {
                    if (event is! KeyDownEvent) return KeyEventResult.ignored;
                    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                      _setActiveSlot(0);
                      return KeyEventResult.handled;
                    }
                    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                      _setActiveSlot(1);
                      return KeyEventResult.handled;
                    }
                    if (event.logicalKey == LogicalKeyboardKey.backspace) {
                      _handleKey(keyBackspace);
                      return KeyEventResult.handled;
                    }
                    if (event.logicalKey == LogicalKeyboardKey.enter ||
                        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
                      _accept();
                      return KeyEventResult.handled;
                    }
                    final char = event.character;
                    if (char != null &&
                        RegExp(r'^[a-zA-Z0-9]$').hasMatch(char)) {
                      _handleKey(char);
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: TextField(
                    autofocus: true,
                    focusNode: _focusNode,
                    controller: _controller,
                    readOnly: disableSystemKeyboard,
                    showCursor: !disableSystemKeyboard,
                    enableInteractiveSelection: !disableSystemKeyboard,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: _maxLength,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                      LengthLimitingTextInputFormatter(_maxLength),
                    ],
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (value) {
                      final normalized = _normalize(value);
                      if (normalized != value) {
                        _controller.value = TextEditingValue(
                          text: normalized,
                          selection: TextSelection.collapsed(
                            offset: normalized.length,
                          ),
                        );
                      }
                      _autoAdvanceToSecondSlot();
                    },
                    onSubmitted: (_) => _accept(),
                  ),
                ),
              ),
            ),
            SizedBox(height: ConstLayout.sizeM),
            InputKeyboard.alpha(
              onKeyPressed: (String key) {
                if (!_focusNode.hasFocus) {
                  _focusNode.requestFocus();
                }
                _handleKey(key);
              },
            ),
            SizedBox(height: ConstLayout.sizeM),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: ConstLayout.startGameScreenMaxWidth,
              ),
              child: MyButtonRectangle(
                width: double.infinity,
                height: ConstLayout.mainMenuButtonHeight,
                onTap: _accept,
                child: Text(
                  localizations.done,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _accept() {
    Navigator.of(context).pop(_normalize(_controller.text));
  }

  /// Moves focus to slot 2 after the first character is entered.
  void _autoAdvanceToSecondSlot() {
    final value = _normalize(_controller.text);
    const secondSlot = _maxLength - 1;
    if (value.length == secondSlot &&
        _controller.selection.baseOffset != secondSlot) {
      _controller.selection = _selectionForSlot(value, secondSlot);
      if (_activeSlot != secondSlot) {
        setState(() => _activeSlot = secondSlot);
      }
    }
  }

  /// Builds one visual OTP-style slot.
  Widget _buildSlot({
    required String value,
    required bool isActive,
    required ColorScheme colorScheme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: ConstLayout.animationDuration300),
        width: ConstLayout.sizeXXL,
        height: ConstLayout.sizeXXL,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(
            ConstLayout.alphaH,
          ),
          borderRadius: BorderRadius.circular(ConstLayout.radiusM),
          border: Border.all(
            color: isActive ? colorScheme.primary : colorScheme.outline,
            width: isActive ? ConstLayout.strokeS : ConstLayout.strokeXS,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(ConstLayout.paddingS),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: ConstLayout.textL,
                height: ConstLayout.strokeXS,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Processes a virtual or physical key press and updates the controller.
  void _handleKey(String key) {
    final current = _normalize(_controller.text);
    final sel = _selectionForSlot(current, _activeSlot);
    final selStart = sel.baseOffset <= sel.extentOffset
        ? sel.baseOffset
        : sel.extentOffset;
    final selEnd = sel.baseOffset <= sel.extentOffset
        ? sel.extentOffset
        : sel.baseOffset;

    String next = current;
    int nextOffset = selStart;

    if (key == keyBackspace) {
      if (selStart != selEnd) {
        next = current.replaceRange(selStart, selEnd, '');
        nextOffset = selStart;
      } else if (selStart > 0) {
        next = current.replaceRange(selStart - 1, selStart, '');
        nextOffset = selStart - 1;
      }
    } else if (key != keySpace && key.length == 1) {
      final char = key.toUpperCase();
      final replaced = selStart == selEnd
          ? selStart < current.length
                ? current.replaceRange(selStart, selStart + 1, char)
                : current.replaceRange(selStart, selStart, char)
          : current.replaceRange(selStart, selEnd, char);
      next = _normalize(replaced);
      nextOffset = (selStart + 1).clamp(0, next.length);
    }

    if (next == current && nextOffset == sel.baseOffset) return;

    _controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: nextOffset),
    );
    final resolved = nextOffset <= 0 ? 0 : 1;
    if (_activeSlot != resolved) {
      setState(() => _activeSlot = resolved);
    }
    _autoAdvanceToSecondSlot();
  }

  String _normalize(String raw) {
    final cleaned = raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return cleaned.length > _maxLength
        ? cleaned.substring(0, _maxLength)
        : cleaned;
  }

  TextSelection _selectionForSlot(String value, int slot) {
    final clamped = slot.clamp(0, _maxLength - 1);
    final start = clamped > value.length ? value.length : clamped;
    final end = (start + 1) <= value.length ? start + 1 : start;
    return TextSelection(baseOffset: start, extentOffset: end);
  }

  void _setActiveSlot(int slot) {
    final value = _normalize(_controller.text);
    if (_activeSlot != slot) {
      setState(() => _activeSlot = slot);
    }
    _focusNode.requestFocus();
    _controller.selection = _selectionForSlot(value, slot);
  }
}
