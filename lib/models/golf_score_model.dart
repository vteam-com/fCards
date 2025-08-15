// ignore: sort_constructors_first
/// Represents the score data for a 9 Cards Golf game.
class GolfScoreModel {
  // ignore: sort_constructors_first
  /// Creates a [GolfScoreModel] instance.
  GolfScoreModel({
    required this.playerNames,
    List<List<int>>? scores,
  }) : scores = scores ?? [] {
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
    scores.add(List<int>.filled(playerNames.length, 0));
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
  void updateScore(int roundIndex, int playerIndex, int score) {
    if (roundIndex < scores.length && playerIndex < scores[roundIndex].length) {
      scores[roundIndex][playerIndex] = score;
    }
  }

  /// Clears all scores and player names from the model.
  void clear() {
    playerNames.clear();
    scores.clear();
  }

  /// Removes a round at the specified index.
  ///
  /// [roundIndex] The index of the round to remove.
  void removeRoundAt(int roundIndex) {
    if (roundIndex >= 0 && roundIndex < scores.length) {
      scores.removeAt(roundIndex);
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
    }
  }

  /// Checks if the last round is empty (all scores are 0).
  bool isLastRoundEmpty() {
    if (scores.isEmpty) {
      return true;
    }
    final lastRound = scores.last;
    return lastRound.every((score) => score == 0);
  }

  /// Adds a new player to the game.
  ///
  /// [playerName] The name of the player to add.
  void addPlayer(String playerName) {
    playerNames.add(playerName);
    for (var roundScores in scores) {
      roundScores.add(0);
    }
  }

  /// Gets the rank of each player based on their total score.
  ///
  /// Returns a list of integers representing the rank of each player.
  /// The player with the lowest score gets rank 1.
  /// Players with the same score get the same rank.
  List<int> getPlayerRanks() {
    final List<int> totalScores = List.generate(
      playerNames.length,
      (index) => getPlayerTotalScore(index),
    );

    final List<int> sortedScores = List.from(totalScores)..sort();
    final List<int> ranks = List.filled(playerNames.length, 0);

    for (int i = 0; i < playerNames.length; i++) {
      ranks[i] = sortedScores.indexOf(totalScores[i]) + 1;
    }

    return ranks;
  }
}
