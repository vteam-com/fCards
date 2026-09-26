import 'package:cards/widgets/player/player_edit_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows player identity and a labeled remove action', (
    WidgetTester tester,
  ) async {
    bool wasRemoved = false;
    bool initialsEditOpened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: PlayerEditTile(
              initials: 'JP',
              width: PlayerEditTile.maxWidth,
              editLabel: 'Edit initials',
              email: 'jp@example.com',
              removeTooltip: 'Remove',
              onEditInitials: () => initialsEditOpened = true,
              onRemove: () => wasRemoved = true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('JP'), findsOneWidget);
    expect(find.text('jp@example.com'), findsOneWidget);
    expect(find.byIcon(Icons.drag_indicator), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.text('Remove'), findsNothing);
    await tester.tap(find.byTooltip('Edit initials'));
    expect(initialsEditOpened, isTrue);
    await tester.tap(find.byTooltip('Remove'));
    expect(wasRemoved, isTrue);
  });
}
