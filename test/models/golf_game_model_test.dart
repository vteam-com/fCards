import 'package:cards/models/base/game_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Create a mock BuildContext - necessary for methods that use BuildContext
class MockBuildContext extends Mock implements BuildContext {}

void main() {
  group('GameModel', () {
    late GameModel gameModel;
    late MockBuildContext mockContext; // Instance of the mock

    setUp(() {
      mockContext = MockBuildContext();
      gameModel = GameModel(
        gameMode: gameModeSkyJo,
        roomName: 'testRoom',
        roomHistory: [],
        loginUserName: 'Player 1',
        names: ['Player 1', 'Player 2'],
        cardsToDeal: 9,
        deck: DeckModel(numberOfDecks: 1),
        isNewGame: true,
      );
    });

    test('drawCard from discard pile updates game state', () {
      // On start up 18 cards were distributed to the players, and the first card of the deck is flipped in the discarded pile.
      expect(
        gameModel.deck.cardsDeckDiscarded.length,
        1,
        reason: 'Discard pile should have 1 card in it',
      );

      // Set the state enable select a card from either pile
      gameModel.gameState = GameStates.pickCardFromEitherPiles;

      // Action user picked the top card of the discarded pile
      gameModel.selectTopCardOfDeck(mockContext, fromDiscardPile: true);

      expect(
        gameModel.gameState,
        GameStates.swapDiscardedCardWithAnyCardsInHand,
        reason: 'State should have changed to flipAndSwap',
      );
    });
  });

  test('initializeGame sets up correct initial state', () {
    final gameModel = GameModel(
      gameMode: gameModeFrenchCards,
      roomName: 'testRoom',
      roomHistory: [],
      loginUserName: 'Player 1',
      names: ['Player 1', 'Player 2', 'Player 3'],
      cardsToDeal: 9,
      deck: DeckModel(numberOfDecks: 1),
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
  });

  test('moveToNextPlayer correctly handles final turn', () {
    final gameModel = GameModel(
      gameMode: gameModeFrenchCards,
      roomName: 'testRoom',
      roomHistory: [],
      loginUserName: 'Player 1',
      names: ['Player 1', 'Player 2'],
      cardsToDeal: 9,
      deck: DeckModel(numberOfDecks: 1),
      isNewGame: true,
    );

    // Reveal all cards for current player
    gameModel.players.first.hand.revealAllCards();

    gameModel.moveToNextPlayer(MockBuildContext());

    expect(gameModel.playerIdAttacking, 0);
    expect(gameModel.playerIdPlaying, 1);
    expect(gameModel.isFinalTurn, true);
  });

  test('getGameStateAsString returns correct message for different scenarios',
      () {
    final gameModel = GameModel(
      gameMode: gameModeFrenchCards,
      roomName: 'testRoom',
      roomHistory: [],
      loginUserName: 'Player 1',
      names: ['Player 1', 'Player 2'],
      cardsToDeal: 9,
      deck: DeckModel(numberOfDecks: 1),
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
  });

  test('areAllCardsFromHandsRevealed returns correct state', () {
    final gameModel = GameModel(
      gameMode: gameModeFrenchCards,
      roomName: 'testRoom',
      roomHistory: [],
      loginUserName: 'Player 1',
      names: ['Player 1', 'Player 2'],
      cardsToDeal: 9,
      deck: DeckModel(numberOfDecks: 1),
      isNewGame: true,
    );

    expect(gameModel.areAllCardsFromHandsRevealed(), false);

    for (var player in gameModel.players) {
      player.hand.revealAllCards();
    }

    expect(gameModel.areAllCardsFromHandsRevealed(), true);
  });

  test('fromJson correctly updates game state', () {
    final gameModel = GameModel(
      gameMode: gameModeFrenchCards,
      roomName: 'testRoom',
      roomHistory: [],
      loginUserName: 'Player 1',
      names: ['Player 1', 'Player 2'],
      cardsToDeal: 9,
      deck: DeckModel(numberOfDecks: 1),
      isNewGame: true,
    );

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

    gameModel.fromJson(jsonData);

    expect(gameModel.playerIdPlaying, 1);
    expect(gameModel.playerIdAttacking, 0);
    expect(gameModel.gameState, GameStates.gameOver);
    expect(gameModel.players.length, 2);
  });
}
