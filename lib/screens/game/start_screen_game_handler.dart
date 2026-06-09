import 'dart:async';

import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/game_history.dart';
import 'package:cards/models/game/game_model.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/screens/game/start_screen_table_name_check_result.dart';
import 'package:cards/screens/game/table_name_flow_helpers.dart';
import 'package:cards/utils/logger.dart';

/// Handles game logic and backend interactions for the start screen.
///
/// This class encapsulates business logic for:
/// - Managing room and player state
/// - Fetching and updating backend data
/// - Handling game initialization
class StartScreenGameHandler {
  /// Callback when players in room are updated.
  final void Function(List<String> playerNames, List<String> rooms)?
  onPlayersUpdated;

  /// Callback when an error occurs.
  final void Function(String error)? onError;

  /// Current subscription to backend updates.
  StreamSubscription? _streamSubscription;

  /// Creates a [StartScreenGameHandler].
  StartScreenGameHandler({this.onPlayersUpdated, this.onError});

  /// Prepares the backend connection for the specified room.
  ///
  /// Fetches initial player data and sets up a stream to listen for updates.
  Future<List<String>> prepareBackEndForRoom(String normalizedRoomId) async {
    if (normalizedRoomId.isEmpty) {
      return [];
    }

    if (isRunningOffLine) {
      return [];
    }

    try {
      await useFirebase();

      final List<String> invitees = await getPlayersInRoom(normalizedRoomId);

      // Set up stream for real-time updates
      _streamSubscription?.cancel();
      _streamSubscription = onBackendInviteesUpdated(normalizedRoomId, (
        invitees,
      ) async {
        final List<String> rooms = await getAllRooms();
        onPlayersUpdated?.call(invitees, rooms);
      });

      return invitees;
    } catch (error) {
      final String errorMessage = error.toString();
      logger.e(errorMessage);
      onError?.call(errorMessage);
      return [];
    }
  }

  /// Adds players to a room.
  Future<void> addPlayersToRoom(
    String roomName,
    Set<String> playerNames,
  ) async {
    if (roomName.isEmpty) {
      return;
    }

    try {
      setPlayersInRoom(roomName, playerNames);
    } catch (error) {
      final String errorMessage = error.toString();
      logger.e(errorMessage);
      onError?.call(errorMessage);
    }
  }

  /// Removes a player from a room.
  Future<void> removePlayerFromRoom(
    String roomName,
    Set<String> playerNames,
  ) async {
    if (roomName.isEmpty) {
      return;
    }

    try {
      setPlayersInRoom(roomName, playerNames);
    } catch (error) {
      final String errorMessage = error.toString();
      logger.e(errorMessage);
      onError?.call(errorMessage);
    }
  }

  /// Initializes a game and returns the GameModel.
  Future<GameModel?> initializeGame({
    required String appVersion,
    required GameStyles gameStyle,
    required String roomName,
    required String playerName,
    required List<String> playerNames,
  }) async {
    if (roomName.isEmpty || playerNames.isEmpty) {
      return null;
    }

    try {
      final List<GameHistory> history = await getGameHistory(roomName);
      logger.d(history.join('|'));

      final config = getGameStyleConfig(gameStyle, playerNames.length);

      return GameModel(
        version: appVersion,
        gameStyle: gameStyle,
        roomName: roomName,
        roomHistory: history,
        loginUserName: playerName.toUpperCase(),
        names: playerNames,
        cardsToDeal: config.cardsToDeal,
        deck: DeckModel(numberOfDecks: config.decks, gameStyle: gameStyle),
        isNewGame: true,
      );
    } catch (error) {
      final String errorMessage = error.toString();
      logger.e(errorMessage);
      onError?.call(errorMessage);
      return null;
    }
  }

  /// Checks if a table name already exists.
  Future<StartScreenTableNameCheckResult> checkTableNameAvailability(
    String tableName,
  ) async {
    if (tableName.isEmpty) {
      return const StartScreenTableNameCheckResult(exists: false, rooms: []);
    }

    if (isRunningOffLine) {
      return const StartScreenTableNameCheckResult(exists: false, rooms: []);
    }

    try {
      final result = await lookupTableNameAvailability(tableName);
      return StartScreenTableNameCheckResult(
        exists: result.exists,
        rooms: result.rooms,
      );
    } catch (error) {
      final String errorMessage = error.toString();
      logger.e(errorMessage);
      onError?.call(errorMessage);
      return const StartScreenTableNameCheckResult(exists: false, rooms: []);
    }
  }

  /// Disposes of resources held by this handler.
  void dispose() {
    _streamSubscription?.cancel();
  }
}
