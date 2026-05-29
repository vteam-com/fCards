import 'package:cards/widgets/helpers/edit_box.dart';
import 'package:cards/widgets/helpers/input_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EditBox virtual keyboard', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    Widget buildSubject({Function(String)? onChanged}) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: EditBox(
              controller: controller,
              onSubmitted: () {},
              errorStatus: '',
              rightSideChild: null,
              onChanged: onChanged,
            ),
          ),
        ),
      );
    }

    testWidgets('hides virtual keyboard when not focused', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byType(InputKeyboard), findsNothing);
    });

    testWidgets('shows virtual keyboard when field is focused', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(find.byType(InputKeyboard), findsOneWidget);
    });

    testWidgets('appends letter to controller via virtual key', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.tap(find.text('A'));
      await tester.pump();

      expect(controller.text, 'A');
    });

    testWidgets('appends space via SPACE key', (WidgetTester tester) async {
      controller.text = 'JP';
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.tap(find.text(keySpaceLabel));
      await tester.pump();

      expect(controller.text, 'JP ');
    });

    testWidgets('removes last character via backspace key', (
      WidgetTester tester,
    ) async {
      controller.text = 'AB';
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.tap(find.text(keyBackspace));
      await tester.pump();

      expect(controller.text, 'A');
    });

    testWidgets('backspace on empty controller does nothing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.tap(find.text(keyBackspace));
      await tester.pump();

      expect(controller.text, '');
    });

    testWidgets('virtual key fires onChanged callback', (
      WidgetTester tester,
    ) async {
      final List<String> changes = [];
      await tester.pumpWidget(buildSubject(onChanged: changes.add));
      await tester.tap(find.byType(TextField));
      await tester.pump();

      await tester.tap(find.text('J'));
      await tester.pump();
      await tester.tap(find.text('P'));
      await tester.pump();

      expect(changes, ['J', 'JP']);
    });
  });
}
