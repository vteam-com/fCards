/// Configuration constants for varied game styles.
///
/// This class defines rules and layout parameters for different
/// supported game modes (Skyjo, 9-Card Golf, MiniPut).
class GameConstants {
  const GameConstants();

  // Skyjo Card Rules
  /// The special value for Joker/Special cards in Skyjo.
  static const int skyjoSpecialValue = -2;

  /// Minimum rank value allowed in Skyjo.
  static const int skyjoRankMin = -2;

  /// Maximum rank value allowed in Skyjo.
  static const int skyjoRankMax = 12;

  // Visual Layout
  /// Divider used for scaling card display sizes.
  static const int cardDisplayDivisor = 3;

  // Hand Sizes (Grid dimensions)
  /// Number of cards for a standard 3x3 Golf game.
  static const int standardCardCount = 9;

  /// Number of cards for a 4x3 Skyjo game.
  static const int skyjoCardCount = 12;

  /// Number of cards for a 2x2 MiniPut game.
  static const int miniPutCardCount = 4;

  // Deck Management
  /// Divider used to calculate number of decks needed based on player count.
  static const int deckCalculationDivider = 2;

  /// Utility to calculate required number of card decks for a session.
  static int calculateDecks(int numberOfPlayers) =>
      (numberOfPlayers + 1) ~/ deckCalculationDivider;

  static String playerNumberPrefix = 'Player';

  // Game Style Label Keys
  /// Key for the Skyjo game style label.
  static const String gameStyleLabelKeySkyjo = 'skyjo';
}
