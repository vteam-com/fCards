import 'package:cards/misc.dart';
import 'package:flutter/material.dart';

class TextFieldWithButton extends StatelessWidget {
  TextFieldWithButton({super.key});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: 'Enter your text here',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            // Handle submit action here
            final text = _controller.text;
            debugLog('Submitted text: $text');
            // Clear the TextField after submission
            _controller.clear();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

void main() => runApp(MaterialApp(home: TextFieldWithButton()));
