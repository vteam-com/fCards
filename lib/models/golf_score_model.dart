import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// ignore: sort_constructors_first
/// Represents the score data for a 9 Cards Golf game.
class GolfScoreModel {
  // ignore: sort_constructors_first
  /// Creates a [GolfScoreModel] instance.
  GolfScoreModel({required this.playerNames, List<List<int>>? scores})
    : scores = scores ?? [] {
    if (this.scores.isEmpty) {
      addRound();
    }
  }

  /// The names of the players in the game.
  List<String> playerNames;

  /// A list of lists, where each inner list represents a round
  /// and contains the scores for each player in that round.
  List<List<int>> scores;

  /// Adds a new round to the game with initial scores (e.g., all zeros).
  void addRound() {
    scores.add(List.filled(playerNames.length, 0, growable: true));
    _save();
  }

  /// Gets the total score for a specific player.
  ///
  /// [playerIndex] The index of the player.
  /// Returns the total score for the player.
  int getPlayerTotalScore(int playerIndex) {
    int total = 0;
    for (var roundScores in scores) {
      if (playerIndex < roundScores.length) {
        total += roundScores[playerIndex];
      }
    }
    return total;
  }

  /// Updates the score for a specific player in a specific round.
  ///
  /// [roundIndex] The index of the round.
  /// [playerIndex] The index of the player.
  /// [score] The new score for the player in that round.
  void updateScore(
    final int roundIndex,
    final int playerIndex,
    final int score,
  ) {
    if (roundIndex < scores.length && playerIndex < scores[roundIndex].length) {
      scores[roundIndex][playerIndex] = score;
      _save();
    }
  }

  /// Clears all scores and player names from the model.
  void clearScores() {
    scores.clear();
    addRound();
    _save();
  }

  /// Clears all scores and player names from the model.
  void clearPlayers() {
    clearScores();
    playerNames.clear();
    _save();
  }

  /// Removes a round at the specified index.
  ///
  /// [roundIndex] The index of the round to remove.
  void removeRoundAt(int roundIndex) {
    if (roundIndex >= 0 && roundIndex < scores.length) {
      scores.removeAt(roundIndex);
      _save();
    }
  }

  /// Removes a player at the specified index.
  ///
  /// [playerIndex] The index of the player to remove.
  void removePlayerAt(int playerIndex) {
    if (playerIndex >= 0 && playerIndex < playerNames.length) {
      playerNames.removeAt(playerIndex);
      for (var roundScores in scores) {
        if (playerIndex < roundScores.length) {
          roundScores.removeAt(playerIndex);
        }
      }
      _save();
    }
  }

  /// Removes a player from the game by name.
  ///
  /// [playerName] The name of the player to remove.
  void removePlayer(String playerName) {
    final int index = playerNames.indexOf(playerName);
    if (index != -1) {
      removePlayerAt(index);
    }
  }

  /// Checks if the last round is empty (all scores are 0).
  bool isLastRoundEmpty() {
    if (scores.isEmpty) {
      return true;
    }
    // We can automated adding new row if needed
    // final lastRound = scores.last;
    // return lastRound.every((score) => score == 0);
    return false;
  }

  /// Adds a new player to the game.
  ///
  /// [playerName] The name of the player to add.
  void addPlayer(String playerName) {
    playerNames.add(playerName);
    for (int i = 0; i < scores.length; i++) {
      final List<int> newRound = List<int>.from(scores[i], growable: true)
        ..add(0);
      scores[i] = newRound;
    }
    _save();
  }

  /// Gets the rank of each player based on their total score.
  ///
  /// Returns a list of integers representing the rank of each player.
  /// The player with the lowest score gets rank 1.
  /// Players with the same score get the same rank.
  List<int> getPlayerRanks() {
    if (playerNames.isEmpty) {
      return [];
    }
    final List<int> totalScores = List.generate(
      playerNames.length,
      (index) => getPlayerTotalScore(index),
    );

    final List<MapEntry<int, int>> indexedScores = totalScores
        .asMap()
        .entries
        .map((entry) => MapEntry(entry.key, entry.value))
        .toList();

    indexedScores.sort((a, b) => a.value.compareTo(b.value));

    final List<int> ranks = List.filled(playerNames.length, 0);
    for (int i = 0; i < indexedScores.length; i++) {
      final int rank = i + 1;
      final int originalIndex = indexedScores[i].key;
      if (i > 0 && indexedScores[i].value == indexedScores[i - 1].value) {
        ranks[originalIndex] = ranks[indexedScores[i - 1].key];
      } else {
        ranks[originalIndex] = rank;
      }
    }
    return ranks;
  }

  ///
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('playerNames', jsonEncode(playerNames));
    prefs.setString('scores', jsonEncode(scores));
  }

  ///
  static Future<GolfScoreModel> load() async {
    final prefs = await SharedPreferences.getInstance();
    final playerNamesJson = prefs.getString('playerNames');
    final scoresJson = prefs.getString('scores');

    if (playerNamesJson != null && scoresJson != null) {
      final playerNames = (jsonDecode(playerNamesJson) as List).cast<String>();
      final scores = (jsonDecode(scoresJson) as List)
          .map((list) => (list as List).cast<int>())
          .toList();
      return GolfScoreModel(playerNames: playerNames, scores: scores);
    } else {
      return GolfScoreModel(
        playerNames: ['Player1', 'Player2', 'Player3', 'Player4'],
      );
    }
  }
}
