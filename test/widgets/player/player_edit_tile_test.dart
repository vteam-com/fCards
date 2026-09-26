import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/widgets/helpers/app_bottom_sheet.dart';
import 'package:cards/widgets/helpers/initials_dialog.dart';
import 'package:cards/widgets/player/player_edit_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows player identity and an icon-only remove action', (
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
    final Finder removeButtonFinder = find.ancestor(
      of: find.byIcon(Icons.close),
      matching: find.byType(IconButton),
    );
    final IconButton removeButton = tester.widget<IconButton>(
      removeButtonFinder,
    );
    expect(
      removeButton.color,
      Theme.of(tester.element(find.byType(Scaffold))).colorScheme.error,
    );
    await tester.tap(find.byTooltip('Edit initials'));
    expect(initialsEditOpened, isTrue);
    await tester.tap(find.byTooltip('Remove'));
    expect(wasRemoved, isTrue);
  });

  testWidgets('initials edit uses the A-to-Z initials dialog', (
    WidgetTester tester,
  ) async {
    String? editedInitials;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (BuildContext context) => Scaffold(
            body: Center(
              child: PlayerEditTile(
                initials: 'JP',
                width: PlayerEditTile.maxWidth,
                editLabel: 'Edit initials',
                removeTooltip: 'Remove',
                onEditInitials: () async {
                  editedInitials = await showAppBottomSheet<String>(
                    context: context,
                    builder: (_) => const InitialsDialog(initialValue: 'JP'),
                  );
                },
                onRemove: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Edit initials'));
    await tester.pumpAndSettle();
    expect(find.text('Player'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('B'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Done'));
    await tester.pumpAndSettle();

    expect(editedInitials, 'AB');
  });
}
