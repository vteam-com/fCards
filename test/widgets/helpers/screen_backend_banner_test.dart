import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/game/backend_model.dart';
import 'package:cards/widgets/helpers/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Key _banner = Key('screen.backendBanner');
const Key _retry = Key('screen.backendRetry');

Widget _app({VoidCallback? onRefresh}) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Screen(
    title: 'Test',
    isWaiting: false,
    onRefresh: onRefresh,
    child: const Text('content'),
  ),
);

void main() {
  setUp(() {
    isRunningOffLine = false;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    BackendHealth.instance.reset();
  });

  tearDown(() => BackendHealth.instance.reset());

  testWidgets('shows the banner only while the backend is unreachable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app());
    await tester.pump();
    expect(find.byKey(_banner), findsNothing);
    expect(find.text('content'), findsOneWidget);

    BackendHealth.instance.recordFailure();
    await tester.pump();
    expect(find.byKey(_banner), findsOneWidget);
    expect(find.text('content'), findsOneWidget);

    BackendHealth.instance.recordSuccess();
    await tester.pump();
    expect(find.byKey(_banner), findsNothing);
  });

  testWidgets('retry lets requests through again and refreshes the screen', (
    WidgetTester tester,
  ) async {
    int refreshes = 0;
    await tester.pumpWidget(_app(onRefresh: () => refreshes++));
    await tester.pump();

    BackendHealth.instance.recordFailure();
    await tester.pump();
    expect(BackendHealth.instance.beginAttempt(), isFalse);

    await tester.tap(find.byKey(_retry));
    await tester.pump();

    expect(refreshes, 1);
    expect(BackendHealth.instance.status, BackendStatus.unknown);
    expect(BackendHealth.instance.beginAttempt(), isTrue);
    expect(find.byKey(_banner), findsNothing);
  });

  testWidgets('never shows the banner in offline mode', (
    WidgetTester tester,
  ) async {
    isRunningOffLine = true;
    addTearDown(() => isRunningOffLine = false);
    await tester.pumpWidget(_app());
    await tester.pump();

    BackendHealth.instance.recordFailure();
    await tester.pump();
    expect(find.byKey(_banner), findsNothing);
  });
}
