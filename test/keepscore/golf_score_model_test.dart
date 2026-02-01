import 'package:cards/models/game/golf_score_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GolfScoreModel', () {
    late GolfScoreModel scoreModel;

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      scoreModel = GolfScoreModel(playerNames: ['Alice', 'Bob', 'Charlie']);
    });

    test('should initialize with empty scores and one round', () {
      expect(scoreModel.playerNames, ['Alice', 'Bob', 'Charlie']);
      expect(scoreModel.scores.length, 1);
      expect(scoreModel.scores[0], [0, 0, 0]);
    });

    test('should initialize with provided scores', () {
      final model = GolfScoreModel(
        playerNames: ['Player1', 'Player2'],
        scores: [
          [10, 15],
          [20, 25],
        ],
      );
      expect(model.playerNames, ['Player1', 'Player2']);
      expect(model.scores, [
        [10, 15],
        [20, 25],
      ]);
    });

    test('should add new round with zeros', () {
      scoreModel.addRound();
      expect(scoreModel.scores.length, 2);
      expect(scoreModel.scores[1], [0, 0, 0]);
    });

    test('should calculate player total score correctly', () {
      scoreModel.updateScore(0, 0, 10);
      scoreModel.updateScore(0, 1, 15);
      scoreModel.addRound();
      scoreModel.updateScore(1, 0, 20);
      scoreModel.updateScore(1, 1, 25);

      expect(scoreModel.getPlayerTotalScore(0), 30); // 10 + 20
      expect(scoreModel.getPlayerTotalScore(1), 40); // 15 + 25
      expect(scoreModel.getPlayerTotalScore(2), 0); // 0 + 0
    });

    test('should update score for specific player and round', () {
      scoreModel.updateScore(0, 1, 25);
      expect(scoreModel.scores[0][1], 25);
    });

    test('should handle invalid score update indices gracefully', () {
      // Should not crash with invalid indices
      scoreModel.updateScore(99, 0, 10);
      scoreModel.updateScore(0, 99, 10);
      expect(scoreModel.scores[0][0], equals(0)); // Should remain unchanged
    });

    test('should clear scores and reset to one round', () {
      scoreModel.updateScore(0, 0, 10);
      scoreModel.addRound();
      scoreModel.updateScore(1, 0, 20);

      scoreModel.clearScores();

      expect(scoreModel.scores.length, equals(1));
      expect(scoreModel.scores[0], equals([0, 0, 0]));
    });

    test('should clear players and scores', () {
      scoreModel.clearPlayers();

      expect(scoreModel.playerNames.isEmpty, isTrue);
      expect(scoreModel.scores.length, equals(1));
      expect(
        scoreModel.scores[0],
        equals([0, 0, 0]),
      ); // After clearPlayers, addRound is called
    });

    test('should remove round at specific index', () {
      scoreModel.addRound();
      scoreModel.updateScore(0, 0, 10);
      scoreModel.updateScore(1, 0, 20);

      scoreModel.removeRoundAt(0);

      expect(scoreModel.scores.length, equals(1));
      expect(scoreModel.scores[0][0], equals(20));
    });

    test('should handle invalid round removal', () {
      scoreModel.addRound();
      final originalLength = scoreModel.scores.length;

      scoreModel.removeRoundAt(-1);
      scoreModel.removeRoundAt(99);

      expect(scoreModel.scores.length, equals(originalLength));
    });

    test('should remove player at specific index', () {
      scoreModel.removePlayerAt(1);

      expect(scoreModel.playerNames, equals(['Alice', 'Charlie']));
      expect(scoreModel.scores[0], equals([0, 0]));
    });

    test('should remove player by name', () {
      scoreModel.removePlayer('Bob');

      expect(scoreModel.playerNames, equals(['Alice', 'Charlie']));
      expect(scoreModel.scores[0], equals([0, 0]));
    });

    test('should handle removing non-existent player', () {
      final originalLength = scoreModel.playerNames.length;

      scoreModel.removePlayer('NonExistent');

      expect(scoreModel.playerNames.length, equals(originalLength));
    });

    test('should add new player', () {
      scoreModel.addPlayer('David');

      expect(
        scoreModel.playerNames,
        equals(['Alice', 'Bob', 'Charlie', 'David']),
      );
      expect(scoreModel.scores[0], equals([0, 0, 0, 0]));
    });

    test('should add player to existing rounds', () {
      scoreModel.addRound();
      scoreModel.addPlayer('David');

      expect(
        scoreModel.playerNames,
        equals(['Alice', 'Bob', 'Charlie', 'David']),
      );
      expect(scoreModel.scores[0], equals([0, 0, 0, 0]));
      expect(scoreModel.scores[1], equals([0, 0, 0, 0]));
    });

    test('should check if last round is empty', () {
      expect(
        scoreModel.isLastRoundEmpty(),
        false,
      ); // Always returns false per implementation

      scoreModel.updateScore(0, 0, 10);
      expect(scoreModel.isLastRoundEmpty(), false);
    });

    test('should calculate player ranks correctly', () {
      // Set up scores: Alice=30, Bob=20, Charlie=40
      scoreModel.updateScore(0, 0, 30);
      scoreModel.updateScore(0, 1, 20);
      scoreModel.updateScore(0, 2, 40);

      final ranks = scoreModel.getPlayerRanks();

      expect(ranks[1], equals(1)); // Bob (20) - rank 1 (lowest score)
      expect(ranks[0], equals(2)); // Alice (30) - rank 2
      expect(ranks[2], equals(3)); // Charlie (40) - rank 3
    });

    test('should handle tied scores in ranking', () {
      // Set up scores: Alice=20, Bob=20, Charlie=30
      scoreModel.updateScore(0, 0, 20);
      scoreModel.updateScore(0, 1, 20);
      scoreModel.updateScore(0, 2, 30);

      final ranks = scoreModel.getPlayerRanks();

      expect(ranks[0], equals(1)); // Alice (20) - rank 1
      expect(ranks[1], equals(1)); // Bob (20) - rank 1 (tied)
      expect(ranks[2], equals(3)); // Charlie (30) - rank 3
    });

    test('should handle empty player list in ranking', () {
      final emptyModel = GolfScoreModel(playerNames: []);
      final ranks = emptyModel.getPlayerRanks();

      expect(ranks, equals([]));
    });

    group('Persistence', () {
      setUp(() async {
        // Set up mock SharedPreferences for each test
        SharedPreferences.setMockInitialValues({});
      });

      test('should save and load data correctly', () async {
        // Set up test data
        scoreModel.updateScore(0, 0, 10);
        scoreModel.updateScore(0, 1, 15);
        scoreModel.addRound();
        scoreModel.updateScore(1, 0, 20);
        scoreModel.addPlayer('David');

        // Create new instance from saved data
        final loadedModel = await GolfScoreModel.load();

        expect(
          loadedModel.playerNames,
          equals(['Alice', 'Bob', 'Charlie', 'David']),
        );
        expect(loadedModel.scores.length, equals(2));
        expect(loadedModel.scores[0], equals([10, 15, 0, 0]));
        expect(loadedModel.scores[1], equals([20, 0, 0, 0]));
      });

      test('should load default data when no saved data exists', () async {
        // Clear the existing model first
        SharedPreferences.setMockInitialValues({});
        final loadedModel = await GolfScoreModel.load();

        expect(
          loadedModel.playerNames,
          equals(['Player1', 'Player2', 'Player3', 'Player4']),
        );
        expect(loadedModel.scores.length, equals(1));
        expect(loadedModel.scores[0], equals([0, 0, 0, 0]));
      });

      test('should handle corrupted saved data gracefully', () async {
        // Set up corrupted data
        SharedPreferences.setMockInitialValues({
          'playerNames': 'invalid json',
          'scores': 'also invalid',
        });

        final loadedModel = await GolfScoreModel.load();

        expect(
          loadedModel.playerNames,
          equals(['Player1', 'Player2', 'Player3', 'Player4']),
        );
        expect(loadedModel.scores.length, equals(1));
        expect(loadedModel.scores[0], equals([0, 0, 0, 0]));
      });
    });

    group('Edge Cases', () {
      test('should handle single player', () {
        final singlePlayerModel = GolfScoreModel(playerNames: ['Solo']);
        singlePlayerModel.updateScore(0, 0, 25);

        expect(singlePlayerModel.getPlayerTotalScore(0), equals(25));
        expect(singlePlayerModel.getPlayerRanks(), equals([1]));
      });

      test('should handle large number of rounds', () {
        for (int i = 0; i < 100; i++) {
          scoreModel.addRound();
          scoreModel.updateScore(i, 0, i);
        }

        expect(scoreModel.scores.length, equals(101));
        expect(
          scoreModel.getPlayerTotalScore(0),
          equals(4950),
        ); // Sum of 0 to 99
      });

      test('should handle negative scores', () {
        scoreModel.updateScore(0, 0, -10);
        scoreModel.updateScore(0, 1, -5);

        expect(scoreModel.getPlayerTotalScore(0), equals(-10));
        expect(scoreModel.getPlayerTotalScore(1), equals(-5));
      });

      test('should handle very large scores', () {
        const largeScore = 999999;
        scoreModel.updateScore(0, 0, largeScore);

        expect(scoreModel.getPlayerTotalScore(0), equals(largeScore));
      });
    });
  });
}
