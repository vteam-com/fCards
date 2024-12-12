import 'dart:math';

import 'package:cards/models/base/game_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../golf_game_model_test.dart';

void main() {
  group(
    'SkyjoGameModel',
    () {
      late GameModel gameModel;
      late MockBuildContext mockContext; // Instance of the mock
      late Random random;

      setUp(
        () {
          random = Random();
          mockContext = MockBuildContext();
          gameModel = GameModel(
            gameMode: gameModeSkyJo,
            roomName: 'testRoom',
            roomHistory: [],
            loginUserName: 'Player 1',
            names: ['Player 1', 'Player 2'],
            cardsToDeal: 12,
            deck: DeckModel(numberOfDecks: 1, gameMode: gameModeSkyJo),
            isNewGame: true,
          );
        },
      );
      test(
        'column should be removed if all cards match',
        () {
          gameModel.players[0].hand = HandModel(4, 3, []);
          gameModel.players[1].hand = HandModel(4, 3, []);
          // Add 3 of the same card
          for (int i = 0; i < 3; i++) {
            gameModel.players[0].hand.add(
              CardModel(suit: '', rank: '10', value: 10, isRevealed: true),
            );
          }
          for (int i = 0; i < 9; i++) {
            gameModel.players[0].hand.add(
              CardModel(
                suit: '',
                rank: (random.nextInt(14) - 2).toString(),
                value: i,
              ),
            );
          }
          for (int i = 0; i < 12; i++) {
            gameModel.players[1].hand.add(
              CardModel(
                suit: '',
                rank: (random.nextInt(14) - 2).toString(),
                value: i,
              ),
            );
          }

          expect(gameModel.players[0].hand.length, 12);
          gameModel.moveToNextPlayer(mockContext);
          gameModel.moveToNextPlayer(mockContext);
          expect(gameModel.players[0].hand.length, 9);
        },
      );
      test(
        'column should be removed if this is the last turn',
        () {
          gameModel.players[0].hand = HandModel(4, 3, []);
          gameModel.players[1].hand = HandModel(4, 3, []);
          // Add 3 of the same card
          for (int i = 0; i < 3; i++) {
            gameModel.players[0].hand
                .add(CardModel(suit: '', rank: '10', value: 10));
          }
          for (int i = 0; i < 9; i++) {
            gameModel.players[0].hand.add(
              CardModel(
                suit: '',
                rank: (random.nextInt(14) - 2).toString(),
                value: i,
              ),
            );
          }
          // Set the 2nd player hand to be fully revealed
          for (int i = 0; i < 12; i++) {
            var rank = (random.nextInt(14) - 2);
            gameModel.players[1].hand.add(
              CardModel(
                suit: '',
                rank: rank.toString(),
                value: rank,
                isRevealed: true,
              ),
            );
          }

          gameModel.playerIdPlaying = 1;

          expect(gameModel.players[0].hand.length, 12);
          // This should trigger the last turn and open all the cards.
          gameModel.moveToNextPlayer(mockContext);
          gameModel.moveToNextPlayer(mockContext);

          expect(gameModel.players[0].hand.length, 9);
        },
      );
    },
  );
}
