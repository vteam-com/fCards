import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/buttons/my_button_rectangle.dart';
import 'package:cards/widgets/buttons/my_button_round.dart';
import 'package:flutter/material.dart';

/// Key label for the sign-toggle button on the numeric keyboard.
const String keyChangeSign = '±';

/// Key label for the backspace button.
const String keyBackspace = '⌫';

/// Key value emitted by the space button on the alpha keyboard.
const String keySpace = ' ';

/// Label displayed on the space bar button.
const String keySpaceLabel = 'SPACE';

/// Internal layout constants for [InputKeyboard].
class _InputKeyboardConstants {
  static const int codeA = 65; // Unicode / ASCII code point for 'A'
  static const int alphabetCount = 26;
  static const int alphaRow1End = 5;
  static const int alphaRow2End = 10;
  static const int alphaRow3End = 15;
  static const int alphaRow4End = 20;
  static const int alphaRow5End = 25;
}

/// The two input modes supported by [InputKeyboard].
enum InputKeyboardMode {
  /// Numeric keypad: digits 0–9, sign toggle, backspace.
  numeric,

  /// Alpha keypad: uppercase A–Z, space, backspace.
  alpha,
}

/// An on-screen virtual keyboard with two modes.
///
/// Use the default constructor for the numeric keypad (score entry).
/// Use [InputKeyboard.alpha] for text entry (names, table names).
class InputKeyboard extends StatelessWidget {
  /// Creates a numeric [InputKeyboard] (default mode).
  const InputKeyboard({super.key, required this.onKeyPressed})
    : mode = InputKeyboardMode.numeric;

  /// Creates an alpha [InputKeyboard] (A–Z, space, backspace).
  const InputKeyboard.alpha({super.key, required this.onKeyPressed})
    : mode = InputKeyboardMode.alpha;

  /// The keyboard mode (set by constructor).
  final InputKeyboardMode mode;

  /// Called with the label of the key that was pressed.
  final Function(String) onKeyPressed;
  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        margin: EdgeInsets.all(ConstLayout.sizeS),
        decoration: BoxDecoration(
          color: Colors.black26,
          border: Border.all(color: Colors.black26),
          borderRadius: const BorderRadius.all(
            Radius.circular(ConstLayout.radiusXL),
          ),
        ),
        padding: EdgeInsets.all(ConstLayout.paddingS),
        child: mode == InputKeyboardMode.alpha
            ? _buildAlphaLayout()
            : _buildNumericLayout(),
      ),
    );
  }

  /// Builds the alpha keyboard layout: rows A–Z, space bar, backspace.
  Widget _buildAlphaLayout() {
    // Generate A–Z from character codes to avoid hardcoded string literals.
    final letters = List<String>.generate(
      _InputKeyboardConstants.alphabetCount,
      (i) => String.fromCharCode(_InputKeyboardConstants.codeA + i),
    );
    return Column(
      children: [
        _buildRow(letters.sublist(0, _InputKeyboardConstants.alphaRow1End)),
        _buildRow(
          letters.sublist(
            _InputKeyboardConstants.alphaRow1End,
            _InputKeyboardConstants.alphaRow2End,
          ),
        ),
        _buildRow(
          letters.sublist(
            _InputKeyboardConstants.alphaRow2End,
            _InputKeyboardConstants.alphaRow3End,
          ),
        ),
        _buildRow(
          letters.sublist(
            _InputKeyboardConstants.alphaRow3End,
            _InputKeyboardConstants.alphaRow4End,
          ),
        ),
        _buildRow(
          letters.sublist(
            _InputKeyboardConstants.alphaRow4End,
            _InputKeyboardConstants.alphaRow5End,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(letters[_InputKeyboardConstants.alphaRow5End]),
            _buildSpaceButton(),
            _buildButton(keyBackspace),
          ],
        ),
      ],
    );
  }

  /// Builds a single round key button.
  Widget _buildButton(String text) {
    return Padding(
      padding: const EdgeInsets.all(ConstLayout.paddingS),
      child: MyButtonRound(
        size: ConstLayout.iconL,
        onTap: () => onKeyPressed(text),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: ConstLayout.textM),
        ),
      ),
    );
  }

  /// Builds the numeric keyboard layout: digits 1–9, sign toggle, 0, backspace.
  Widget _buildNumericLayout() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_buildButton('1'), _buildButton('2'), _buildButton('3')],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_buildButton('4'), _buildButton('5'), _buildButton('6')],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [_buildButton('7'), _buildButton('8'), _buildButton('9')],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildButton(keyChangeSign),
            _buildButton('0'),
            _buildButton(keyBackspace),
          ],
        ),
      ],
    );
  }

  /// Builds a row of round key buttons from a list of labels.
  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map(_buildButton).toList(),
    );
  }

  /// Builds the wide SPACE bar button for the alpha keyboard.
  Widget _buildSpaceButton() {
    return Padding(
      padding: const EdgeInsets.all(ConstLayout.paddingS),
      child: MyButtonRectangle(
        width: ConstLayout.iconXL,
        height: ConstLayout.iconL,
        onTap: () => onKeyPressed(keySpace),
        child: const Text(
          keySpaceLabel,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: ConstLayout.textS),
        ),
      ),
    );
  }
}
