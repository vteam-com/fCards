import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/helpers/input_keyboard.dart';
import 'package:cards/widgets/player/player_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerHeader initials input spec', () {
    Widget buildSubject({
      required String playerName,
      required ValueChanged<String> onNameChanged,
    }) {
      return MaterialApp(
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: PlayerHeader(
              playerName: playerName,
              rank: 1,
              numberOfPlayers: 2,
              totalScore: 0,
              onNameChanged: onNameChanged,
              onPlayerRemoved: () {},
              onPlayerAdded: () {},
            ),
          ),
        ),
      );
    }

    Future<void> openEditDialog(WidgetTester tester) async {
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
    }

    bool isSlotActive(WidgetTester tester, Key slotKey) {
      final AnimatedContainer slot = tester.widget<AnimatedContainer>(
        find.byKey(slotKey),
      );
      final BoxDecoration decoration = slot.decoration! as BoxDecoration;
      final Border border = decoration.border! as Border;
      return border.top.width == ConstLayout.strokeS;
    }

    String readSlotValue(WidgetTester tester, Key slotKey) {
      final Finder textFinder = find.descendant(
        of: find.byKey(slotKey),
        matching: find.byType(Text),
      );
      final Text text = tester.widget<Text>(textFinder.first);
      return text.data ?? '';
    }

    testWidgets('shows localized Player Initials label', (
      WidgetTester tester,
    ) async {
      String latestName = '';
      await tester.pumpWidget(
        buildSubject(playerName: 'JP', onNameChanged: (v) => latestName = v),
      );

      await openEditDialog(tester);

      expect(find.text('Player Initials'), findsOneWidget);
      expect(latestName, '');
    });

    testWidgets('slot 1 is active by default on dialog open', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(playerName: '', onNameChanged: (_) {}),
      );

      await openEditDialog(tester);

      expect(isSlotActive(tester, PlayerHeaderConstants.pinSlotOneKey), isTrue);
      expect(
        isSlotActive(tester, PlayerHeaderConstants.pinSlotTwoKey),
        isFalse,
      );
    });

    testWidgets('tapping slot 2 activates slot 2', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildSubject(playerName: 'A', onNameChanged: (_) {}),
      );

      await openEditDialog(tester);
      await tester.tap(find.byKey(PlayerHeaderConstants.pinSlotTwoKey));
      await tester.pump();
      await tester.tap(find.text('Z'));
      await tester.pumpAndSettle();

      expect(readSlotValue(tester, PlayerHeaderConstants.pinSlotOneKey), 'A');
      expect(readSlotValue(tester, PlayerHeaderConstants.pinSlotTwoKey), 'Z');
    });

    testWidgets('auto-advances to slot 2 after first character', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(playerName: '', onNameChanged: (_) {}),
      );

      await openEditDialog(tester);
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      expect(readSlotValue(tester, PlayerHeaderConstants.pinSlotOneKey), 'A');
      expect(isSlotActive(tester, PlayerHeaderConstants.pinSlotTwoKey), isTrue);
    });

    testWidgets('virtual keyboard is visible in dialog', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(playerName: '', onNameChanged: (_) {}),
      );

      await openEditDialog(tester);

      expect(find.byType(InputKeyboard), findsOneWidget);
    });

    testWidgets('second typed character is placed in slot 2', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(playerName: '', onNameChanged: (_) {}),
      );

      await openEditDialog(tester);
      await tester.tap(find.text('A'));
      await tester.pump();
      await tester.tap(find.text('B'));
      await tester.pumpAndSettle();

      expect(readSlotValue(tester, PlayerHeaderConstants.pinSlotOneKey), 'A');
      expect(readSlotValue(tester, PlayerHeaderConstants.pinSlotTwoKey), 'B');
    });

    testWidgets('typing overwrites active slot and does not push right', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(playerName: 'AB', onNameChanged: (_) {}),
      );

      await openEditDialog(tester);
      await tester.tap(find.byKey(PlayerHeaderConstants.pinSlotOneKey));
      await tester.pumpAndSettle();
      await tester.tap(find.text('C'));
      await tester.pumpAndSettle();

      expect(readSlotValue(tester, PlayerHeaderConstants.pinSlotOneKey), 'C');
      expect(readSlotValue(tester, PlayerHeaderConstants.pinSlotTwoKey), 'B');
    });

    testWidgets('physical keyboard follows same overwrite rules', (
      WidgetTester tester,
    ) async {
      String latestName = '';
      await tester.pumpWidget(
        buildSubject(playerName: '', onNameChanged: (v) => latestName = v),
      );

      await openEditDialog(tester);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyA);
      await tester.pump();

      expect(readSlotValue(tester, PlayerHeaderConstants.pinSlotOneKey), 'A');
      expect(isSlotActive(tester, PlayerHeaderConstants.pinSlotTwoKey), isTrue);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyB);
      await tester.pumpAndSettle();

      expect(readSlotValue(tester, PlayerHeaderConstants.pinSlotOneKey), 'A');
      expect(readSlotValue(tester, PlayerHeaderConstants.pinSlotTwoKey), 'B');
      expect(latestName, 'AB');

      await tester.tap(find.byKey(PlayerHeaderConstants.pinSlotOneKey));
      await tester.pumpAndSettle();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyC);
      await tester.pumpAndSettle();

      expect(readSlotValue(tester, PlayerHeaderConstants.pinSlotOneKey), 'C');
      expect(readSlotValue(tester, PlayerHeaderConstants.pinSlotTwoKey), 'B');
      expect(latestName, 'CB');
    });

    testWidgets('left and right arrows change active slot', (
      WidgetTester tester,
    ) async {
      String latestName = '';
      await tester.pumpWidget(
        buildSubject(playerName: 'AB', onNameChanged: (v) => latestName = v),
      );

      await openEditDialog(tester);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(isSlotActive(tester, PlayerHeaderConstants.pinSlotTwoKey), isTrue);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyC);
      await tester.pumpAndSettle();
      expect(readSlotValue(tester, PlayerHeaderConstants.pinSlotOneKey), 'A');
      expect(readSlotValue(tester, PlayerHeaderConstants.pinSlotTwoKey), 'C');

      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(isSlotActive(tester, PlayerHeaderConstants.pinSlotOneKey), isTrue);

      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyD);
      await tester.pumpAndSettle();
      expect(readSlotValue(tester, PlayerHeaderConstants.pinSlotOneKey), 'D');
      expect(readSlotValue(tester, PlayerHeaderConstants.pinSlotTwoKey), 'C');
      expect(latestName, 'DC');
    });

    testWidgets('ENTER submits like Done and closes dialog', (
      WidgetTester tester,
    ) async {
      String latestName = '';
      await tester.pumpWidget(
        buildSubject(playerName: '', onNameChanged: (v) => latestName = v),
      );

      await openEditDialog(tester);
      await tester.tap(find.text('J'));
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(latestName, 'J');
    });

    testWidgets('dialog keeps max width and action button width caps', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(playerName: '', onNameChanged: (_) {}),
      );

      await openEditDialog(tester);

      final AlertDialog dialog = tester.widget<AlertDialog>(
        find.byType(AlertDialog),
      );
      expect(
        dialog.constraints?.maxWidth,
        PlayerHeaderConstants.editDialogMaxWidth,
      );

      final Iterable<ConstrainedBox> constrained = tester
          .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
          .where(
            (ConstrainedBox c) =>
                c.constraints.maxWidth ==
                PlayerHeaderConstants.textActionButtonMaxWidth,
          );
      expect(constrained.length >= 2, isTrue);
    });
  });
}
