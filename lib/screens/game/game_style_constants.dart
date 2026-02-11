/// Configuration constants for varied game styles.
///
/// This class defines the rules and layout parameters for the different
/// supported game modes (SkyJo, 9-Card Golf, MiniPut).
class GameStyleConstants {
  const GameStyleConstants();

  // SkyJo Card Rules
  /// The special value for Joker/Special cards in SkyJo.
  static const int skyJoSpecialValue = -2;

  /// Minimum rank value allowed in SkyJo.
  static const int skyJoRankMin = -2;

  /// Maximum rank value allowed in SkyJo.
  static const int skyJoRankMax = 12;

  // Visual Layout
  /// Divider used for scaling card display sizes.
  static const int cardDisplayDivisor = 3;

  // Hand Sizes (Grid dimensions)
  /// Number of cards for a standard 3x3 Golf game.
  static const int standardCardCount = 9;

  /// Number of cards for a 4x3 SkyJo game.
  static const int skyJoCardCount = 12;

  /// Number of cards for a 2x2 MiniPut game.
  static const int miniPutCardCount = 4;

  // Deck Management
  /// Divider used to calculate the number of decks needed based on player count.
  static const int deckCalculationDivider = 2;

  /// Utility to calculate the required number of card decks for a session.
  static int calculateDecks(int numberOfPlayers) =>
      (numberOfPlayers + 1) ~/ deckCalculationDivider;
}
