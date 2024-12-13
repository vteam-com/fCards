import 'package:cards/models/game_history.dart';
import 'package:cards/models/game_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testPlayers = [
    'Player1',
    'Player2',
  ];

  GameModel getNewSkyJoInstance() {
    return GameModel(
      gameStyle: GameStyles.skyJo,
      roomName: 'testRoom',
      roomHistory: [],
      loginUserName: testPlayers.first,
      names: testPlayers,
      cardsToDeal: 12,
      deck: DeckModel(
        numberOfDecks: 1,
        gameStyle: GameStyles.skyJo,
      ),
      isNewGame: true,
    );
  }

  GameModel getNewInstanceFrench9Cards() {
    return GameModel(
      gameStyle: GameStyles.frenchCards9,
      roomName: 'testRoom',
      roomHistory: [],
      loginUserName: testPlayers.first,
      names: testPlayers,
      cardsToDeal: 9,
      deck: DeckModel(
        numberOfDecks: 1,
        gameStyle: GameStyles.frenchCards9,
      ),
      isNewGame: true,
    );
  }

  GameModel getNewInstanceFrenchMiniPut() {
    return GameModel(
      gameStyle: GameStyles.miniPut,
      roomName: 'testRoom',
      roomHistory: [],
      loginUserName: testPlayers.first,
      names: testPlayers,
      cardsToDeal: 4,
      deck: DeckModel(
        numberOfDecks: 1,
        gameStyle: GameStyles.miniPut,
      ),
      isNewGame: true,
    );
  }

  group('GameModel Initialization', () {
    test('should initialize with correct number of players', () {
      final gameModel = getNewSkyJoInstance();
      expect(gameModel.players.length, equals(2));
      expect(gameModel.getPlayersNames(), equals(testPlayers));
    });

    test('should start with correct game state', () {
      final gameModel = getNewSkyJoInstance();
      expect(gameModel.gameState, equals(GameStates.pickCardFromEitherPiles));
    });

    test('should deal correct number of cards to players', () {
      final gameModel = getNewSkyJoInstance();
      for (var player in gameModel.players) {
        expect(player.hand.length, equals(12));
      }
    });

    test('gameModel == gameModel, hash, toString', () {
      final gameModel1 = getNewSkyJoInstance();
      final gameModel2 = getNewInstanceFrench9Cards();

      final gameModel3 = getNewInstanceFrenchMiniPut();
      gameModel3.players.first.hand.getSumOfCardsForGolf();

      expect(gameModel1 == gameModel1, true);
      expect(gameModel2 == gameModel2, true);
      expect(gameModel1 == gameModel2, false);

      expect(gameModel1.hashCode == gameModel1.hashCode, true);
      expect(gameModel2.hashCode == gameModel2.hashCode, true);
      expect(gameModel1.hashCode == gameModel2.hashCode, false);
      expect(gameModel2.hashCode == gameModel3.hashCode, false);

      expect(gameModel1.toString() == gameModel1.toString(), true);
      expect(gameModel2.toString() == gameModel2.toString(), true);
      expect(gameModel1.toString() == gameModel2.toString(), false);
    });
  });

  test('MiniPut', () {
    final gameModel3 = getNewInstanceFrenchMiniPut();
    gameModel3.players.first.hand.revealAllCards();
    // TODO
    // note that there is a chance that all reveal cards adds up to zero
    final count = gameModel3.players.first.hand.getSumOfCardsForGolf();
    expect(count > 0, true);
  });

  group('Game State Management', () {
    test('should properly track active player', () {
      final gameModel = getNewSkyJoInstance();
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
      final gameModel = getNewSkyJoInstance();
      expect(gameModel.isFinalTurn, isFalse);
      gameModel.playerIdAttacking = 1;
      expect(gameModel.isFinalTurn, isTrue);
    });

    test('Player status', () {
      final gameModel = getNewSkyJoInstance();
      gameModel.updatePlayerStatus(
        gameModel.players.first,
        PlayerStatus(emoji: '', phrase: 'test'),
      );
      expect(gameModel.players.first.status.phrase, 'test');
    });
  });

  group('Card Operations', () {
    test('should handle card revelation', () {
      final gameModel = getNewSkyJoInstance();
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
      final gameModel = getNewSkyJoInstance();
      final json = gameModel.toJson();

      expect(json['players'], isNotNull);
      expect(json['deck'], isNotNull);
      expect(json['playerIdPlaying'], equals(gameModel.playerIdPlaying));
      expect(json['state'], equals(gameModel.gameState.toString()));
    });

    test('should correctly deserialize from JSON', () {
      final newGameModel = GameModel(
        gameStyle: GameStyles.skyJo,
        roomName: 'testRoom',
        roomHistory: [],
        loginUserName: 'Player1',
        names: testPlayers,
        cardsToDeal: 9,
        deck: DeckModel(
          numberOfDecks: 1,
          gameStyle: GameStyles.skyJo,
        ),
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

      final gameModel = getNewSkyJoInstance();
      expect(newGameModel.players.length, equals(gameModel.players.length));
      expect(newGameModel.gameState, equals(gameModel.gameState));
    });
  });

  group('Game Link Generation', () {
    test('should generate correct game link', () {
      final gameModel = getNewSkyJoInstance();
      final expectedLink = '?mode=Custom&room=testRoom&players=Player1,Player2';
      expect(gameModel.linkUri, equals(expectedLink));

      // because this is running in a none-browser mode the expected url will be empty
      expect(gameModel.getLinkToGame(), equals(''));
    });
  });

  group('Player Management', () {
    test('should get correct player name', () {
      final gameModel = getNewSkyJoInstance();
      expect(gameModel.getPlayerName(0), equals('Player1'));
      expect(gameModel.getPlayerName(1), equals('Player2'));
      expect(gameModel.getPlayerName(-1), equals('No one'));
    });

    test('should track revealed cards correctly', () {
      final gameModel = getNewSkyJoInstance();
      final PlayerModel player = gameModel.players.first;
      player.hand.revealAllCards();

      expect(gameModel.areAllCardRevealed(0), isTrue);
    });
  });
}
