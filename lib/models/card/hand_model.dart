import 'dart:math';

import 'package:cards/models/card/card_model.dart';
export 'package:cards/models/card/card_model.dart';

/// A model class representing a hand of cards in a card game.
///
/// This class manages a collection of [CardModel] instances arranged in a grid
/// with specified columns and rows. It provides various operations for
/// manipulating and querying the cards in the hand.
class HandModel {
  /// Grid checking indices for 2x2 layout (rows and columns)
  static const List<List<int>> _checkingIndices2x2 = [
    [0, 1], // Row 1
    [2, 3], // Row 2
    [0, 2], // Column 1
    [1, 3], // Column 2
  ];

  /// Grid checking indices for 3x3 layout (rows and columns)
  static const List<List<int>> _checkingIndices3x3 = [
    [0, 1, 2], // Row 1
    [3, 4, 5], // Row 2
    [6, 7, 8], // Row 3
    [0, 3, 6], // Column 1
    [1, 4, 7], // Column 2
    [2, 5, 8], // Column 3
  ];

  /// Creates a new [HandModel] with the specified dimensions and initial cards.
  ///
  /// The [columns] and [rows] parameters define the grid layout of the hand.
  /// The [cards] parameter provides the initial list of cards to populate the hand.
  HandModel(this.columns, this.rows, final List<CardModel> cards) {
    _list.clear();
    _list.addAll(cards);
  }

  /// Whether the hand contains no cards.
  bool get isEmpty => _list.isEmpty;

  /// Whether the hand contains at least one card.
  bool get isNotEmpty => _list.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is HandModel &&
        other.columns == columns &&
        other.rows == rows &&
        _listEquals(other._list, _list);
  }

  /// Compares two lists of [CardModel] instances for equality.
  ///
  /// This private helper function checks if the two input lists have the same
  /// length and if all the corresponding elements in the lists are equal.
  /// It is used to implement the equality operator for the [HandModel] class.
  bool _listEquals(List<CardModel> a, List<CardModel> b) {
    if (a.length != b.length) {
      return false;
    }
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(columns, rows, Object.hashAll(_list));

  /// Assigns a [CardModel] to the [HandModel] at the specified [index].
  ///
  /// This operator allows you to set the card at the given index in the hand.
  /// It is used to update the contents of the hand.
  void operator []=(int index, CardModel card) {
    _list[index] = card;
  }

  /// The number of columns in the hand's grid layout.
  int columns = 0;

  /// The number of rows in the hand's grid layout.
  int rows = 0;

  /// The internal list storing the cards in the hand.
  final List<CardModel> _list = [];

  /// Returns the card at the specified index in the hand.
  CardModel operator [](int index) => _list[index];

  /// Returns the index of the specified [CardModel] in the hand.
  ///
  /// This method searches the list of cards in the hand and returns the index
  /// of the first occurrence of the specified [CardModel]. If the card is not
  /// found in the hand, -1 is returned.
  int indexOf(final CardModel card) {
    return _list.indexOf(card);
  }

  /// Returns the first card in the hand.
  CardModel get first => _list.first;

  /// Returns the last card in the hand.
  CardModel get last => _list.last;

  /// Checks if the given index is valid for this hand.
  ///
  /// Returns true if the index is within the bounds of the hand's card list.
  bool validIndex(int index) {
    return index >= 0 && index < _list.length;
  }

  /// Returns the number of cards in the hand.
  int get length => _list.length;

  /// Adds a card to the hand.
  ///
  /// The [card] parameter specifies the [CardModel] to be added.
  void add(final CardModel card) {
    _list.add(card);
  }

  /// Checks if all cards in the hand are revealed.
  ///
  /// Returns true if every card in the hand has its [isRevealed] property set to true.
  bool areAllCardsRevealed() {
    return _list.every((card) => card.isRevealed);
  }

  /// Reveals all cards in the hand.
  ///
  /// Sets the [isRevealed] property of each card to true.
  void revealAllCards() {
    for (final CardModel card in _list) {
      card.isRevealed = true;
    }
  }

  /// Removes and returns the card at the specified index.
  ///
  /// Returns the removed [CardModel].
  CardModel removeAt(int index) {
    return _list.removeAt(index);
  }

  @override
  String toString() {
    return '$columns X $rows [ ${_list.join('| ')} ]';
  }

  /// Calculates the sum of card values for the SkyJo game variant.
  ///
  /// Only considers revealed cards when calculating the sum.
  /// Returns the total score based on the values of revealed cards.
  int getSumOfCardsInHandSkyJo() {
    int score = 0;
    for (final CardModel card in _list) {
      if (card.isRevealed) {
        score += card.value;
      }
    }

    return score;
  }

  /// Calculates the sum of card values for the Golf game variant and related games.
  ///
  /// **Golf-Style Scoring Logic (PASSED SCORING)**:
  /// Unlike SkyJo which modifies hands during play, Golf games calculate scores
  /// passively based on the final revealed card layout after all play is complete.
  ///
  /// **Scoring Rules:**
  /// - Revealed cards are scored based on their face values
  /// - Cards that match in rank (same number/symbol) don't count toward the score
  ///   - In 3x3 grids: matches can be horizonal (rows) or vertical (columns)
  ///   - In 2x2 grids: matches can be pairs in rows or columns
  /// - Only the unmatched revealed cards contribute to the final score
  ///
  /// **Used By:**
  /// - French Cards (3x3 grid)
  /// - MiniPut (2x2 grid)
  /// - Any other Golf-style variant games
  ///
  /// **Called From UI:** When displaying final scores to players
  ///
  /// @return The total score (sum of values of scoring cards)
  int getSumOfCardsForGolf() {
    int score = 0;

    final List<List<int>> checkingIndices =
        _list.length == CardModel.golfGrid2x2Size
        ? _checkingIndices2x2 // 2x2
        : _checkingIndices3x3; // 3x3

    for (final List<int> indices in checkingIndices) {
      markIfSameRankForGolf(indices);
    }

    for (final CardModel card in _list) {
      if (card.isRevealed && card.partOfSet == false) {
        score += card.value;
      }
    }

    return score;
  }

  /// Marks cards of the same rank as part of a set for Golf scoring.
  ///
  /// Takes a list of boolean flags [markedForZeroScore] to track which cards have been marked,
  /// and a list of [indices] specifying which card positions to check.
  ///
  /// For 2 or 3 indices:
  /// - Checks if cards at specified positions have matching ranks
  /// - If they match, aren't already part of a set, and are revealed, marks them as part of a set
  /// - Cards with rank '§' are excluded from being marked as part of a set
  void markIfSameRankForGolf(List<int> indices) {
    // Validate all cards are revealed and not already part of a set
    final bool allCardsValid = indices.every(
      (index) => _list[index].isRevealed && !_list[index].partOfSet,
    );

    if (!allCardsValid) {
      return;
    }
    const cardInxexFirst = 0;
    const cardInxexSecond = 1;
    const cardInxexThird = 2;

    // Check if all cards have matching ranks
    final bool haveSameRank = indices.length == CardModel.twoCardMatchSize
        ? _list[indices[cardInxexFirst]].rank ==
              _list[indices[cardInxexSecond]].rank
        : _list[indices[cardInxexFirst]].rank ==
                  _list[indices[cardInxexSecond]].rank &&
              _list[indices[cardInxexSecond]].rank ==
                  _list[indices[cardInxexThird]].rank;

    if (haveSameRank) {
      // Mark matching cards as part of set if not special rank
      for (final int index in indices) {
        if (_list[index].rank != '§') {
          _list[index].partOfSet = true;
        }
      }
    }
  }

  /// Reveals a specified number of random cards in the hand.
  ///
  /// [numberOfCardsToReveal] specifies how many cards should be revealed.
  void revealCards(int numberOfCardsToReveal) {
    final Random random = Random();
    final List<int> indices = List.generate(_list.length, (i) => i)
      ..shuffle(random);
    for (int i = 0; i < numberOfCardsToReveal; i++) {
      _list[indices[i]].isRevealed = true;
    }
  }

  /// Converts the hand to a JSON-serializable format.
  ///
  /// Returns a list of JSON representations of the cards in the hand.
  List<dynamic> toJson() {
    return _list.map((CardModel card) => card.toJson()).toList();
  }
}
