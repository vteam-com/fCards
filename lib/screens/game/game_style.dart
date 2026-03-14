import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/gen/l10n/app_localizations_en.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/card/card_dimensions.dart';
import 'package:cards/models/card/card_model_french.dart';
import 'package:cards/models/game/game_constants.dart';
import 'package:cards/models/game/game_model.dart';
import 'package:cards/models/game/game_styles.dart';
import 'package:cards/utils/logger.dart';
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
    final AppLocalizations localizations =
        Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizationsEn();
    return Column(
      children: [
        Expanded(
          child: Markdown(
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              textScaler: TextScaler.linear(ConstLayout.markdownTextScale),
            ),
            data: gameInstructions(style, localizations),
            onTapLink: (_ /* text */, href, _ /* title */) async {
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
    cards.add(
      CardModel(
        suit: '*',
        rank: '§',
        value: GameConstants.skyJoSpecialValue,
        isRevealed: false,
      ),
    );
    cards.add(
      CardModel(
        suit: '*',
        rank: '§',
        value: GameConstants.skyJoSpecialValue,
        isRevealed: true,
      ),
    );
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

    for (
      int rank = GameConstants.skyJoRankMin;
      rank <= GameConstants.skyJoRankMax;
      rank++
    ) {
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
      spacing: ConstLayout.sizeM,
      runSpacing: ConstLayout.sizeM,
      children: cards
          .map(
            (card) => SizedBox(
              width: CardDimensions.width / GameConstants.cardDisplayDivisor,
              height: CardDimensions.height / GameConstants.cardDisplayDivisor,
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

/// Returns the instructions for a given game style.
///
/// Takes a [GameStyles] parameter and returns a formatted string containing
/// the rules and instructions for that game variant.
String gameInstructions(GameStyles style, AppLocalizations localizations) {
  switch (style) {
    case GameStyles.frenchCards9:
      return localizations.instructionsFrenchCards9;
    case GameStyles.skyJo:
      return localizations.instructionsSkyJo;
    case GameStyles.miniPut:
      return localizations.instructionsMiniPut;

    case GameStyles.custom:
      return localizations.instructionsCustom;
  }
}
