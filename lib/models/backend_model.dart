import 'dart:async';
import 'dart:core';

import 'package:cards/misc.dart';
import 'package:cards/models/firebase_options.dart';
import 'package:cards/models/game_history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

bool isRunningOffLine = false;
bool _backendReady = isRunningOffLine;
bool get backendReady => _backendReady;
set backendReady(bool value) {
  _backendReady = value;
}

Future<void> useFirebase() async {
  if (isRunningOffLine) {
    debugLog('---------------------');
    debugLog('RUNNING OFFLINE');
    debugLog('---------------------');

    backendReady = true;
  } else {
    try {
      if (backendReady == false) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );

        if (isRunningOffLine) {
          await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
        }

        await FirebaseAuth.instance.signInAnonymously();
        backendReady = true;
      }
    } catch (e) {
      backendReady = false;
      debugLog('---------------------');
      debugLog(e.toString());
      debugLog('---------------------');
    }
  }
}

Future<List<String>> getPlayersInRoom(final String roomId) async {
  if (isRunningOffLine) {
    return ['BOB', 'SUE', 'JOHN', 'MARY'];
  }

  final DataSnapshot dataSnapshot =
      await FirebaseDatabase.instance.ref('rooms/$roomId/invitees').get();

  final List? players = dataSnapshot.value as List?;

  if (players == null) {
    return [];
  } else {
    return players.cast<String>().toList();
  }
}

void setPlayersInRoom(final String room, final Set<String> playersNames) {
  if (isRunningOffLine) {
    return;
  }

  useFirebase().then((_) {
    FirebaseDatabase.instance
        .ref('rooms/$room/invitees')
        .set(playersNames.toList());
  });
}

Future<List<GameHistory>> getGameHistory(final String roomName) async {
  List<GameHistory> list = [];
  if (!isRunningOffLine) {
    try {
      final DataSnapshot dataSnapshot =
          await FirebaseDatabase.instance.ref('history/$roomName/').get();

      if (dataSnapshot.exists && dataSnapshot.value is Map) {
        final Map data = dataSnapshot.value as Map;

        data.forEach((key, value) {
          final gameHistory = GameHistory();
          gameHistory.date =
              DateTime.fromMillisecondsSinceEpoch(int.parse(key));
          gameHistory.playersNames = [value];

          list.add(gameHistory);
        });
      }
    } catch (error) {
      debugLog('getGameHistory: ${error.toString()}');
    }
  }

  return list;
}

Future<void> recordPlayerWin(
  final String roomName,
  final DateTime gameStartDate,
  final String playerName,
) async {
  if (isRunningOffLine) {
    return;
  }

  try {
    final String dateTimeAsKey =
        gameStartDate.millisecondsSinceEpoch.toString();

    final DatabaseEvent dataFound = await FirebaseDatabase.instance
        .ref(
          'history/$roomName/$dateTimeAsKey',
        )
        .once();

    // only record it once
    if (!dataFound.snapshot.exists) {
      await FirebaseDatabase.instance
          .ref(
            'history/$roomName/$dateTimeAsKey',
          )
          .set(playerName);
    }
  } catch (error) {
    debugLog('Error recording player win: ${error.toString()}');
  }
}

StreamSubscription onBackendInviteesUpdated(
  final String roomId,
  void Function(List<String>) onInviteesNamesChanged,
) {
  return FirebaseDatabase.instance
      .ref()
      .onValue
      .listen((final DatabaseEvent event) {
    getInviteesFromDataSnapshot(event.snapshot, roomId);
    onInviteesNamesChanged(getInviteesFromDataSnapshot(event.snapshot, roomId));
  });
}

List<String> getInviteesFromDataSnapshot(
  final DataSnapshot snapshot,
  final String roomId,
) {
  List<String> playersNames = [];
  if (snapshot.exists) {
    final Object? data = snapshot.value;

    // Safely access and update the player list from the Firebase snapshot.
    if (data != null && data is Map) {
      final rooms = data['rooms'] as Map?;
      if (rooms != null) {
        final room = rooms[roomId] as Map?;
        if (room != null) {
          final players = room['invitees'] as List?;
          if (players != null) {
            playersNames = players.cast<String>().toList();
          }
        }
      }
    }
  }
  return playersNames;
}

Future<List<String>> getAllRooms() async {
  if (isRunningOffLine) {
    return ['TEST_ROOM'];
  }

  final DataSnapshot dataSnapshot =
      await FirebaseDatabase.instance.ref('rooms').get();
  final List<String> rooms = [];

  if (dataSnapshot.exists && dataSnapshot.value is Map) {
    final Map<dynamic, dynamic> data =
        dataSnapshot.value as Map<dynamic, dynamic>;
    data.forEach((key, value) {
      rooms.add(key.toString());
    });
  }

  return rooms;
}
