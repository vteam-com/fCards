import 'package:cards/models/card/card_model.dart';
import 'package:cards/screens/game/game_style_constants.dart';

enum GameStyles {
  /// Classic French cards with a 9x9 grid and special rules.
  frenchCards9,

  /// SkyJo card game style with specific rules.
  skyJo,

  /// Mini Putt card game style with a smaller grid.
  miniPut,

  /// Custom game style that allows for any configuration.
  custom,
}

/// Configuration for a specific game style
class GameStyleConfig {
  /// Number of cards to reveal at startup
  final int cardsToReveal;

  /// Number of cards to deal to each player
  final int cardsToDeal;

  /// Number of decks required for the given number of players
  final int decks;

  const GameStyleConfig({
    required this.cardsToReveal,
    required this.cardsToDeal,
    required this.decks,
  });
}

/// Returns the complete configuration for a given game style
///
/// Takes a [GameStyles] parameter and [numberOfPlayers] to return
/// a comprehensive configuration object for the game.
GameStyleConfig getGameStyleConfig(GameStyles style, int numberOfPlayers) {
  switch (style) {
    case GameStyles.frenchCards9:
      return GameStyleConfig(
        cardsToReveal: CardModel.frenchCardsRevealCount,
        cardsToDeal: GameStyleConstants.standardCardCount,
        decks: GameStyleConstants.calculateDecks(numberOfPlayers),
      );
    case GameStyles.skyJo:
      return GameStyleConfig(
        cardsToReveal: CardModel.skyjoRevealCount,
        cardsToDeal: GameStyleConstants.skyJoCardCount,
        decks: 1,
      );
    case GameStyles.miniPut:
      return GameStyleConfig(
        cardsToReveal: CardModel.miniPutRevealCount,
        cardsToDeal: GameStyleConstants.miniPutCardCount,
        decks: 1,
      );
    case GameStyles.custom:
      return GameStyleConfig(
        cardsToReveal: CardModel.customRevealCount,
        cardsToDeal: GameStyleConstants.standardCardCount,
        decks: 1,
      );
  }
}

/// Returns the number of decks required for a given game style and number of players.
///
/// Takes a [GameStyles] parameter and [numberOfPlayers] to calculate
/// how many card decks are needed for the game.
@Deprecated('Use getGameStyleConfig().decks instead')
int numberOfDecks(GameStyles style, int numberOfPlayers) {
  switch (style) {
    case GameStyles.frenchCards9:
      return GameStyleConstants.calculateDecks(numberOfPlayers);
    case GameStyles.skyJo:
      return 1;
    case GameStyles.miniPut:
      return 1;
    case GameStyles.custom:
      return 1;
  }
}
