import 'package:cards/misc.dart';
import 'package:cards/models/hand_model.dart';
import 'package:cards/models/player_status.dart';

export 'package:cards/models/card_model.dart';
export 'package:cards/models/hand_model.dart';
export 'package:cards/models/player_status.dart';

/// Represents a player in the card game.
///
/// This class encapsulates all the properties and behaviors associated with a player,
/// including their name, hand of cards, game status, and various game-related flags.
///
/// Parameters:
/// - [name]: The name of the player.
/// - [columns]: The number of columns in the player's hand grid.
/// - [rows]: The number of rows in the player's hand grid.
/// - [skyJoLogic]: A flag indicating whether SkyJo game logic should be used.
class PlayerModel {
  ///
  /// Creates a `PlayerModel` with the given name.
  ///
  PlayerModel({
    required this.name,
    required this.columns,
    required this.rows,
    required this.skyJoLogic,
  }) {
    clear();
  }

  /// Creates a `PlayerModel` from a JSON map.
  ///
  /// This factory constructor takes a JSON map representing a player and
  /// constructs a `PlayerModel` instance.  It parses the player's name, hand,
  /// and card visibility from the JSON data.
  ///
  /// Args:
  ///   json (```Map<String, dynamic>```): The JSON map representing the player.
  ///       This map should contain the keys 'name', 'hand', and
  ///       'cardVisibility'.  The 'hand' value should be a list of JSON maps
  ///       representing cards, and the 'cardVisibility' value should be a list
  ///       of booleans.
  ///
  /// Returns:
  ///   PlayerModel: A new `PlayerModel` instance initialized with the data from
  ///       the JSON map.
  factory PlayerModel.fromJson({
    required final Map<String, dynamic> json,
    required final int columns,
    required final int rows,
    required final bool skyJoLogic,
  }) {
    // Create a new PlayerModel instance with the parsed data.
    final PlayerModel instance = PlayerModel(
      name: json['name'] as String,
      columns: columns,
      rows: rows,
      skyJoLogic: skyJoLogic,
    );

    // Status
    final status = json['status'];
    if (status is Map<String, dynamic>) {
      instance.status = PlayerStatus.fromJson(status);
    }

    // Hand
    try {
      instance.hand = HandModel(
        columns,
        rows,
        (json['hand'] as List<dynamic>)
            .map(
              (cardJson) => CardModel.fromJson(
                cardJson as Map<String, dynamic>,
              ),
            )
            .toList(),
      );
    } catch (error) {
      debugLog(error.toString());
    }

    return instance;
  }

  /// Properties
  /// The unique identifier for the player.
  ///
  /// This ID is used to distinguish between different players in the game.
  /// It's initialized to -1 and should be set to a unique positive integer
  /// when the player joins a game.
  int id = -1;

  /// The name of the player.
  final String name;

  /// The number of columns in the player's hand grid.
  final int columns;

  /// The number of rows in the player's hand grid.
  final int rows;

  /// A flag indicating whether SkyJo game logic should be used.
  ///
  /// If true, SkyJo scoring rules are applied. If false, standard rules are used.
  final bool skyJoLogic;

  /// The current status of the player in the game.
  ///
  /// Initialized with the first status from the list of player statuses.
  PlayerStatus status = playersStatuses.first;

  /// Indicates whether this player is currently the active player in the game.
  ///
  /// True if this player is active, false otherwise.
  bool isActivePlayer = false;

  /// Indicates whether this player has won the game.
  ///
  /// Set to true when the player wins, false otherwise.
  bool isWinner = false;

  /// Calculates and returns the sum of revealed cards in the player's hand.
  ///
  /// The calculation method depends on the game logic:
  /// - If [skyJoLogic] is true, it uses SkyJo scoring rules.
  /// - If [skyJoLogic] is false, it uses Golf scoring rules.
  ///
  /// Returns:
  ///   An integer representing the sum of revealed cards.
  int get sumOfRevealedCards {
    if (skyJoLogic) {
      return hand.getSumOfCardsInHandSkyJo();
    } else {
      return hand.getSumOfCardsForGolf();
    }
  }

  /// The list of cards in the player's hand.
  ///
  /// Initialized as an empty hand with 0 columns and rows.
  HandModel hand = HandModel(0, 0, []);

  /// Clears the player's hand and initializes a new empty hand.
  ///
  /// This method resets the player's hand to an empty state using the
  /// player's defined number of columns and rows.
  void clear() {
    hand = HandModel(columns, rows, []);
  }

  /// Checks if all cards in the player's hand are revealed.
  ///
  /// Returns:
  ///   A boolean value. True if all cards are revealed, false otherwise.
  bool areAllCardsRevealed() {
    return hand.areAllCardsRevealed();
  }

  /// Adds a card to the player's hand.
  ///
  /// Parameters:
  ///   [card]: The CardModel object to be added to the hand.
  void addCardToHand(CardModel card) {
    hand.add(card);
  }

  /// Reveals a specified number of random cards in the player's hand.
  ///
  /// Parameters:
  ///   [numberOfCardsToReveal]: The number of cards to reveal randomly.

  void revealRandomCardsInHand(int numberOfCardsToReveal) {
    hand.revealCards(numberOfCardsToReveal);
  }

  /// Checks if three given ranks are all the same.
  ///
  /// This function compares three string representations of card ranks to determine
  /// if they are all identical.
  ///
  /// Parameters:
  /// - [rank1]: A string representing the first card rank.
  /// - [rank2]: A string representing the second card rank.
  /// - [rank3]: A string representing the third card rank.
  ///
  /// Returns:
  /// A boolean value. Returns true if all three ranks are identical, false otherwise.
  bool areAllTheSameRank(String rank1, String rank2, String rank3) {
    return rank1 == rank2 && rank2 == rank3;
  }

  /// Converts the PlayerModel instance to a JSON-serializable map.
  ///
  /// This method creates a map representation of the player's data, which can be
  /// easily converted to JSON for storage or transmission.
  ///
  /// Returns:
  ///   A [Map<String, dynamic>] containing the following key-value pairs:
  ///   - 'name': The player's name as a String.
  ///   - 'hand': A JSON representation of the player's hand, obtained by calling
  ///             [toJson] on the [hand] property.
  ///   - 'status': A JSON representation of the player's status, obtained by calling
  ///               [toJson] on the [status] property.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'hand': hand.toJson(),
      'status': status.toJson(),
    };
  }

  @override
  String toString() {
    return 'Player[$id] ${name.padRight(10)} ${isActivePlayer ? "* " : '  '} $hand ${sumOfRevealedCards.toString().padLeft(3)}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is PlayerModel &&
        other.id == id &&
        other.name == name &&
        other.isActivePlayer == isActivePlayer &&
        other.hand.length == hand.length &&
        List.generate(hand.length, (i) => hand[i] == other.hand[i])
            .every((bool equalResult) => equalResult);
  }

  @override
  int get hashCode => Object.hash(id, name, isActivePlayer, hand.hashCode);
}
