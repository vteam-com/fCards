/// Game constants for the SkyJo card game.
class Constants {
  /// Number of columns in a SkyJo player's hand.
  static const int skyjoColumns = 4;

  /// Number of rows in a SkyJo player's hand.
  static const int skyjoRows = 3;

  /// Number of columns in a standard player's hand.
  static const int standardColumns = 3;

  /// Number of rows in a standard player's hand.
  static const int standardRows = 3;

  /// Number of cards to reveal at startup for French Cards game style.
  static const int frenchCardsRevealCount = 2;

  /// Number of cards to reveal at startup for SkyJo game style.
  static const int skyjoRevealCount = 2;

  /// Number of cards to reveal at startup for Mini Put game style.
  static const int miniPutRevealCount = 1;

  /// Number of cards to reveal at startup for Custom game style.
  static const int customRevealCount = 0;

  /// The number of cards to remove when evaluating a SkyJo hand (3 cards in a set).
  static const int skyjoSetSize = 3;

  /// The number of players to reveal cards for in the final turn.
  static const int finalTurnRevealCount = 1;

  /// The increment value when moving to the next player.
  static const int nextPlayerIncrement = 1;

  /// The number of cards to deal to each player in a SkyJo game.
  static const int skyjoCardsToDeal = 12;

  /// The number of cards to deal to each player in a French Cards game.
  static const int frenchCardsToDeal = 9;

  /// The number of cards to deal to each player in a Mini Put game.
  static const int miniPutCardsToDeal = 4;

  /// Number of columns in a Mini Put player's hand.
  static const int miniPutColumns = 2;

  /// Number of rows in a Mini Put player's hand.
  static const int miniPutRows = 2;

  /// The size of a 2x2 grid for Golf scoring (4 cards).
  static const int golfGrid2x2Size = 4;

  /// The size of a 3x3 grid for Golf scoring (9 cards).
  static const int golfGrid3x3Size = 9;

  /// Number of cards in a 2-card matching set.
  static const int twoCardMatchSize = 2;

  /// Number of cards in a 3-card matching set.
  static const int threeCardMatchSize = 3;

  /// Duration for snackbars in seconds.
  static const int snackbarDurationSeconds = 2;

  /// Width for string padding in player display (3 characters).
  static const int playerDisplayPaddingWidth = 3;

  /// Width for player name padding in display (10 characters).
  static const int playerNamePaddingWidth = 10;

  /// Width for string padding in card display (2 characters).
  static const int cardDisplayPaddingWidth = 2;

  /// The number of indices to check for a set (3 for 3-card sets).
  static const int indicesInSet = 3;

  /// The offset for calculating set start position (1 for 3-card sets).
  static const int setStartOffset = 1;

  /// The index offset for the first card in a set.
  static const int firstCardIndexOffset = 0;

  /// The index offset for the second card in a set.
  static const int secondCardIndexOffset = 1;

  /// The index offset for the third card in a set.
  static const int thirdCardIndexOffset = 2;

  /// The minimum value for cards in a SkyJo deck (-2).
  static const int skyjoMinValue = -2;

  /// The maximum value for cards in a SkyJo deck (12).
  static const int skyjoMaxValue = 12;

  /// The count of cards with value 0 in a SkyJo deck (15).
  static const int skyjoZeroCardCount = 15;

  /// The count of cards with value -2 in a SkyJo deck (5).
  static const int skyjoNegativeTwoCardCount = 5;

  /// The count of cards with values other than 0 and -2 in a SkyJo deck (10).
  static const int skyjoOtherCardCount = 10;

  /// The number of Jokers to add to each deck in Golf style (2).
  static const int golfJokerCount = 2;

  /// The value of a joker is a deduction of -2
  static const int golfJokerValue = -2;

  /// The minimum number of players required to start a game.
  static const int minPlayersToStartGame = 2;

  /// The maximum width for the player list widget in the join game screen.
  static const double joinGamePlayerListMaxWidth = 400.0;

  /// The width for the name entry field in join game screen.
  static const double joinGameNameEntryWidth = 300.0;

  /// The padding value for container in join game screen.
  static const double joinGameContainerPadding = 100.0;

  /// The border radius for container in join game screen.
  static const double joinGameContainerBorderRadius = 8.0;

  /// The font size X1
  static const double textSizeX1 = 15.0;

  /// The font size X2
  static const double textSizeX2 = 30.0;

  /// The horizontal padding for the start game button.
  static const double joinGameButtonHorizontalPadding = 24.0;

  /// The vertical padding for the start game button.
  static const double joinGameButtonVerticalPadding = 12.0;

  /// The spacing between widgets in join game screen.
  static const double joinGameSpacing = 20.0;

  /// The radius for circle avatar in join game screen.
  static const double circleAvatarRadius = 12.0;

  /// Column spacing
  static const double spacing = 20.0;
}
