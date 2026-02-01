// ignore: fcheck_magic_numbers
import 'package:cards/utils/logger.dart';
import 'package:cards/models/card/card_dimensions.dart';
import 'package:cards/models/card/card_model_french.dart';
import 'package:cards/models/game/game_model.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/widgets/cards/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// File: game_style.dart
///
/// This file defines the models and widgets for different game styles in a card game application.
/// It includes GameStyle enum, GameStyle widget, functions to get card lists,
/// instructions, and other utility functions related to game settings.

/// A StatelessWidget representing the game style UI.
///
/// Displays game instructions and available cards for the selected game style.
class GameStyle extends StatelessWidget {
  /// Creates a GameStyle widget.
  ///
  /// The [style] parameter determines which game variant to display.
  const GameStyle({super.key, required this.style});

  /// The selected game style to display.
  final GameStyles style;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Markdown(
            selectable: true,
            styleSheet: MarkdownStyleSheet(textScaler: TextScaler.linear(1.2)),
            data: gameInstructions(style),
            onTapLink: (text, href, title) async {
              if (href != null) {
                await launchUrlString(href);
              }
            },
          ),
        ),
        showAllCards(),
      ],
    );
  }

  /// Retrieves all French Cards based on the game rules.
  ///
  /// Returns a [List<CardModel>] containing all French cards including
  /// special cards and standard ranked cards.
  List<CardModel> getAllFrenchCards() {
    List<CardModel> cards = [];
    cards.add(CardModel(suit: '*', rank: '§', value: -2, isRevealed: false));
    cards.add(CardModel(suit: '*', rank: '§', value: -2, isRevealed: true));
    int suit = 0;
    for (String rank in CardModelFrench.ranks) {
      cards.add(
        CardModel(
          suit: CardModelFrench.suits[suit],
          rank: rank,
          value: CardModelFrench.getValue(rank),
          isRevealed: true,
        ),
      );
      suit++;
      if (suit == CardModelFrench.suits.length) {
        suit = 0;
      }
    }
    return cards;
  }

  /// Retrieves all SkyJo Cards based on the game rules.
  ///
  /// Returns a [List<CardModel>] containing all SkyJo cards with values
  /// ranging from -2 to 12.
  List<CardModel> getAllSkyJoCards() {
    List<CardModel> cards = [];
    cards.add(CardModel(suit: '', rank: '1', value: 1, isRevealed: false));

    for (int rank = -2; rank <= 12; rank++) {
      cards.add(
        CardModel(
          suit: '',
          rank: rank.toString(),
          value: rank,
          isRevealed: true,
        ),
      );
    }
    return cards;
  }

  /// Displays all cards based on the selected game style.
  ///
  /// Returns a [Widget] containing a wrapped layout of all available cards
  /// for the current game style.
  Widget showAllCards() {
    List<CardModel> cards = [];
    switch (style) {
      case GameStyles.frenchCards9:
        cards = getAllFrenchCards();
      case GameStyles.skyJo:
        cards = getAllSkyJoCards();
      case GameStyles.miniPut:
        cards = getAllFrenchCards(); // Similar to French Cards for simplicity
      case GameStyles.custom:
        cards = getAllFrenchCards(); // Similar to French Cards for simplicity
    }
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: cards
          .map(
            (card) => SizedBox(
              width: CardDimensions.width / 3,
              height: CardDimensions.height / 3,
              child: CardWidget(card: card),
            ),
          )
          .toList(),
    );
  }
}

/// Converts an integer index to a GameStyles enum.
///
/// Returns the corresponding [GameStyles] enum value for the given [gameStyleIndex].
/// Falls back to [GameStyles.frenchCards9] if the index is invalid.
GameStyles intToGameStyles(final int gameStyleIndex) {
  if (gameStyleIndex >= 0 && gameStyleIndex < GameStyles.values.length) {
    return GameStyles.values[gameStyleIndex];
  } else {
    logger.w(
      'Invalid gameStyleIndex: $gameStyleIndex fall back to ${GameStyles.frenchCards9}',
    );
    return GameStyles.frenchCards9;
  }
}

/// Returns the number of cards for a given game style.
///
/// Takes a [GameStyles] parameter and returns the number of cards
/// required for that game variant.
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

/// Returns the number of decks required for a given game style and number of players.
///
/// Takes a [GameStyles] parameter and [numberOfPlayers] to calculate
/// how many card decks are needed for the game.
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

/// Returns the instructions for a given game style.
///
/// Takes a [GameStyles] parameter and returns a formatted string containing
/// the rules and instructions for that game variant.
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
