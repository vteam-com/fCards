import 'package:flutter/material.dart';

///
class InputKeyboard extends StatelessWidget {
  ///
  const InputKeyboard({super.key, required this.onKeyPressed});

  ///
  final Function(String) onKeyPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
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
              _buildButton('-'),
              _buildButton('0'),
              _buildButton('⇐'),
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
          width: 50,
          height: 60,
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
            child: Text(text, style: TextStyle(fontSize: 20)),
          ),
        ),
      ),
    );
  }
}
