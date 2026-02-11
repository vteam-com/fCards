/// Standardized card values and display offsets.
///
/// This class maintains the canonical scoring values for different card ranks
/// across various game modes (SkyJo, Golf, etc.).
class ConstCardValue {
  const ConstCardValue();

  // Generic Rank Values
  static const int cardValueJoker = -2;
  static const int cardValueKing = 0;
  static const int cardValueAce = 1;
  static const int cardValue2 = 2;
  static const int cardValue3 = 3;
  static const int cardValue4 = 4;
  static const int cardValue5 = 5;
  static const int cardValue6 = 6;
  static const int cardValue7 = 7;
  static const int cardValue8 = 8;
  static const int cardValue9 = 9;
  static const int cardValue10 = 10;
  static const int cardValueJack = 11;
  static const int cardValueQueen = 12;

  // SkyJo Specifics
  /// Minimum possible card value in SkyJo (-2).
  static const int skyjoMinValue = -2;

  /// Maximum possible card value in SkyJo (12).
  static const int skyjoMaxValue = 12;

  /// Number of '0' cards in a SkyJo deck.
  static const int skyjoZeroCardCount = 15;

  /// Number of '-2' cards in a SkyJo deck.
  static const int skyjoNegativeTwoCardCount = 5;

  /// Standard count for other numbered cards in a SkyJo deck.
  static const int skyjoOtherCardCount = 10;

  /// Threshold for AI/Logic level 5.
  static const int skyjoValueThreshold5 = 5;

  /// Threshold for AI/Logic level 9.
  static const int skyjoValueThreshold9 = 9;

  // Golf Specifics
  /// Number of jokers in a Golf game.
  static const int golfJokerCount = 2;

  /// Point value of a joker in Golf (-2).
  static const int golfJokerValue = -2;

  // UI Display Offsets
  /// Standard offset for stacked cards (10.0).
  static const double cardOffset10 = 10.0;

  /// Wide offset for stacked cards (15.0).
  static const double cardOffset15 = 15.0;

  /// Extra wide offset for stacked cards (20.0).
  static const double cardOffset20 = 20.0;

  /// Deep offset for card stacks (30.0).
  static const double cardOffset30 = 30.0;

  /// Maximum offset for card stacks (50.0).
  static const double cardOffset50 = 50.0;
}
