import 'package:cards/misc.dart';

enum GameStyles {
  frenchCards9,
  skyJo,
  miniPut,
  custom,
}

GameStyles intToGameStyles(final int gameStyleIndex) {
  // Validate that the index is within the valid range of GameStyles values.
  if (gameStyleIndex >= 0 && gameStyleIndex < GameStyles.values.length) {
    return GameStyles.values[gameStyleIndex];
  } else {
    // Handle the error case where the index is out of range.
    // You can throw an exception, return a default value, or log an error.
    // Here, we return a default value and log an error message.
    debugLog(
      'Invalid gameStyleIndex: $gameStyleIndex fall back to ${GameStyles.frenchCards9}',
    );
    return GameStyles.frenchCards9; // Or whatever your default GameStyle is
  }
}

int numberOfCards(GameStyles style) {
  switch (style) {
    case GameStyles.frenchCards9:
      return 9;
    case GameStyles.skyJo:
      return 12;
    case GameStyles.miniPut:
      return 4;
    case GameStyles.custom:
      return 9;
  }
}

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

int numberOfDecks(GameStyles style, int numberOfPlayers) {
  switch (style) {
    case GameStyles.frenchCards9:
      return (numberOfPlayers + 1) ~/ 2;
    case GameStyles.skyJo:
      return 1;
    case GameStyles.miniPut:
      return 1;
    case GameStyles.custom:
      return 1;
  }
}

String gameInstructions(GameStyles style) {
  switch (style) {
    case GameStyles.frenchCards9:
      return '- Aim for the lowest score.'
          '\n- Choose a card from either the Deck or Discard pile.'
          '\n- Swap the chosen card with a card in your 3x3 grid, or discard it and flip over one of your face-down cards.'
          '\n- Three cards of the same rank in a row or column score zero.'
          '\n- The first player to reveal all nine cards challenges others, claiming the lowest score.'
          '\n- If someone else has an equal or lower score, the challenger doubles their points!'
          '\n- Players are eliminated after busting 100 points.'
          '\n'
          '\n'
          'Learn more [Wikipedia](https://en.wikipedia.org/wiki/Golf_(card_game))';
    case GameStyles.skyJo:
      return '- Aim for the lowest score.'
          '\n- Choose a card from either the Deck or Discard pile.'
          '\n- Swap the chosen card with a card in your 4x3 grid, or discard it and flip over one of your face-down cards.'
          '\n- When 3 cards of the same rank are lined up in a column they are moved to the discard pile.'
          '\n- The first player to reveal all their cards challenges others, claiming the lowest score.'
          '\n'
          '\n'
          'Learn more [SkyJo](https://www.geekyhobbies.com/how-to-play-skyjo-card-game-rules-and-instructions/)';
    case GameStyles.miniPut:
      return '- Aim for the lowest score.'
          '\n- Choose a card from either the Deck or Discard pile.'
          '\n- Swap the chosen card with a card in your 2x2 grid, or discard it and flip over one of your face-down cards.'
          '\n- Three cards of the same rank in a row or column score zero.'
          '\n- The first player to reveal all nine cards challenges others, claiming the lowest score.'
          '\n- If someone else has an equal or lower score, the challenger doubles their points!'
          '\n- Players are eliminated after busting 100 points.'
          '\n'
          '\n'
          'Learn more [Wikipedia](https://en.wikipedia.org/wiki/Golf_(card_game))';

    case GameStyles.custom:
      return 'Custom rules';
  }
}
