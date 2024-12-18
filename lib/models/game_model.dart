// ignore: avoid_web_libraries_in_flutter
// Imports
import 'package:cards/models/backend_model.dart';
import 'package:cards/models/deck_model.dart';
import 'package:cards/models/game_history.dart';
import 'package:cards/models/game_style.dart';
import 'package:cards/models/player_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Exports
export 'package:cards/models/deck_model.dart';
export 'package:cards/models/game_style.dart';
export 'package:cards/models/player_model.dart';

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
    names.forEach((name) => addPlayer(name));

    if (isNewGame) {
      initializeGame();
    }
  }

  // Model version
  final String version;

  // Type of game
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

  void addPlayer(String name) {
    if (gameStyle == GameStyles.skyJo) {
      players.add(
        PlayerModel(
          name: name,
          columns: 4,
          rows: 3,
          skyJoLogic: true,
        ),
      );
    } else {
      players.add(
        PlayerModel(
          name: name,
          columns: 3,
          rows: 3,
          skyJoLogic: false,
        ),
      );
    }
  }

  // must be override by models
  String get mode => 'Custom';

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

  void pushGameModelToBackend() {
    if (backendReady) {
      if (isRunningOffLine == false) {
        final refPlayers =
            FirebaseDatabase.instance.ref().child('rooms/$roomName');
        refPlayers.set(this.toJson());
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

  DeckModel loadDeck(Map<String, dynamic> json) {
    return DeckModel.fromJson(
      json,
      gameStyle,
    );
  }

  PlayerModel loadPlayer(Map<String, dynamic> json) {
    switch (gameStyle) {
      case GameStyles.skyJo:
        return PlayerModel.fromJson(
          json: json,
          columns: 4,
          rows: 3,
          skyJoLogic: true,
        );
      case GameStyles.frenchCards9:
        return PlayerModel.fromJson(
          json: json,
          columns: 3,
          rows: 3,
          skyJoLogic: false,
        );
      case GameStyles.miniPut:
        return PlayerModel.fromJson(
          json: json,
          columns: 2,
          rows: 2,
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
    players.forEach((player) {
      player.clear();
      dealCards(player);
      player.revealRandomCardsInHand(cardsToReveal);
    });

    // Add a card to the discard pile if the deck is not empty.
    if (deck.cardsDeckPile.isNotEmpty) {
      deck.cardsDeckDiscarded.add(deck.cardsDeckPile.removeLast());
    }
    gameState = GameStates.pickCardFromEitherPiles;
  }

  List<DateTime> getWinsForPlayerName(final String nameOfPlayer) {
    List<DateTime> list = [];
    roomHistory.forEach((game) {
      if (game.playersNames.first == nameOfPlayer) {
        list.add(game.date);
      }
    });
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

  void onDropCardOnCard(
    final BuildContext context,
    final CardModel cardSource,
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
          swapDragCardOnPlayersTargetCard(
            context,
            cardTarget,
          );
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

  void swapDragCardOnPlayersTargetCard(
    BuildContext context,
    CardModel cardTarget,
  ) {
    // Find the index of the target card in the player's hand
    final int targetIndex = players[playerIdPlaying].hand.indexOf(cardTarget);

    if (targetIndex != -1) {
      swapCardWithTopPile(
        players[playerIdPlaying],
        targetIndex,
      );
      moveToNextPlayer(context); // Assuming context is available
      // Optionally add a state update notification here
      notifyListeners();
    }
  }

  /// Swaps the selected card with a card in the player's hand.
  ///
  /// [playerIndex] is the index of the player whose hand is being modified.
  /// [cardIndex] is the index of the card in the player's hand to swap.
  void swapCardWithTopPile(
    final PlayerModel player,
    final int cardIndex,
  ) {
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

      if (this.isFinalTurn) {
        if (areAllCardsFromHandsRevealed()) {
          gameState = GameStates.gameOver;
        }
      }
    } else {
      notifyCardUnavailable(context, 'Not allowed!');
    }
  }

  /// Handles the logic for flipping a card during the [GameStates.revealOneHiddenCard] game state.
  bool handleFlipOneCardState(
    final PlayerModel player,
    final int cardIndex,
  ) {
    if (gameState == GameStates.revealOneHiddenCard &&
        player.hand[cardIndex].isRevealed == false) {
      // reveal the card
      player.hand[cardIndex].isRevealed = true;

      return true;
    }
    return false;
  }

  /// Handles the logic for flipping and swapping a card during the 'flipAndSwap' game state.
  bool handleFlipAndSwapState(
    final PlayerModel player,
    final int cardIndex,
  ) {
    if (gameState == GameStates.swapTopDeckCardWithAnyCardsInHandOrDiscard ||
        gameState == GameStates.swapDiscardedCardWithAnyCardsInHand) {
      swapCardWithTopPile(
        player,
        cardIndex,
      );

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

  void evaluateHand() {
    if (gameStyle == GameStyles.skyJo) {
      evaluateHandSkyJo();
    } else {
      // TODO
      //evaluateHandGolf();
    }
  }

  void evaluateHandSkyJo() {
    var player = players[playerIdPlaying];

    for (int i = 0; i < player.hand.length - 2; i += 3) {
      if (player.hand[i].isRevealed &&
          player.hand[i + 1].isRevealed &&
          player.hand[i + 2].isRevealed &&
          player.areAllTheSameRank(
            player.hand[i].rank,
            player.hand[i + 1].rank,
            player.hand[i + 2].rank,
          )) {
        deck.cardsDeckDiscarded.add(player.hand[i]);
        player.hand.removeAt(i);
        deck.cardsDeckDiscarded.add(player.hand[i]);
        player.hand.removeAt(i);
        deck.cardsDeckDiscarded.add(player.hand[i]);
        player.hand.removeAt(i);
        // We have removed the cards from the hand, reduce the index before the
        // next iteration
        i -= 3;
      }
    }
  }

  /// Advances the game to the next player's turn.
  void moveToNextPlayer(BuildContext context) {
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

  static String getLinkToGameFromInput(
    final String mode,
    final String room,
    final List<String> names,
  ) {
    return '?mode=$mode&room=$room&players=${names.join(",")}';
  }

  String get linkUri => getLinkToGameFromInput(
        this.mode,
        this.roomName,
        this.getPlayersNames(),
      );

  String getLinkToGame() {
    if (kIsWeb) {
      return Uri.base.origin + linkUri;
    }
    return '';
  }
}

void showTurnNotification(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
  );
}

enum GameStates {
  notStarted,
  pickCardFromEitherPiles,
  swapTopDeckCardWithAnyCardsInHandOrDiscard,
  revealOneHiddenCard,
  swapDiscardedCardWithAnyCardsInHand,
  gameOver,
}
