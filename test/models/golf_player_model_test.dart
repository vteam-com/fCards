import 'package:cards/models/base/player_model.dart';
import 'package:cards/models/golf/golf_french_suit_card_model.dart';
import 'package:cards/models/golf/golf_player_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayerModel', () {
    late PlayerModel player;

    setUp(() {
      player = GolfPlayerModel(name: 'Test Player');
    });

    test('reset clears hand', () {
      player.hand = [
        GolfFrenchSuitCardModel(suit: '♥️', rank: 'A'),
        GolfFrenchSuitCardModel(suit: '♦️', rank: '2'),
      ];
      player.reset();
      expect(player.hand, isEmpty);
    });

    test('addCardToHand adds card correctly', () {
      final card = GolfFrenchSuitCardModel(suit: '♥️', rank: 'A');
      player.addCardToHand(card);
      expect(player.hand.length, 1);
      expect(player.hand.first, card);
    });

    test('revealInitialCards reveals correct cards', () {
      for (int i = 0; i < 9; i++) {
        player.addCardToHand(GolfFrenchSuitCardModel(suit: '♥️', rank: 'A'));
      }
      player.revealInitialCards();
      expect(player.hand[3].isRevealed, true);
      expect(player.hand[5].isRevealed, true);
      expect(player.hand[0].isRevealed, false);
    });

    test('sumOfRevealedCards identifies vertical sets', () {
      player.addCardToHand(
        GolfFrenchSuitCardModel(suit: '♥️', rank: 'Q', isRevealed: true),
      );
      player.addCardToHand(GolfFrenchSuitCardModel(suit: '♦️', rank: '2'));
      player.addCardToHand(GolfFrenchSuitCardModel(suit: '♣️', rank: '3'));
      player.addCardToHand(
        GolfFrenchSuitCardModel(suit: '♠️', rank: 'Q', isRevealed: true),
      );
      player.addCardToHand(GolfFrenchSuitCardModel(suit: '♥️', rank: '5'));
      player.addCardToHand(GolfFrenchSuitCardModel(suit: '♦️', rank: '6'));
      player.addCardToHand(
        GolfFrenchSuitCardModel(suit: '♣️', rank: 'Q', isRevealed: true),
      );
      player.addCardToHand(GolfFrenchSuitCardModel(suit: '♠️', rank: '8'));
      player.addCardToHand(GolfFrenchSuitCardModel(suit: '♥️', rank: '9'));
      expect(player.sumOfRevealedCards, 0);
    });

    test('sumOfRevealedCards identifies vertical sets of Jokers', () {
      // 3 lined up Jokers shall not be Zero, we expect -6
      player.addCardToHand(
        GolfFrenchSuitCardModel(suit: '♥️', rank: '§', isRevealed: true),
      );
      player.addCardToHand(GolfFrenchSuitCardModel(suit: '♦️', rank: '2'));
      player.addCardToHand(GolfFrenchSuitCardModel(suit: '♣️', rank: '3'));
      player.addCardToHand(
        GolfFrenchSuitCardModel(suit: '♠️', rank: '§', isRevealed: true),
      );
      player.addCardToHand(GolfFrenchSuitCardModel(suit: '♥️', rank: '5'));
      player.addCardToHand(GolfFrenchSuitCardModel(suit: '♦️', rank: '6'));
      player.addCardToHand(
        GolfFrenchSuitCardModel(suit: '♣️', rank: '§', isRevealed: true),
      );
      player.addCardToHand(GolfFrenchSuitCardModel(suit: '♠️', rank: '8'));
      player.addCardToHand(GolfFrenchSuitCardModel(suit: '♥️', rank: '9'));
      expect(player.sumOfRevealedCards, -6);
    });

    test('toJson creates correct json representation', () {
      player.addCardToHand(
        GolfFrenchSuitCardModel(suit: '♥️', rank: 'A', isRevealed: true),
      );
      player.addCardToHand(GolfFrenchSuitCardModel(suit: '♦️', rank: '2'));

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
          {'suit': '♥️', 'rank': 'A', 'isRevealed': true},
          {'suit': '♦️', 'rank': '2'},
        ],
      };

      final playerFromJson = PlayerModel.fromJson(json);

      expect(playerFromJson.name, 'Test Player');
      expect(playerFromJson.hand.length, 2);
      expect(playerFromJson.hand[0].suit, '♥️');
      expect(playerFromJson.hand[0].rank, 'A');
      expect(playerFromJson.hand[0].isRevealed, true);
    });
  });
}
