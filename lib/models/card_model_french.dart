/// Represents a playing card with a suit and rank, specifically for a French-suited deck.
///
/// The [CardModelFrench] class provides static methods and constants for working with
/// a standard French-suited deck of playing cards. It includes methods for getting the
/// numerical value of a card rank and defines the valid suits and ranks.
class CardModelFrench {
  /// Returns the numerical value of a card rank.
  ///
  /// Handles special cases for 'A', 'X', 'K', 'Q', 'J', '§'
  /// Ranks '2' through '10' return their face value.
  /// Returns 0 if the rank is invalid.
  ///
  /// @param rank The rank of the card as a String.
  /// @return The numerical value of the card rank as an int.
  static int getValue(rank) {
    if (rank == '§') {
      return -2;
    }
    if (rank == 'A') {
      return 1;
    }
    if (rank == 'X') {
      return 10;
    }
    if (rank == 'J') {
      return 11;
    }
    if (rank == 'Q') {
      return 12;
    }
    if (rank == 'K') {
      return 0;
    }

    // face value for cards from 2 to 10
    return int.tryParse(rank) ?? 0;
  }

  /// A list of valid suits for a French-suited deck of cards.
  static const List<String> suits = [
    '♠️',
    '♥️',
    '♣️',
    '♦️',
  ];

  /// A list of valid ranks for a French-suited deck of cards.
  ///
  /// Includes 'A' (Ace), '2' through '9', 'X' (10), 'J' (Jack), 'Q' (Queen), and 'K' (King).
  /// Note that Jokers ('§') are not included here as they are handled separately.
  static const List<String> ranks = [
    'A', // Ace
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'X', // 10
    'J', // Jack
    'Q', // Queen
    'K', // King
    // '§', // Joker are special we ony generate 2 per deck, so do not include them here
  ];
}
