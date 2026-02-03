import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/helpers/my_button_round.dart';
import 'package:flutter/material.dart';

///
const String keyChangeSign = '±';

///
const String keyBackspace = '⌫';

///
class InputKeyboard extends StatelessWidget {
  ///
  const InputKeyboard({super.key, required this.onKeyPressed});

  ///
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
        padding: EdgeInsets.all(ConstLayout.sizeS),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildButton('1'),
                _buildButton('2'),
                _buildButton('3'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildButton('4'),
                _buildButton('5'),
                _buildButton('6'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildButton('7'),
                _buildButton('8'),
                _buildButton('9'),
              ],
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
        ),
      ),
    );
  }

  Widget _buildButton(String text) {
    return Padding(
      padding: const EdgeInsets.all(ConstLayout.sizeS),
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
}
