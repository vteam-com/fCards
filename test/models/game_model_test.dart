import 'package:cards/models/game_history.dart';
import 'package:cards/models/game_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GameModel gameModel;
  final testPlayers = [
    'Player1',
    'Player2',
  ];

  setUp(() {
    gameModel = GameModel(
      gameMode: 'skyjo',
      roomName: 'testRoom',
      roomHistory: [],
      loginUserName: 'Player1',
      names: testPlayers,
      cardsToDeal: 9,
      deck: DeckModel(numberOfDecks: 1, gameMode: 'skyjo'),
      isNewGame: true,
    );
  });

  group('GameModel Initialization', () {
    test('should initialize with correct number of players', () {
      expect(gameModel.players.length, equals(2));
      expect(gameModel.getPlayersNames(), equals(testPlayers));
    });

    test('should start with correct game state', () {
      expect(gameModel.gameState, equals(GameStates.pickCardFromEitherPiles));
    });

    test('should deal correct number of cards to players', () {
      for (var player in gameModel.players) {
        expect(player.hand.length, equals(9));
      }
    });
  });

  group('Game State Management', () {
    test('should properly track active player', () {
      expect(gameModel.playerIdPlaying, equals(0));
      gameModel.setActivePlayer(1);
      expect(gameModel.playerIdPlaying, equals(1));

      final win1 = GameHistory.fromJson({
        'date': DateTime.now(),
        'playersNames': ['Player1'],
      });
      gameModel.roomHistory.add(win1);
      final List<DateTime> wins = gameModel.getWinsForPlayerName('Player1');
      expect(wins.length, 1);
    });

    test('should correctly identify final turn state', () {
      expect(gameModel.isFinalTurn, isFalse);
      gameModel.playerIdAttacking = 1;
      expect(gameModel.isFinalTurn, isTrue);
    });
  });

  group('Card Operations', () {
    test('should handle card revelation', () {
      final player = gameModel.players[0];
      final hiddenCard = player.hand.revealedCards.first;
      final cardIndex = player.hand.indexOf(hiddenCard);

      gameModel.gameState = GameStates.revealOneHiddenCard;
      gameModel.handleFlipOneCardState(player, cardIndex);

      expect(player.hand[cardIndex].isRevealed, isTrue);
    });
  });

  group('JSON Serialization', () {
    test('should correctly serialize to JSON', () {
      final json = gameModel.toJson();

      expect(json['players'], isNotNull);
      expect(json['deck'], isNotNull);
      expect(json['playerIdPlaying'], equals(gameModel.playerIdPlaying));
      expect(json['state'], equals(gameModel.gameState.toString()));
    });

    test('should correctly deserialize from JSON', () {
      final newGameModel = GameModel(
        gameMode: 'skyjo',
        roomName: 'testRoom',
        roomHistory: [],
        loginUserName: 'Player1',
        names: testPlayers,
        cardsToDeal: 9,
        deck: DeckModel(numberOfDecks: 1, gameMode: 'skyjo'),
      );

      newGameModel.fromJson({
        'deck': {
          'cardsDeckDiscarded': [
            {
              'rank': 'K',
              'suit': '♥️',
              'value': 0,
            },
            {
              'rank': '7',
              'suit': '♣️',
            },
            {
              'rank': '5',
              'suit': '♠️',
            },
            {
              'rank': '4',
              'suit': '♦️',
            },
            {
              'rank': '6',
              'suit': '♦️',
            },
            {
              'rank': '7',
              'suit': '♦️',
            },
            {
              'rank': 'J',
              'suit': '♦️',
              'value': 11,
            },
            {
              'rank': 'Q',
              'suit': '♠️',
              'value': 12,
            },
            {
              'rank': '9',
              'suit': '♥️',
            },
            {
              'rank': '9',
              'suit': '♦️',
            },
            {
              'isRevealed': true,
              'rank': '3',
              'suit': '♠️',
            },
            {
              'isRevealed': true,
              'rank': '5',
              'suit': '♦️',
            }
          ],
          'cardsDeckPile': [
            {
              'rank': 'K',
              'suit': '♦️',
              'value': 0,
            },
            {
              'rank': 'X',
              'suit': '♣️',
              'value': 10,
            },
            {
              'rank': '3',
              'suit': '♥️',
            },
            {
              'rank': '7',
              'suit': '♥️',
            },
            {
              'rank': '2',
              'suit': '♣️',
            },
            {
              'rank': '3',
              'suit': '♦️',
            },
            {
              'rank': 'A',
              'suit': '♦️',
              'value': 1,
            },
            {
              'rank': 'J',
              'suit': '♣️',
              'value': 11,
            },
            {
              'rank': '2',
              'suit': '♥️',
            },
            {
              'rank': '5',
              'suit': '♥️',
            },
            {
              'rank': 'A',
              'suit': '♥️',
              'value': 1,
            },
            {
              'rank': '4',
              'suit': '♠️',
            },
            {
              'rank': 'Q',
              'suit': '♣️',
              'value': 12,
            },
            {
              'rank': '2',
              'suit': '♦️',
            },
            {
              'rank': 'J',
              'suit': '♠️',
              'value': 11,
            },
            {
              'rank': '8',
              'suit': '♣️',
            },
            {
              'rank': '8',
              'suit': '♥️',
            },
            {
              'rank': 'K',
              'suit': '♠️',
              'value': 0,
            },
            {
              'rank': '4',
              'suit': '♣️',
            },
            {
              'rank': '4',
              'suit': '♥️',
            },
            {
              'rank': '9',
              'suit': '♣️',
            },
            {
              'rank': '8',
              'suit': '♦️',
            },
            {
              'rank': 'X',
              'suit': '♦️',
              'value': 10,
            },
            {
              'rank': '6',
              'suit': '♥️',
            }
          ],
          'numberOfDecks': 1,
        },
        'invitees': [
          'JP',
          'GILLES',
        ],
        'playerIdAttacking': -1,
        'playerIdPlaying': 1,
        'players': [
          {
            'hand': [
              {
                'isRevealed': true,
                'rank': 'K',
                'suit': '♣️',
                'value': 0,
              },
              {
                'isRevealed': true,
                'rank': 'J',
                'suit': '♥️',
                'value': 11,
              },
              {
                'rank': 'X',
                'suit': '♥️',
                'value': 10,
              },
              {
                'isRevealed': true,
                'rank': 'Q',
                'suit': '♥️',
                'value': 12,
              },
              {
                'isRevealed': true,
                'rank': '§',
                'suit': '*',
                'value': -2,
              },
              {
                'isRevealed': true,
                'rank': 'Q',
                'suit': '♦️',
                'value': 12,
              },
              {
                'isRevealed': true,
                'rank': '8',
                'suit': '♠️',
              },
              {
                'isRevealed': true,
                'rank': 'A',
                'suit': '♠️',
                'value': 1,
              },
              {
                'rank': '9',
                'suit': '♠️',
              }
            ],
            'name': 'JP',
            'status': {
              'emoji': '',
              'phrase': '',
            },
          },
          {
            'hand': [
              {
                'isRevealed': true,
                'rank': 'X',
                'suit': '♠️',
                'value': 10,
              },
              {
                'isRevealed': true,
                'rank': '5',
                'suit': '♣️',
              },
              {
                'isRevealed': true,
                'rank': '3',
                'suit': '♣️',
              },
              {
                'isRevealed': true,
                'rank': '§',
                'suit': '*',
                'value': -2,
              },
              {
                'isRevealed': true,
                'rank': 'A',
                'suit': '♣️',
                'value': 1,
              },
              {
                'isRevealed': true,
                'rank': '7',
                'suit': '♠️',
              },
              {
                'isRevealed': true,
                'rank': '6',
                'suit': '♣️',
              },
              {
                'rank': '2',
                'suit': '♠️',
              },
              {
                'rank': '6',
                'suit': '♠️',
              }
            ],
            'name': 'GILLES',
            'status': {
              'emoji': '',
              'phrase': '',
            },
          }
        ],
        'state': 'GameStates.pickCardFromEitherPiles',
      });

      expect(newGameModel.players.length, equals(gameModel.players.length));
      expect(newGameModel.gameState, equals(gameModel.gameState));
    });
  });

  group('Game Link Generation', () {
    test('should generate correct game link', () {
      final expectedLink = '?mode=Custom&room=testRoom&players=Player1,Player2';
      expect(gameModel.linkUri, equals(expectedLink));
    });
  });

  group('Player Management', () {
    test('should get correct player name', () {
      expect(gameModel.getPlayerName(0), equals('Player1'));
      expect(gameModel.getPlayerName(1), equals('Player2'));
      expect(gameModel.getPlayerName(-1), equals('No one'));
    });

    test('should track revealed cards correctly', () {
      final PlayerModel player = gameModel.players.first;
      player.hand.revealAllCards();

      expect(gameModel.areAllCardRevealed(0), isTrue);
    });
  });
}
