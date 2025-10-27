import 'package:cards/models/backend_model.dart';
import 'package:cards/models/firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'backend_json_data.dart';

class MockDataSnapshot extends Mock implements DataSnapshot {}

class MockDatabaseReference extends Mock implements DatabaseReference {}

class MockQuery extends Mock implements Query {}

class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}

class MockDataSnapshotImpl implements DataSnapshot {
  @override
  dynamic get value => backEndRoomInstance();
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

  group('test offline', () {
    test('getInviteesFromDataSnapshot', () async {
      isRunningOffLine = false;
      final players = getInviteesFromDataSnapshot(
        MockDataSnapshotImpl(),
        'TEST_ROOM',
      );
      expect(players, ['JOHN', 'PAUL', 'GORGES', 'RINGO']);
    });

    test('getPlayersInRoom', () async {
      isRunningOffLine = true;
      final players = await getPlayersInRoom('TEST_ROOM');
      expect(players, ['BOB', 'SUE', 'JOHN', 'MARY']);

      // this does nothing in offline mode, but we still want to test that the function exist
      setPlayersInRoom('TEST_ROOM', {'BOB', 'SUE', 'JOHN', 'MARY'});
    });

    test('game history', () async {
      isRunningOffLine = true;
      // this does nothing in offline mode, but we still want to test that the function exist
      final history = await getGameHistory('TEST_ROOM');
      expect(history, []);
    });

    test('game recordPlayerWin', () async {
      isRunningOffLine = true;
      // this does nothing in offline mode, but we still want to test that the function exist
      await recordPlayerWin('TEST_ROOM', DateTime.now(), 'BOB');
    });

    test('game getAllRooms', () async {
      isRunningOffLine = true;
      // this does nothing in offline mode, but we still want to test that the function exist
      final rooms = await getAllRooms();
      expect(rooms, ['TEST_ROOM']);
    });
  });
}
