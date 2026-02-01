import 'dart:async';
import 'dart:core';

import 'package:cards/utils/log.dart';
import 'package:cards/models/app/firebase_options.dart';
import 'package:cards/models/game/game_history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

/// Indicates whether the app is running offline or not.
///
/// This flag is used to determine the behavior of the app's backend functionality.
/// If the app is running offline, certain operations may be handled differently
/// or may not be available at all.
bool isRunningOffLine = false;

/// @nodoc
bool _backendReady = isRunningOffLine;

/// Indicates whether the backend is ready for use.
///
/// This property is set to `true` when the backend has been successfully
/// initialized, and `false` otherwise. It is used to determine the availability
/// of the backend functionality in the app.
bool get backendReady => _backendReady;
set backendReady(bool value) {
  _backendReady = value;
}

/// Initializes the Firebase backend and sets the [backendReady] flag accordingly.
///
/// This function is responsible for setting up the Firebase backend and ensuring
/// that it is ready for use. If the app is running offline, it sets the
/// [backendReady] flag to true without initializing Firebase. Otherwise, it
/// initializes Firebase, signs in anonymously, and sets the [backendReady] flag
/// to true if the initialization is successful. If there is an error during
/// initialization, it sets the [backendReady] flag to false and logs the error.
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

/// Retrieves the list of players in the specified room.
///
/// If the app is running offline, this method returns a predefined list of
/// player names. Otherwise, it retrieves the list of players from the Firebase
/// Realtime Database.
///
/// @param roomId The ID of the room to retrieve the player list for.
/// @return A Future that completes with a list of player names in the room.
Future<List<String>> getPlayersInRoom(final String roomId) async {
  if (isRunningOffLine) {
    return ['BOB', 'SUE', 'JOHN', 'MARY'];
  }

  final DataSnapshot dataSnapshot = await FirebaseDatabase.instance
      .ref('rooms/$roomId/invitees')
      .get();

  final List? players = dataSnapshot.value as List?;

  if (players == null) {
    return [];
  } else {
    return players.cast<String>().toList();
  }
}

/// Sets the list of players in the specified room.
///
/// If the app is running offline, this method does nothing.
/// Otherwise, it updates the list of players in the Firebase Realtime Database
/// for the specified room.
///
/// @param room The ID of the room to update the player list for.
/// @param playersNames The set of player names to set in the room.
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

/// Retrieves the game history for a specific room.
///
/// If the app is running offline, this method returns an empty list.
/// Otherwise, it fetches the game history from Firebase Realtime Database.
///
/// @param roomName The name of the room to retrieve the game history for.
/// @return A Future that completes with a list of [GameHistory] objects.
Future<List<GameHistory>> getGameHistory(final String roomName) async {
  List<GameHistory> list = [];
  if (!isRunningOffLine) {
    try {
      final DataSnapshot dataSnapshot = await FirebaseDatabase.instance
          .ref('history/$roomName/')
          .get();

      if (dataSnapshot.exists && dataSnapshot.value is Map) {
        final Map data = dataSnapshot.value as Map;

        data.forEach((key, value) {
          final gameHistory = GameHistory();
          gameHistory.date = DateTime.fromMillisecondsSinceEpoch(
            int.parse(key),
          );
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

/// Records a player's win in the game history.
///
/// If the app is running offline, this method does nothing.
/// Otherwise, it records the player's win in the Firebase Realtime Database.
///
/// @param roomName The name of the room where the game was played.
/// @param gameStartDate The start date and time of the game.
/// @param playerName The name of the winning player.
Future<void> recordPlayerWin(
  final String roomName,
  final DateTime gameStartDate,
  final String playerName,
) async {
  if (isRunningOffLine) {
    return;
  }

  try {
    final String dateTimeAsKey = gameStartDate.millisecondsSinceEpoch
        .toString();

    final DatabaseEvent dataFound = await FirebaseDatabase.instance
        .ref('history/$roomName/$dateTimeAsKey')
        .once();

    // only record it once
    if (!dataFound.snapshot.exists) {
      await FirebaseDatabase.instance
          .ref('history/$roomName/$dateTimeAsKey')
          .set(playerName);
    }
  } catch (error) {
    debugLog('Error recording player win: ${error.toString()}');
  }
}

/// Sets up a listener for updates to the list of invitees in a room.
///
/// This method returns a [StreamSubscription] that can be used to cancel the
/// listener when it is no longer needed.
///
/// @param roomId The ID of the room to listen for invitee updates in.
/// @param onInviteesNamesChanged A callback function that is called when the
///     list of invitees changes.
/// @return A [StreamSubscription] that can be used to cancel the listener.
StreamSubscription onBackendInviteesUpdated(
  final String roomId,
  void Function(List<String>) onInviteesNamesChanged,
) {
  return FirebaseDatabase.instance.ref().onValue.listen((
    final DatabaseEvent event,
  ) {
    getInviteesFromDataSnapshot(event.snapshot, roomId);
    onInviteesNamesChanged(getInviteesFromDataSnapshot(event.snapshot, roomId));
  });
}

/// Extracts the list of invitees from a Firebase DataSnapshot.
///
/// @param snapshot The Firebase DataSnapshot to extract the invitees from.
/// @param roomId The ID of the room to extract the invitees for.
/// @return A list of player names.
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

/// Retrieves a list of all available room names.
///
/// If the app is running offline, this method returns a predefined list of
/// room names. Otherwise, it retrieves the list of rooms from the Firebase
/// Realtime Database.
///
/// @return A Future that completes with a list of room names.
Future<List<String>> getAllRooms() async {
  if (isRunningOffLine) {
    return ['TEST_ROOM'];
  }

  final DataSnapshot dataSnapshot = await FirebaseDatabase.instance
      .ref('rooms')
      .get();
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
