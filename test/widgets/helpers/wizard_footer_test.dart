import 'package:cards/widgets/helpers/wizard_footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('back and next fit on a narrow screen', (
    WidgetTester tester,
  ) async {
    const double narrowWidth = 280;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: narrowWidth,
              child: WizardFooter(
                backLabel: 'Back',
                primaryLabel: 'Start a Score Sheet',
                isPrimaryEnabled: true,
                onBack: () {},
                onForward: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final Rect footer = tester.getRect(find.byType(WizardFooter));
    for (final String label in <String>['Back', 'Start a Score Sheet']) {
      final Rect rect = tester.getRect(find.text(label));
      expect(rect.left, greaterThanOrEqualTo(footer.left));
      expect(rect.right, lessThanOrEqualTo(footer.right));
    }
  });
}
