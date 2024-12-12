import 'package:cards/models/base/card_model.dart';
export 'package:cards/models/base/card_model.dart';

class HandModel {
  HandModel(this.columns, this.rows, final List<CardModel> cards) {
    _list.clear();
    _list.addAll(cards);
  }

  bool get isEmpty => _list.isEmpty;
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

  // number of columns
  int columns = 0;

  // rows
  int rows = 0;

  // list of card in the hand
  final List<CardModel> _list = [];

  // operator to get card at index
  CardModel operator [](int index) => _list[index];

  /// Returns the index of the specified [CardModel] in the hand.
  ///
  /// This method searches the list of cards in the hand and returns the index
  /// of the first occurrence of the specified [CardModel]. If the card is not
  /// found in the hand, -1 is returned.
  int indexOf(final CardModel card) {
    return _list.indexOf(card);
  }

  CardModel get first => _list.first;
  CardModel get last => _list.last;

  bool validIndex(int index) {
    return index >= 0 && index < _list.length;
  }

  int get length => _list.length;

  void add(final CardModel card) {
    _list.add(card);
  }

  bool areAllCardsRevealed() {
    return _list.every((card) => card.isRevealed);
  }

  void revealAllCards() {
    for (final CardModel card in _list) {
      card.isRevealed = true;
    }
  }

  CardModel removeAt(int index) {
    return _list.removeAt(index);
  }

  @override
  String toString() {
    return '$columns X $rows [ ${_list.join('| ')} ]';
  }

  List<CardModel> get revealedCards {
    return _list.where((card) => card.isRevealed).toList();
  }

  int getSumOfCardsInHandSkyJo() {
    int score = 0;
    for (final CardModel card in _list) {
      if (card.isRevealed) {
        score += card.value;
      }
    }

    return score;
  }

  int getSumOfCardsForGolf() {
    int score = 0;
    List<bool> markedForZeroScore = List.filled(_list.length, false);

    List<List<int>> checkingIndices = [
      [0, 1, 2],
      [3, 4, 5],
      [6, 7, 8],
      [0, 3, 6],
      [1, 4, 7],
      [2, 5, 8],
      // [0, 4, 8], // Diagonal from top-left to bottom-right
      // [2, 4, 6], // Diagonal from top-right to bottom-left
    ];

    for (final List<int> indices in checkingIndices) {
      markIfSameRankForGolf(markedForZeroScore, indices);
    }

    for (final CardModel card in _list) {
      if (card.isRevealed && card.partOfSet == false) {
        score += card.value;
      }
    }

    return score;
  }

  void markIfSameRankForGolf(
    List<bool> markedForZeroScore,
    List<int> indices,
  ) {
    if (indices.length == 3 &&
        areAllTheSameRankAndNotAlreadyUsed(
          _list[indices[0]],
          _list[indices[1]],
          _list[indices[2]],
        )) {
      for (final int index in indices) {
        if (_list[index].rank != '§') {
          _list[index].partOfSet = true;
        }
      }
    }
  }

  bool areAllTheSameRankAndNotAlreadyUsed(
    CardModel card1,
    CardModel card2,
    CardModel card3,
  ) {
    return !(card1.partOfSet || card2.partOfSet || card3.partOfSet) &&
        areAllTheSameRank(card1.rank, card2.rank, card3.rank);
  }

  bool areAllTheSameRank(String rank1, String rank2, String rank3) {
    return rank1 == rank2 && rank2 == rank3;
  }

  List<dynamic> toJson() {
    return _list.map((CardModel card) => card.toJson()).toList();
  }
}
