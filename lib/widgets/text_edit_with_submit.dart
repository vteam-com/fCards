import 'package:cards/misc.dart';
import 'package:flutter/material.dart';

/// A widget that combines a [TextField] and an [ElevatedButton] to provide a
/// text input field with a submit button.
///
/// This widget is useful for creating forms or other user input scenarios where
/// the user needs to enter some text and submit it.
class TextFieldWithButton extends StatelessWidget {
  /// Constructs a [TextFieldWithButton] widget.
  ///
  /// The [super.key] parameter is passed to the [StatelessWidget] constructor.
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
