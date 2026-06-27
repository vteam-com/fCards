import 'package:cards/widgets/helpers/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Screen.avatarFallbackText', () {
    test('returns trimmed display name when available', () {
      expect(
        Screen.avatarFallbackText(
          displayName: '  Jane Doe  ',
          email: 'player@example.com',
        ),
        'Jane Doe',
      );
    });

    test('falls back to trimmed email when display name is missing', () {
      expect(
        Screen.avatarFallbackText(
          displayName: null,
          email: '  player@example.com  ',
        ),
        'player@example.com',
      );
    });

    test('falls back to placeholder when display name and email are blank', () {
      expect(Screen.avatarFallbackText(displayName: '   ', email: '   '), '🤔');
    });
  });

  testWidgets('signOutToHome clears navigation back to root', (
    WidgetTester tester,
  ) async {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    late BuildContext gameContext;
    int signOutCalls = 0;
    int ensureSignedInCalls = 0;

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        initialRoute: '/game',
        routes: <String, WidgetBuilder>{
          '/': (BuildContext _) => const Scaffold(body: Text('home')),
          '/game': (BuildContext context) {
            gameContext = context;
            return const Scaffold(body: Text('game'));
          },
        },
      ),
    );

    expect(find.text('game'), findsOneWidget);
    expect(navigatorKey.currentState?.canPop(), isTrue);

    await Screen.signOutToHome(
      context: gameContext,
      signOut: () async {
        signOutCalls += 1;
      },
      ensureSignedIn: () async {
        ensureSignedInCalls += 1;
      },
    );
    await tester.pumpAndSettle();

    expect(signOutCalls, 1);
    expect(ensureSignedInCalls, 1);
    expect(find.text('home'), findsOneWidget);
    expect(find.text('game'), findsNothing);
    expect(navigatorKey.currentState?.canPop(), isFalse);
  });
}
