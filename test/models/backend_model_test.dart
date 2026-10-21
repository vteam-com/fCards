import 'dart:async';

import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/app/firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockDataSnapshot extends Mock implements DataSnapshot {}

class MockDatabaseReference extends Mock implements DatabaseReference {}

class MockQuery extends Mock implements Query {}

class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}

class MockDataSnapshotImpl implements DataSnapshot {
  @override
  dynamic get value => ['JOHN', 'PAUL', 'GORGES', 'RINGO'];
  @override
  String get key => 'mockKey';

  @override
  bool hasChild(String path) => true;

  @override
  DataSnapshot child(String path) => MockDataSnapshotImpl();

  @override
  List<DataSnapshot> get children => [this];

  @override
  dynamic get priority => null;

  @override
  DatabaseReference get ref => MockDatabaseReference();

  @override
  bool get exists => true;
}

void main() {
  group('BackEndModel', () {
    test('mock backend', () {
      DefaultFirebaseOptions.currentPlatform;
      DefaultFirebaseOptions.web;
      DefaultFirebaseOptions.ios;
      DefaultFirebaseOptions.macos;
      DefaultFirebaseOptions.windows;
    });
  });

  group('useFirebase', () {
    test('should set backendReady to true when offline', () async {
      isRunningOffLine = true;
      await useFirebase();
      expect(backendReady, true);
    });

    test('should initialize Firebase when online and not ready', () async {
      isRunningOffLine = false;
      backendReady = false;
      await useFirebase();
      // this wont run in unit test, so we expected to not be ready
      expect(backendReady, false);
    });

    test('should skip initialization when already ready', () async {
      isRunningOffLine = false;
      backendReady = true;
      await useFirebase();
      expect(backendReady, true);
    });

    test('should set local persistence when offline', () async {
      isRunningOffLine = true;
      backendReady = false;
      await useFirebase();
      expect(backendReady, true);
    });
  });

  group('withFirebaseRequestTimeout', () {
    late DateTime now;
    late BackendHealth health;

    setUp(() {
      now = DateTime(2026, 10, 21, 9);
      health = BackendHealth(now: () => now);
    });

    test('completes with a timeout when the request does not finish', () async {
      final Completer<void> request = Completer<void>();
      await expectLater(
        withFirebaseRequestTimeout(
          () => request.future,
          timeout: const Duration(milliseconds: 1),
          health: health,
        ),
        throwsA(isA<TimeoutException>()),
      );
      expect(health.isUnreachable, isTrue);
    });

    test(
      'fails fast without sending while the backend is unreachable',
      () async {
        health.recordFailure();
        bool sent = false;
        await expectLater(
          withFirebaseRequestTimeout(() async {
            sent = true;
          }, health: health),
          throwsA(isA<BackendUnavailableException>()),
        );
        expect(sent, isFalse);
      },
    );

    test('sends one probe after the retry delay and recovers', () async {
      health.recordFailure();
      now = now.add(backendRetryAfter);
      expect(
        await withFirebaseRequestTimeout(() async => 'pong', health: health),
        'pong',
      );
      expect(health.status, BackendStatus.reachable);
    });

    test('an error from the backend still counts as reachable', () async {
      await expectLater(
        withFirebaseRequestTimeout(
          () => Future<void>.error(StateError('permission denied')),
          health: health,
        ),
        throwsA(isA<StateError>()),
      );
      expect(health.status, BackendStatus.reachable);
    });
  });

  group('withFirebaseStreamTimeout', () {
    late DateTime now;
    late BackendHealth health;

    setUp(() {
      now = DateTime(2026, 10, 21, 9);
      health = BackendHealth(now: () => now);
    });

    test('fails when the first event does not arrive in time', () async {
      final StreamController<int> source = StreamController<int>();
      addTearDown(source.close);
      await expectLater(
        withFirebaseStreamTimeout(
          () => source.stream,
          timeout: const Duration(milliseconds: 1),
          health: health,
        ).first,
        throwsA(isA<TimeoutException>()),
      );
      expect(health.isUnreachable, isTrue);
      expect(source.hasListener, isFalse);
    });

    test('passes events through once the first one arrived', () async {
      final StreamController<int> source = StreamController<int>();
      addTearDown(source.close);
      final Future<List<int>> events = withFirebaseStreamTimeout(
        () => source.stream,
        timeout: const Duration(milliseconds: 1),
        health: health,
      ).take(2).toList();
      source.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      source.add(2);
      expect(await events, <int>[1, 2]);
      expect(health.status, BackendStatus.reachable);
    });

    test('fails fast without subscribing while unreachable', () async {
      health.recordFailure();
      bool subscribed = false;
      await expectLater(
        withFirebaseStreamTimeout(() {
          subscribed = true;
          return const Stream<int>.empty();
        }, health: health).first,
        throwsA(isA<BackendUnavailableException>()),
      );
      expect(subscribed, isFalse);
    });
  });

  group('test offline', () {
    test('getInviteesFromDataSnapshot', () async {
      isRunningOffLine = false;
      final players = getInviteesFromDataSnapshot(MockDataSnapshotImpl());
      expect(players, ['JOHN', 'PAUL', 'GORGES', 'RINGO']);
    });

    test('getPlayersInRoom', () async {
      isRunningOffLine = true;
      final players = await getPlayersInRoom('TEST_ROOM');
      expect(players, ['BOB', 'SUE', 'JOHN', 'MARY']);

      // this does nothing in offline mode, but we still want to test that the function exist
      setPlayersInRoom('TEST_ROOM', {'BOB', 'SUE', 'JOHN', 'MARY'});
    });
  });
}
