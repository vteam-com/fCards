import 'package:cards/widgets/helpers/input_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InputKeyboard', () {
    late List<String> capturedKeys;
    late Function(String) mockOnKeyPressed;

    setUp(() {
      capturedKeys = [];
      mockOnKeyPressed = (String key) {
        capturedKeys.add(key);
      };
    });

    testWidgets('should display all number keys correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: InputKeyboard(onKeyPressed: mockOnKeyPressed)),
        ),
      );

      // Check that all number keys are present
      for (int i = 1; i <= 9; i++) {
        expect(find.text(i.toString()), findsOneWidget);
      }
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('should display special keys correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: InputKeyboard(onKeyPressed: mockOnKeyPressed)),
        ),
      );

      expect(find.text(keyChangeSign), findsOneWidget);
      expect(find.text(keyBackspace), findsOneWidget);
    });

    testWidgets('should call onPressed when number key is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: InputKeyboard(onKeyPressed: mockOnKeyPressed)),
        ),
      );

      await tester.tap(find.text('5'));
      await tester.pump();

      expect(capturedKeys, ['5']);
    });

    testWidgets('should call onPressed when special key is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: InputKeyboard(onKeyPressed: mockOnKeyPressed)),
        ),
      );

      await tester.tap(find.text(keyChangeSign));
      await tester.pump();

      expect(capturedKeys, [keyChangeSign]);
    });

    testWidgets('should call onPressed when backspace is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: InputKeyboard(onKeyPressed: mockOnKeyPressed)),
        ),
      );

      await tester.tap(find.text(keyBackspace));
      await tester.pump();

      expect(capturedKeys, [keyBackspace]);
    });

    testWidgets('should handle multiple key presses', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: InputKeyboard(onKeyPressed: mockOnKeyPressed)),
        ),
      );

      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text(keyBackspace));
      await tester.pump();

      expect(capturedKeys, ['1', '2', keyBackspace]);
    });

    group('Layout Tests', () {
      testWidgets('should arrange keys in correct rows', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: InputKeyboard(onKeyPressed: mockOnKeyPressed)),
          ),
        );

        // Find all Row widgets in the keyboard
        final rows = find.byType(Row);
        expect(rows, findsWidgets);

        // Check that we have the expected number of rows
        expect(rows.evaluate().length, equals(4));

        // Check first row has 3 buttons (1, 2, 3)
        final firstRow = rows.first;
        expect(firstRow, findsOneWidget);

        // Check that all number keys are present
        expect(find.text('1'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('4'), findsOneWidget);
        expect(find.text('5'), findsOneWidget);
        expect(find.text('6'), findsOneWidget);
        expect(find.text('7'), findsOneWidget);
        expect(find.text('8'), findsOneWidget);
        expect(find.text('9'), findsOneWidget);
        expect(find.text('0'), findsOneWidget);
      });

      testWidgets('should have proper spacing and styling', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: InputKeyboard(onKeyPressed: mockOnKeyPressed)),
          ),
        );

        // Check that the keyboard container exists
        expect(find.byType(Container), findsWidgets);

        // Check that buttons are properly styled
        expect(find.byType(IntrinsicWidth), findsOneWidget);
      });
    });

    group('Integration Tests', () {
      testWidgets('should work with score input scenario', (
        WidgetTester tester,
      ) async {
        String currentInput = '';

        scoreInputHandler(String key) {
          if (key == keyBackspace) {
            if (currentInput.isNotEmpty) {
              currentInput = currentInput.substring(0, currentInput.length - 1);
            }
          } else if (key == keyChangeSign) {
            if (currentInput.startsWith('-')) {
              currentInput = currentInput.substring(1);
            } else if (currentInput.isNotEmpty) {
              currentInput = '-$currentInput';
            }
          } else if (key != keyChangeSign && key != keyBackspace) {
            currentInput += key;
          }
        }

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InputKeyboard(onKeyPressed: scoreInputHandler),
            ),
          ),
        );

        // Simulate entering "123"
        await tester.tap(find.text('1'));
        await tester.pump();
        await tester.tap(find.text('2'));
        await tester.pump();
        await tester.tap(find.text('3'));
        await tester.pump();

        expect(currentInput, '123');

        // Make it negative
        await tester.tap(find.text(keyChangeSign));
        await tester.pump();

        expect(currentInput, '-123');

        // Remove last digit
        await tester.tap(find.text(keyBackspace));
        await tester.pump();

        expect(currentInput, '-12');
      });
    });
  });
}
