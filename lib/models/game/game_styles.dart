import 'package:cards/models/card/card_model.dart';

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

/// Returns the number of cards to reveal at startup for a given game style.
///
/// Takes a [GameStyles] parameter and returns the number of cards that
/// should be revealed when the game starts.
int numberOfCardsToRevealOnStartup(GameStyles style) {
  switch (style) {
    case GameStyles.frenchCards9:
      return CardModel.frenchCardsRevealCount;
    case GameStyles.skyJo:
      return CardModel.skyjoRevealCount;
    case GameStyles.miniPut:
      return CardModel.miniPutRevealCount;
    case GameStyles.custom:
      return CardModel.customRevealCount;
  }
}
