import 'package:cards/models/game/game_model.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Create a mock BuildContext - necessary for methods that use BuildContext
class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late MockBuildContext mockContext; // Instance of the mock

  late GameModel gameModelSkyJo;
  late GameModel gameModelFrench9Cards;
  late GameModel gameModelMiniPut;
  List<String> playersNames = ['Player 1', 'Player 2'];
  setUp(() {
    mockContext = MockBuildContext();
    gameModelSkyJo = GameModel(
      gameStyle: GameStyles.skyJo,
      roomName: 'testRoom',
      roomHistory: [],
      loginUserName: playersNames.first,
      names: playersNames,
      cardsToDeal: 9,
      deck: DeckModel(numberOfDecks: 1, gameStyle: GameStyles.skyJo),
      isNewGame: true,
    );

    gameModelFrench9Cards = GameModel(
      gameStyle: GameStyles.frenchCards9,
      roomName: 'TEST_ROOM_FRENCH_9_CARDS',
      roomHistory: [],
      loginUserName: playersNames.first,
      names: playersNames,
      cardsToDeal: 9,
      deck: DeckModel(numberOfDecks: 1, gameStyle: GameStyles.frenchCards9),
      isNewGame: true,
    );

    gameModelMiniPut = GameModel(
      gameStyle: GameStyles.miniPut,
      roomName: 'TEST_ROOM_FRENCH_MINI_PUT',
      roomHistory: [],
      loginUserName: playersNames.first,
      names: playersNames,
      cardsToDeal: 4,
      deck: DeckModel(numberOfDecks: 1, gameStyle: GameStyles.miniPut),
      isNewGame: true,
    );
  });

  group('GameModel', () {
    test('drawCard from discard pile updates game state', () {
      // On start up 18 cards were distributed to the players, and the first card of the deck is flipped in the discarded pile.
      expect(
        gameModelSkyJo.deck.cardsDeckDiscarded.length,
        1,
        reason: 'Discard pile should have 1 card in it',
      );

      // Set the state enable select a card from either pile
      gameModelSkyJo.gameState = GameStates.pickCardFromEitherPiles;

      // Action user picked the top card of the discarded pile
      gameModelSkyJo.selectTopCardOfDeck(mockContext, fromDiscardPile: true);

      expect(
        gameModelSkyJo.gameState,
        GameStates.swapDiscardedCardWithAnyCardsInHand,
        reason: 'State should have changed to flipAndSwap',
      );
    });
  });

  test('initializeGame sets up correct initial state', () {
    final gameModel = GameModel(
      gameStyle: GameStyles.frenchCards9,
      roomName: 'testRoom',
      roomHistory: [],
      loginUserName: 'Player 1',
      names: ['Player 1', 'Player 2', 'Player 3'],
      cardsToDeal: 9,
      deck: DeckModel(numberOfDecks: 1, gameStyle: GameStyles.frenchCards9),
      isNewGame: true,
    );

    gameModel.initializeGame();

    expect(gameModel.playerIdPlaying, 0);
    expect(gameModel.playerIdAttacking, -1);
    expect(gameModel.players.length, 3);
    expect(gameModel.gameState, GameStates.pickCardFromEitherPiles);
    expect(gameModel.deck.cardsDeckDiscarded.length, 1);

    for (final PlayerModel player in gameModel.players) {
      expect(player.hand.length, 9);
      expect(player.hand.revealedCards.length, 2);
    }

    // remaining cards in the deck piles
    expect(gameModelFrench9Cards.deck.cardsDeckPile.length, 35);
    expect(gameModelMiniPut.deck.cardsDeckPile.length, 45);
  });

  test('moveToNextPlayer correctly handles final turn', () {
    final gameModel = GameModel(
      gameStyle: GameStyles.frenchCards9,
      roomName: 'testRoom',
      roomHistory: [],
      loginUserName: 'Player 1',
      names: ['Player 1', 'Player 2'],
      cardsToDeal: 9,
      deck: DeckModel(numberOfDecks: 1, gameStyle: GameStyles.frenchCards9),
      isNewGame: true,
    );

    // Reveal all cards for current player
    gameModel.players.first.hand.revealAllCards();

    gameModel.moveToNextPlayer(MockBuildContext());

    expect(gameModel.playerIdAttacking, 0);
    expect(gameModel.playerIdPlaying, 1);
    expect(gameModel.isFinalTurn, true);
  });

  test(
    'getGameStateAsString returns correct message for different scenarios',
    () {
      final gameModel = GameModel(
        gameStyle: GameStyles.frenchCards9,
        roomName: 'testRoom',
        roomHistory: [],
        loginUserName: 'Player 1',
        names: ['Player 1', 'Player 2'],
        cardsToDeal: 9,
        deck: DeckModel(numberOfDecks: 1, gameStyle: GameStyles.frenchCards9),
        isNewGame: true,
      );

      expect(gameModel.getGameStateAsString(), "It's your turn Player 1");

      gameModel.setActivePlayer(1);
      expect(gameModel.getGameStateAsString(), "It's Player 2's turn");

      gameModel.playerIdAttacking = 0;
      expect(
        gameModel.getGameStateAsString(),
        "Final Round. It's Player 2's turn. You have to beat Player 1",
      );
    },
  );

  test('areAllCardsFromHandsRevealed returns correct state', () {
    final gameModel = GameModel(
      gameStyle: GameStyles.frenchCards9,
      roomName: 'testRoom',
      roomHistory: [],
      loginUserName: 'Player 1',
      names: ['Player 1', 'Player 2'],
      cardsToDeal: 9,
      deck: DeckModel(numberOfDecks: 1, gameStyle: GameStyles.frenchCards9),
      isNewGame: true,
    );

    expect(gameModel.areAllCardsFromHandsRevealed(), false);

    for (var player in gameModel.players) {
      player.hand.revealAllCards();
    }

    expect(gameModel.areAllCardsFromHandsRevealed(), true);
  });

  test('fromJson correctly updates game state', () {
    final jsonData = {
      'players': [
        {'name': 'Player 1', 'hand': []},
        {'name': 'Player 2', 'hand': []},
      ],
      'deck': {'cardsDeckPile': [], 'cardsDeckDiscarded': []},
      'playerIdPlaying': 1,
      'playerIdAttacking': 0,
      'state': 'GameStates.gameOver',
    };

    // French 9 Cards
    {
      final gameModel = GameModel(
        gameStyle: GameStyles.frenchCards9,
        roomName: 'testRoom',
        roomHistory: [],
        loginUserName: playersNames.first,
        names: playersNames,
        cardsToDeal: 9,
        deck: DeckModel(numberOfDecks: 1, gameStyle: GameStyles.frenchCards9),
        isNewGame: true,
      );

      gameModel.fromJson(jsonData);

      expect(gameModel.playerIdPlaying, 1);
      expect(gameModel.playerIdAttacking, 0);
      expect(gameModel.gameState, GameStates.gameOver);
      expect(gameModel.players.length, 2);
    }

    // French MiniPut 4 Cards
    {
      final gameModel = GameModel(
        gameStyle: GameStyles.miniPut,
        roomName: 'testRoom',
        roomHistory: [],
        loginUserName: playersNames.first,
        names: playersNames,
        cardsToDeal: 4,
        deck: DeckModel(numberOfDecks: 1, gameStyle: GameStyles.miniPut),
        isNewGame: true,
      );

      gameModel.fromJson(jsonData);

      expect(gameModel.playerIdPlaying, 1);
      expect(gameModel.playerIdAttacking, 0);
      expect(gameModel.gameState, GameStates.gameOver);
      expect(gameModel.players.length, 2);
    }

    // Custom
    {
      final gameModel = GameModel(
        gameStyle: GameStyles.custom,
        roomName: 'testRoom',
        roomHistory: [],
        loginUserName: playersNames.first,
        names: playersNames,
        cardsToDeal: 9,
        deck: DeckModel(numberOfDecks: 1, gameStyle: GameStyles.custom),
        isNewGame: true,
      );

      gameModel.fromJson(jsonData);

      expect(gameModel.playerIdPlaying, 1);
      expect(gameModel.playerIdAttacking, 0);
      expect(gameModel.gameState, GameStates.gameOver);
      expect(gameModel.players.length, 2);
    }
  });
}
