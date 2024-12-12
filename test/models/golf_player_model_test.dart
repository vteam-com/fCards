import 'package:cards/models/player_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerModel', () {
    late PlayerModel player;

    setUp(() {
      player = PlayerModel(
        name: 'Test Player',
        columns: 3,
        rows: 3,
        skyJoLogic: false,
      );
    });

    test('reset clears hand', () {
      player.hand = HandModel(2, 1, [
        CardModel(suit: '♥️', rank: 'A', value: 1),
        CardModel(suit: '♦️', rank: '2', value: 2),
      ]);

      player.clear();
      expect(player.hand.isEmpty, true);
    });

    test('addCardToHand adds card correctly', () {
      final card = CardModel(suit: '♥️', rank: 'A', value: 1);
      player.addCardToHand(card);
      expect(player.hand.length, 1);
      expect(player.hand.first, card);
    });

    test('revealInitialCards reveals correct cards', () {
      for (int i = 0; i < 9; i++) {
        player.addCardToHand(
          CardModel(suit: '♥️', rank: 'A', value: 1),
        );
      }
      player.revealInitialCards();
      expect(player.hand[3].isRevealed, true);
      expect(player.hand[5].isRevealed, true);
      expect(player.hand[0].isRevealed, false);
    });

    test('sumOfRevealedCards identifies vertical sets', () {
      player.hand = HandModel(3, 3, []);
      player.addCardToHand(
        CardModel(
          suit: '♥️',
          rank: 'Q',
          value: 12,
          isRevealed: true,
        ),
      );
      player.addCardToHand(
        CardModel(suit: '♦️', rank: '2', value: 2),
      );
      player.addCardToHand(
        CardModel(suit: '♣️', rank: '3', value: 3),
      );
      player.addCardToHand(
        CardModel(
          suit: '♠️',
          rank: 'Q',
          value: 12,
          isRevealed: true,
        ),
      );
      player.addCardToHand(
        CardModel(suit: '♥️', rank: '5', value: 5),
      );
      player.addCardToHand(
        CardModel(suit: '♦️', rank: '6', value: 6),
      );
      player.addCardToHand(
        CardModel(
          suit: '♣️',
          rank: 'Q',
          value: 12,
          isRevealed: true,
        ),
      );
      player.addCardToHand(
        CardModel(suit: '♠️', rank: '8', value: 8),
      );
      player.addCardToHand(
        CardModel(suit: '♥️', rank: '9', value: 9),
      );
      expect(player.sumOfRevealedCards, 0);
    });

    test('sumOfRevealedCards identifies vertical sets of Jokers', () {
      // 3 lined up Jokers shall not be Zero, we expect -6
      player.addCardToHand(
        CardModel(
          suit: '♥️',
          rank: '§',
          value: -2,
          isRevealed: true,
        ),
      );
      player.addCardToHand(
        CardModel(suit: '♦️', rank: '2', value: 2),
      );
      player.addCardToHand(
        CardModel(suit: '♣️', rank: '3', value: 3),
      );
      player.addCardToHand(
        CardModel(
          suit: '♠️',
          rank: '§',
          value: -2,
          isRevealed: true,
        ),
      );
      player.addCardToHand(
        CardModel(suit: '♥️', rank: '5', value: 5),
      );
      player.addCardToHand(
        CardModel(suit: '♦️', rank: '6', value: 6),
      );
      player.addCardToHand(
        CardModel(
          suit: '♣️',
          rank: '§',
          value: -2,
          isRevealed: true,
        ),
      );
      player.addCardToHand(
        CardModel(suit: '♠️', rank: '8', value: 8),
      );
      player.addCardToHand(
        CardModel(suit: '♥️', rank: '9', value: 9),
      );
      expect(player.sumOfRevealedCards, -6);
    });

    test('toJson creates correct json representation', () {
      player.addCardToHand(
        CardModel(
          suit: '♥️',
          rank: 'A',
          value: 1,
          isRevealed: true,
        ),
      );
      player.addCardToHand(
        CardModel(suit: '♦️', rank: '2', value: 2),
      );

      final json = player.toJson();

      expect(json['name'], 'Test Player');
      expect(json['hand'], isA<List>());
      expect(json['hand'].length, 2);
      expect(json['hand'][0]['suit'], '♥️');
      expect(json['hand'][0]['rank'], 'A');
      expect(json['hand'][0]['isRevealed'], true);
    });

    test('fromJson creates correct player model', () {
      final json = {
        'name': 'Test Player',
        'hand': [
          {'suit': '♥️', 'rank': 'A', 'value': 1, 'isRevealed': true},
          {'suit': '♦️', 'rank': '2', 'value': 2},
        ],
      };

      final PlayerModel playerFromJson = PlayerModel.fromJson(
        json: json,
        columns: 3,
        rows: 3,
        skyJoLogic: false,
      );

      expect(playerFromJson.name, 'Test Player');
      expect(playerFromJson.hand.length, 2);
      expect(playerFromJson.hand[0].suit, '♥️');
      expect(playerFromJson.hand[0].rank, 'A');
      expect(playerFromJson.hand[0].isRevealed, true);
    });
  });
}
