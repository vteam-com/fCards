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
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        border: Border.all(
          color: Colors.black26,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(40),
        ),
      ),
      padding: EdgeInsets.all(10),
      width: 240,
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
    );
  }

  Widget _buildButton(String text) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          width: 40,
          height: 45,
          child: ElevatedButton(
            onPressed: () => onKeyPressed(text),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(
                Colors.black.withAlpha(60),
              ),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0),
                ),
              ),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }
}
