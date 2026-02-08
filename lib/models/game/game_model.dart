// fcheck - ignore magic numbers
// Imports

import 'package:cards/models/game/backend_model.dart';
import 'package:cards/models/game/deck_model.dart';

import 'package:cards/models/game/game_history.dart';
import 'package:cards/models/game/game_styles.dart';

import 'package:cards/models/player/player_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Exports
export 'package:cards/models/game/deck_model.dart';
export 'package:cards/models/player/player_model.dart';

/// Represents a game model that manages the state and logic of a game.
/// This class extends `ChangeNotifier` to allow for state changes to be
/// observed by other parts of the application.
class GameModel with ChangeNotifier {
  /// Creates a new game model.
  ///
  /// [roomName] is the ID of the room this game is in.
  /// [names] is the list of player names.
  /// [cardsToDeal] is the number of cards to deal to each player
  /// [deck] a cardDeck to use for the game
  /// [isNewGame] indicates whether this is a new game or joining an existing one.
  GameModel({
    required this.gameStyle,
    required this.roomName,
    required this.roomHistory,
    required this.loginUserName,
    required final List<String> names,
    required this.cardsToDeal,
    required this.deck,
    bool isNewGame = false,
    this.version = '',
  }) {
    // Initialize players from the list of names
    for (var name in names) {
      addPlayer(name);
    }

    if (isNewGame) {
      initializeGame();
    }
  }

  /// Model version
  final String version;

  /// Type of game
  final GameStyles gameStyle;

  /// Game Unique Id based on DateTime
  DateTime gameStartDate = DateTime.now();

  /// al the games played in this room
  final List<GameHistory> roomHistory;

  /// The number of cards to deal to each player
  final int cardsToDeal;

  /// The Name of the game room.
  final String roomName;

  /// The name of the person running the app.
  final String loginUserName;

  /// When did the date start
  DateTime startedOn = DateTime.fromMillisecondsSinceEpoch(0);

  /// When did the date end
  DateTime endedOn = DateTime.fromMillisecondsSinceEpoch(0);

  /// The deck of cards used in the game.
  DeckModel deck;

  /// List of players in the game.
  final List<PlayerModel> players = [];

  /// The index of the player currently playing.
  int playerIdPlaying = 0;

  /// The index of the player being attacked in the final turn. -1 if not the final turn.
  int playerIdAttacking = -1;

  /// Whether the game is in the final turn.
  bool get isFinalTurn => playerIdAttacking != -1;

  /// The current state of the game.
  GameStates _gameState = GameStates.notStarted;

  /// The current state of the game.
  GameStates get gameState => _gameState;

  /// Adds a new player to the game.
  ///
  /// The player is added to the [players] list. The player's properties are set based on the [gameStyle]:
  /// - If [gameStyle] is [GameStyles.skyJo], the player has 4 columns and 3 rows, and [skyJoLogic] is set to `true`.
  /// - Otherwise, the player has 3 columns and 3 rows, and [skyJoLogic] is set to `false`.
  ///
  /// @param name The name of the new player.
  void addPlayer(String name) {
    if (gameStyle == GameStyles.skyJo) {
      players.add(
        PlayerModel(
          name: name,
          columns: CardModel.skyjoColumns,
          rows: CardModel.skyjoRows,
          skyJoLogic: true,
        ),
      );
    } else {
      players.add(
        PlayerModel(
          name: name,
          columns: CardModel.standardColumns,
          rows: CardModel.standardRows,
          skyJoLogic: false,
        ),
      );
    }
  }

  /// Sets the game state and updates the database if backend is ready.
  set gameState(GameStates value) {
    if (_gameState != value) {
      _gameState = value;

      if (isRunningOffLine) {
        notifyListeners();
      } else {
        pushGameModelToBackend();
      }
    }
  }

  /// Pushes the current game model to the backend.
  ///
  /// This method checks if the backend is ready and the app is not running offline. If both conditions are met, it updates the game state in the Firebase Realtime Database under the 'rooms/$roomName' path.
  void pushGameModelToBackend() {
    if (backendReady) {
      if (isRunningOffLine == false) {
        final refPlayers = FirebaseDatabase.instance.ref().child(
          'rooms/$roomName',
        );
        refPlayers.set(toJson());
      }
    }
  }

  /// The number of players in the game.
  int get numPlayers => players.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is GameModel &&
        other.gameState == gameState &&
        other.playerIdPlaying == playerIdPlaying &&
        listEquals(other.players, players);
  }

  @override
  int get hashCode =>
      Object.hash(gameState, playerIdPlaying, Object.hashAll(players));

  /// Loads the game state from a JSON object.
  ///
  /// [json] should contain:
  /// - 'deck': JSON object representing the deck state
  /// - 'playerIdPlaying': index of active player
  /// - 'playerIdAttacking': index of player being attacked (-1 if not in final turn)
  /// - 'state': string representation of game state
  void _loadGameState(Map<String, dynamic> json) {
    deck = loadDeck(json['deck']);
    setActivePlayer(json['playerIdPlaying']);
    playerIdAttacking = json['playerIdAttacking'];
    _gameState = GameStates.values.firstWhere(
      (e) => e.toString() == json['state'],
      orElse: () => GameStates.pickCardFromEitherPiles,
    );
  }

  /// Loads a deck from JSON data.
  ///
  /// This function is responsible for parsing and deserializing the deck data from the given JSON object.
  ///
  /// - Parameters:
  ///   - json: The JSON data to load the deck from.
  ///
  /// - Returns: A new instance of `DeckModel` representing the loaded deck, or null if the loading fails.
  DeckModel loadDeck(Map<String, dynamic> json) {
    return DeckModel.fromJson(json, gameStyle);
  }

  /// Loads a player model from a JSON object, with the player configuration based on the current game style.
  ///
  /// The [json] parameter should contain the player data to be loaded.
  /// The [gameStyle] property of the current [GameModel] is used to determine the appropriate player configuration.
  /// For each supported game style, this method creates a [PlayerModel] instance with the corresponding columns, rows, and sky-jo logic settings.
  /// If the [gameStyle] is [GameStyles.custom], the player is created with 0 columns and 0 rows, and sky-jo logic disabled.
  PlayerModel loadPlayer(Map<String, dynamic> json) {
    switch (gameStyle) {
      case GameStyles.skyJo:
        return PlayerModel.fromJson(
          json: json,
          columns: CardModel.skyjoColumns,
          rows: CardModel.skyjoRows,
          skyJoLogic: true,
        );
      case GameStyles.frenchCards9:
        return PlayerModel.fromJson(
          json: json,
          columns: CardModel.standardColumns,
          rows: CardModel.standardRows,
          skyJoLogic: false,
        );
      case GameStyles.miniPut:
        return PlayerModel.fromJson(
          json: json,
          columns: CardModel.miniPutColumns,
          rows: CardModel.miniPutRows,
          skyJoLogic: false,
        );
      case GameStyles.custom:
        return PlayerModel.fromJson(
          json: json,
          columns: 0,
          rows: 0,
          skyJoLogic: false,
        );
    }
  }

  /// Updates the game model from a JSON object.
  ///
  /// [json] should contain:
  /// - 'players': array of player JSON objects
  /// - 'deck': deck JSON object
  /// - 'playerIdPlaying': active player index
  /// - 'playerIdAttacking': attacked player index
  /// - 'state': game state string
  void fromJson(Map<String, dynamic> json) {
    _loadPlayers(json['players'] ?? []);
    _loadGameState(json);
  }

  /// Loads player data from a JSON array.
  ///
  /// [playersJson] array of player JSON objects containing player state.
  /// Clears existing players and recreates them from the JSON data,
  /// assigning sequential IDs starting from 0.
  void _loadPlayers(List<dynamic> playersJson) {
    players.clear();
    int index = 0;
    for (final dynamic playerJson in playersJson) {
      final PlayerModel player = loadPlayer(playerJson);
      player.id = index++;
      players.add(player);
    }
  }

  /// Sets the active player to the player at the given index.
  ///
  /// [index] The index of the player to set as active.
  /// Updates the playerIdPlaying field and sets isActivePlayer flag
  /// to true for the selected player and false for all other players.
  void setActivePlayer(final int index) {
    playerIdPlaying = index;
    for (int index = 0; index < players.length; index++) {
      players[index].isActivePlayer = (index == playerIdPlaying);
    }
  }

  /// Converts the game model to a JSON object.
  ///
  /// The JSON object contains the following properties:
  /// - `players`: a list of JSON objects representing the players in the game
  /// - `deck`: a JSON object representing the game deck
  /// - `invitees`: a list of player names
  /// - `playerIdPlaying`: the index of the player currently playing
  /// - `playerIdAttacking`: the index of the player being attacked in the final turn, or -1 if not the final turn
  /// - `state`: the current state of the game as a string
  Map<String, dynamic> toJson() {
    return {
      'players': players.map((player) => player.toJson()).toList(),
      'deck': deck.toJson(),
      'invitees': players.map((player) => player.name).toList(),
      'playerIdPlaying': playerIdPlaying,
      'playerIdAttacking': playerIdAttacking,
      'state': gameState.toString(),
    };
  }

  @override
  String toString() {
    return '${deck.cardsDeckPile.last} ${deck.cardsDeckDiscarded.last}';
  }

  /// Returns the name of the player at the given index.
  String getPlayerName(final int index) {
    if (index < 0 || index >= players.length) {
      return 'No one';
    }
    return players[index].name;
  }

  /// Returns a list of the names of all players in the game.
  List<String> getPlayersNames() {
    return players.map((player) => player.name).toList();
  }

  /// Initializes the game state, including dealing cards and setting the initial game state.
  void initializeGame() {
    startedOn = DateTime.now();
    playerIdPlaying = 0;
    playerIdAttacking = -1;
    gameStartDate = DateTime.now();

    deck.shuffle();

    int cardsToReveal = numberOfCardsToRevealOnStartup(gameStyle);

    // Deal cards to each players and reveal the initial cards (cardsToReveal = 1 or 2).
    for (var player in players) {
      player.clear();
      dealCards(player);
      player.revealRandomCardsInHand(cardsToReveal);
    }

    // Add a card to the discard pile if the deck is not empty.
    if (deck.cardsDeckPile.isNotEmpty) {
      deck.cardsDeckDiscarded.add(deck.cardsDeckPile.removeLast());
    }
    gameState = GameStates.pickCardFromEitherPiles;
  }

  /// Returns a list of the dates when the given player won a game.
  ///
  /// [nameOfPlayer] The name of the player to get the win dates for.
  /// Returns a list of [DateTime] objects representing the dates when the player won.
  List<DateTime> getWinsForPlayerName(final String nameOfPlayer) {
    List<DateTime> list = [];
    for (var game in roomHistory) {
      if (game.playersNames.first == nameOfPlayer) {
        list.add(game.date);
      }
    }
    return list;
  }

  /// Deals the proper cards to the given player from the deck.
  ///
  /// [player The player to deal cards to.
  void dealCards(PlayerModel player) {
    for (int i = 0; i < cardsToDeal; i++) {
      player.addCardToHand(deck.cardsDeckPile.removeLast());
    }
  }

  /// Allows a player to draw a card, either from the discard pile or the deck.
  ///
  /// [context] is the BuildContext used for displaying snackbar messages.
  /// [fromDiscardPile] indicates whether to draw from the discard pile or the deck.
  void selectTopCardOfDeck(
    BuildContext context, {
    required bool fromDiscardPile,
  }) {
    if (gameState != GameStates.pickCardFromEitherPiles) {
      showTurnNotification(context, "It's not your turn!");
      return;
    }

    if (fromDiscardPile && deck.cardsDeckDiscarded.isNotEmpty) {
      gameState = GameStates.swapDiscardedCardWithAnyCardsInHand;
    } else if (!fromDiscardPile && deck.cardsDeckPile.isNotEmpty) {
      gameState = GameStates.swapTopDeckCardWithAnyCardsInHandOrDiscard;
    } else {
      showTurnNotification(context, 'No cards available to draw!');
    }
  }

  /// Handles the drop of a card on another card in the game.
  ///
  /// This method is responsible for managing the game state and performing the appropriate actions when a card is dropped on another card. It handles different game states, such as swapping the top deck card with a card in the player's hand or discard pile, and revealing a hidden card.
  ///
  /// [context] The BuildContext used for displaying snackbar messages.
  /// [cardSource] The source card that was dropped.
  /// [cardTarget] The target card that the source card was dropped on.
  void onDropCardOnCard(
    final BuildContext context,
    final CardModel _, //cardSource,
    final CardModel cardTarget,
  ) {
    switch (gameState) {
      case GameStates.swapTopDeckCardWithAnyCardsInHandOrDiscard:
        if (cardTarget == deck.cardsDeckDiscarded.last) {
          // Player has discard the top deck revealed card
          // they now have to turn over one of their hidden card
          deck.cardsDeckDiscarded.add(deck.cardsDeckPile.removeLast());
          gameState = GameStates.revealOneHiddenCard;
          return;
        } else {
          swapDragCardOnPlayersTargetCard(context, cardTarget);
        }
      case GameStates.swapDiscardedCardWithAnyCardsInHand:
        if (cardTarget == deck.cardsDeckDiscarded.last) {
          // Player has just drop the card back down
          // do nothing
          return;
        } else {
          swapDragCardOnPlayersTargetCard(context, cardTarget);
        }
      default:
        // Do nothing or handle other states if necessary
        break;
    }
  }

  /// Swaps the drag card with the target card in the player's hand.
  ///
  /// This method is responsible for finding the index of the target card in the player's hand, and then calling the `swapCardWithTopPile` method to perform the swap. After the swap, it moves to the next player and notifies any listeners of the state change.
  ///
  /// [context] The BuildContext used for accessing the game state and moving to the next player.
  /// [cardTarget] The target card that the drag card was dropped on.
  void swapDragCardOnPlayersTargetCard(
    BuildContext context,
    CardModel cardTarget,
  ) {
    // Find the index of the target card in the player's hand
    final int targetIndex = players[playerIdPlaying].hand.indexOf(cardTarget);

    if (targetIndex != -1) {
      swapCardWithTopPile(players[playerIdPlaying], targetIndex);
      moveToNextPlayer(context); // Assuming context is available
      // Optionally add a state update notification here
      notifyListeners();
    }
  }

  /// Swaps the selected card with a card in the player's hand.
  ///
  /// [playerIndex] is the index of the player whose hand is being modified.
  /// [cardIndex] is the index of the card in the player's hand to swap.
  void swapCardWithTopPile(final PlayerModel player, final int cardIndex) {
    if (player.hand.validIndex(cardIndex)) {
      // do the swap
      CardModel cardToSwapFromPlayer = player.hand[cardIndex];

      // replace players card in their 3x3 with the selected card
      if (gameState == GameStates.swapDiscardedCardWithAnyCardsInHand) {
        player.hand[cardIndex] = deck.cardsDeckDiscarded.removeLast();
      } else {
        player.hand[cardIndex] = deck.cardsDeckPile.removeLast();
      }

      // ensure this card is revealed
      player.hand[cardIndex].isRevealed = true;

      // add players old card to to discard pile
      deck.cardsDeckDiscarded.add(cardToSwapFromPlayer);
    }
  }

  /// Reveals all remaining cards for the specified player.
  ///
  /// [playerIndex] is the index of the player whose cards should be revealed.
  void revealAllRemainingCardsFor(int playerIndex) {
    final PlayerModel player = players[playerIndex];
    player.hand.revealAllCards();
  }

  /// Handles revealing a card, either for flipping or swapping.
  ///
  /// [context] is the BuildContext used for displaying snackbar messages.
  /// [playerIndex] is the index of the player revealing the card.
  /// [cardIndex] is the index of the card being revealed.
  void revealCard(
    BuildContext context,
    final PlayerModel player,
    int cardIndex,
  ) {
    if (player.isActivePlayer == false) {
      notifyCardUnavailable(context, 'Wait your turn!');
      return;
    }

    bool wasSwapped = false;

    if (handleFlipOneCardState(player, cardIndex)) {
      wasSwapped = true;
    }

    if (handleFlipAndSwapState(player, cardIndex)) {
      wasSwapped = true;
    }

    if (wasSwapped) {
      moveToNextPlayer(context);

      if (isFinalTurn) {
        if (areAllCardsFromHandsRevealed()) {
          gameState = GameStates.gameOver;
        }
      }
    } else {
      notifyCardUnavailable(context, 'Not allowed!');
    }
  }

  /// Handles the logic for flipping a card during the [GameStates.revealOneHiddenCard] game state.
  bool handleFlipOneCardState(final PlayerModel player, final int cardIndex) {
    if (gameState == GameStates.revealOneHiddenCard &&
        player.hand[cardIndex].isRevealed == false) {
      // reveal the card
      player.hand[cardIndex].isRevealed = true;

      return true;
    }
    return false;
  }

  /// Handles the logic for flipping and swapping a card during the 'flipAndSwap' game state.
  bool handleFlipAndSwapState(final PlayerModel player, final int cardIndex) {
    if (gameState == GameStates.swapTopDeckCardWithAnyCardsInHandOrDiscard ||
        gameState == GameStates.swapDiscardedCardWithAnyCardsInHand) {
      swapCardWithTopPile(player, cardIndex);

      return true;
    }
    return false;
  }

  /// Displays a snackbar message indicating that a card is unavailable.
  void notifyCardUnavailable(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  /// Checks if all cards are revealed for a specific player.
  bool areAllCardRevealed(final int playerIndex) {
    return players[playerIndex].areAllCardsRevealed();
  }

  /// Checks if all players have revealed all their cards.
  bool areAllCardsFromHandsRevealed() {
    for (int playerIndex = 0; playerIndex < numPlayers; playerIndex++) {
      if (!areAllCardRevealed(playerIndex)) {
        return false;
      }
    }
    return true;
  }

  /// Evaluates the current player's hand based on the game style.
  ///
  /// **Different Game Styles Use Different Scoring Approaches:**
  ///
  /// 🎯 **SkyJo (Active Evaluation)**:
  /// - Removes completed card sets from the player's hand during gameplay
  /// - Cards that form sets (3 of same rank) are discarded and removed from play
  /// - Hand physical composition changes during the game
  ///
  /// 🏌️ **Golf-Style Games (Passive Scoring)**:
  /// - No hand modification - scoring is calculated based on final card layout
  /// - Matched sets don't count toward final score, but cards remain in hand
  /// - Scoring logic resides in `HandModel.getSumOfCardsForGolf()`
  /// - Called when displaying scores, not during active play
  ///
  /// Currently only SkyJo uses active evaluation. Other game styles use
  /// passive scoring through the HandModel's scoring methods.
  void evaluateHand() {
    if (gameStyle == GameStyles.skyJo) {
      // SkyJo actively modifies the hand by removing completed sets
      evaluateHandSkyJo();
    }
    // Golf-style games (French Cards, MiniPut) don't need hand evaluation
    // They use passive scoring via HandModel.getSumOfCardsForGolf()
    // which calculates scores without modifying the hand
  }

  /// Evaluates the player's hand in the 'skyJo' game style.
  /// This method checks the player's hand for sets of three cards with the same rank,
  /// and removes those sets from the hand, adding them to the discarded pile.
  /// The method reduces the index after removing cards to ensure the loop iterates
  /// correctly over the remaining cards in the hand.
  void evaluateHandSkyJo() {
    var player = players[playerIdPlaying];

    for (
      int i = 0;
      i <
          player.hand.length -
              (CardModel.skyjoSetSize - CardModel.setStartOffset);
      i += CardModel.skyjoSetSize
    ) {
      if (player.hand[i + CardModel.firstCardIndexOffset].isRevealed &&
          player.hand[i + CardModel.secondCardIndexOffset].isRevealed &&
          player.hand[i + CardModel.thirdCardIndexOffset].isRevealed &&
          player.areAllTheSameRank(
            player.hand[i + CardModel.firstCardIndexOffset].rank,
            player.hand[i + CardModel.secondCardIndexOffset].rank,
            player.hand[i + CardModel.thirdCardIndexOffset].rank,
          )) {
        deck.cardsDeckDiscarded.add(player.hand[i]);
        player.hand.removeAt(i);
        deck.cardsDeckDiscarded.add(player.hand[i]);
        player.hand.removeAt(i);
        deck.cardsDeckDiscarded.add(player.hand[i]);
        player.hand.removeAt(i);
        // We have removed the cards from the hand, reduce the index before the
        // next iteration
        i -= CardModel.skyjoSetSize;
      }
    }
  }

  /// Advances the game to the next player's turn.
  void moveToNextPlayer(BuildContext _) {
    if (isFinalTurn) {
      revealAllRemainingCardsFor(playerIdPlaying);
    } else {
      if (areAllCardRevealed(playerIdPlaying)) {
        // Start Final Turn
        playerIdAttacking = playerIdPlaying;
      }
    }
    evaluateHand();
    setActivePlayer((playerIdPlaying + 1) % players.length);
    gameState = GameStates.pickCardFromEitherPiles;
  }

  /// Updates the status of the given [player] to the new [newStatus].
  ///
  /// If the game is running offline, this method will notify any listeners of the change.
  /// Otherwise, it will push the updated game model to the backend.
  void updatePlayerStatus(
    final PlayerModel player,
    final PlayerStatus newStatus,
  ) {
    // Update the player's status
    player.status = newStatus;
    if (isRunningOffLine) {
      notifyListeners();
    } else {
      pushGameModelToBackend();
    }
  }

  /// Returns a string representing the current game state, including the current player's name
  /// and the attacker's name if it's the final turn.
  String getGameStateAsString() {
    String playersName = getPlayerName(playerIdPlaying);
    String playerAttackerName = getPlayerName(playerIdAttacking);

    String inputText = playersName == loginUserName
        ? 'It\'s your turn $playersName'
        : 'It\'s $playersName\'s turn';

    if (isFinalTurn) {
      inputText =
          'Final Round. $inputText. You have to beat $playerAttackerName';
    }

    return inputText;
  }

  /// Generates a link URI for the game based on the provided input parameters.
  ///
  /// The link URI includes the game mode, room name, and a comma-separated list of player names.
  /// This method is used to construct the URL for the game, which can be shared with other players.
  ///
  /// @param mode The game mode (as an integer string representing GameStyles enum index).
  /// @param room The name of the game room.
  /// @param names A list of player names.
  /// @return The generated link URI.
  static String getLinkToGameFromInput(
    final String mode,
    final String room,
    final List<String> names,
  ) {
    return '?mode=$mode&room=${Uri.encodeComponent(room)}&players=${Uri.encodeComponent(names.join(","))}';
  }

  /// Generates a link URI for the game based on the provided input parameters.
  ///
  /// The link URI includes the game mode, room name, and a comma-separated list of player names.
  /// This method is used to construct the URL for the game, which can be shared with other players.
  ///
  /// @param mode The game mode, e.g. "classic", "timed", etc.
  /// @param room The name of the game room.
  /// @param names A list of player names.
  /// @return The generated link URI.
  String get linkUri => getLinkToGameFromInput(
    gameStyle.index.toString(),
    roomName,
    getPlayersNames(),
  );

  /// Generates a link URI for the game based on the provided input parameters.
  ///
  /// The link URI includes the game mode, room name, and a comma-separated list of player names.
  /// This method is used to construct the URL for the game, which can be shared with other players.
  ///
  /// @param mode The game mode, e.g. "classic", "timed", etc.
  /// @param room The name of the game room.
  /// @param names A list of player names.
  /// @return The generated link URI.
  String getLinkToGame() {
    if (kIsWeb) {
      return Uri.base.origin + linkUri;
    }
    return '';
  }
}

/// Shows a snack bar notification with the provided message for a short duration.
///
/// This method is used to display a temporary notification to the user, typically
/// to indicate a game-related event or action.
///
/// @param context The [BuildContext] used to access the [ScaffoldMessenger].
/// @param message The message to be displayed in the snack bar.
void showTurnNotification(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
  );
}

/// Represents the different states of the game.
///
/// The game can be in one of the following states:
/// - `notStarted`: The game has not started yet.
/// - `pickCardFromEitherPiles`: The player can pick a card from either the deck or the discard pile.
/// - `swapTopDeckCardWithAnyCardsInHandOrDiscard`: The player can swap the top card of the deck with any card in their hand or the discard pile.
/// - `revealOneHiddenCard`: The player can reveal one of their hidden cards.
/// - `swapDiscardedCardWithAnyCardsInHand`: The player can swap the top card of the discard pile with any card in their hand.
/// - `gameOver`: The game has ended.
enum GameStates {
  /// The game has not started yet.
  notStarted,

  /// The player can pick a card from either the deck or the discard pile.
  pickCardFromEitherPiles,

  /// The player can swap the top card of the deck with any card in their hand or the discard pile.
  swapTopDeckCardWithAnyCardsInHandOrDiscard,

  /// The player can reveal one of their hidden cards.
  revealOneHiddenCard,

  /// The player can swap the top card of the discard pile with any card in their hand.
  swapDiscardedCardWithAnyCardsInHand,

  /// The game has ended.
  gameOver,
}
