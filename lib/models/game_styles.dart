/// Enum to represent different game styles.
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
      return 2;
    case GameStyles.skyJo:
      return 2;
    case GameStyles.miniPut:
      return 1;
    case GameStyles.custom:
      return 0;
  }
}
