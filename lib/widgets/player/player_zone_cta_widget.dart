import 'package:cards/gen/l10n/app_localizations.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/game/game_model.dart';
import 'package:cards/widgets/cards/card_pile_widget.dart';
import 'package:flutter/material.dart';

///
class PlayerZoneCtaWidget extends StatelessWidget {
  /// Constructs a [PlayerZoneCtaWidget] with the given [player] and [gameModel].
  ///
  /// The [player] parameter represents the player associated with this widget.
  /// The [gameModel] parameter represents the game model associated with this widget.
  const PlayerZoneCtaWidget({
    super.key,
    required this.player,
    required this.gameModel,
  });

  ///
  final GameModel gameModel;

  ///
  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    return Center(child: buildContent(context));
  }

  ///
  Widget buildContent(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    if (player.isActivePlayer) {
      switch (gameModel.gameState) {
        //
        case GameStates.notStarted:
          return Text(localizations.starting);

        /// Player has to choose to Reveal the Top Deck card or Take the Discarded Card
        /// if chose to reveal deck card >>> [swapWithAnyCardsInHandOrDiscard]
        /// selected the discard card >>> [GameStates.swapDiscardedCardWithAnyCardsInHand]
        case GameStates.pickCardFromEitherPiles:
          return ctaPickCardFromPiles(context);

        // Use has chosen to reveal the top deck card
        // now either:
        // 1) swap with any of the players card > Move to next players [pickCardFromEitherPiles]
        // 2) discard > this will move the state to >>> [revealOneHiddenCard]
        case GameStates.swapTopDeckCardWithAnyCardsInHandOrDiscard:
          return ctaSwapTopDeckCardWithAnyCardsInHandOrDiscard(context);

        // swap the discarded card with any of the players card >>>> Move to next players [pickCardFromEitherPiles]
        case GameStates.swapDiscardedCardWithAnyCardsInHand:
          return ctaSwapDiscardedCardWithAnyCardsInHand(context);

        // after this it goes to next player >>> [pickCardFromEitherPiles]
        case GameStates.revealOneHiddenCard:
          return ctaFlipOneOfYourHiddenCards(context);

        //
        case GameStates.gameOver:
          return Text(localizations.gameOverTitle);
      }
    } else {
      return buildWaitingForTurnContent(context);
    }
  }

  ///
  Widget buildWaitingForTurnContent(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return buildMiniInstructions(
      player.isActivePlayer,
      player.areAllCardsRevealed()
          ? localizations.youAreDone
          : localizations.waitForYourTurnSmiley,
      TextAlign.center,
    );
  }

  ///
  Widget ctaFlipOneOfYourHiddenCards(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return buildMiniInstructions(
      true,
      localizations.flipOpenOneHiddenCard,
      TextAlign.center,
    );
  }

  ///
  /// Draw Card [DECK]   [DISCARD] or here
  ///  here ->                     <-
  ///
  Widget ctaPickCardFromPiles(final BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (GameStates.swapTopDeckCardWithAnyCardsInHandOrDiscard !=
            gameModel.gameState)
          buildMiniInstructions(
            true,
            localizations.drawCardHere,
            TextAlign.left,
          ),
        const SizedBox(width: ConstLayout.sizeM),
        CardPileWidget(
          cards: gameModel.deck.cardsDeckPile,
          scale: 1.00,
          wiggleTopCard: true,
          cardsAreHidden: true,
          revealTopDeckCard:
              gameModel.gameState ==
              GameStates.swapTopDeckCardWithAnyCardsInHandOrDiscard,
          isDragSource: false,
          isDropTarget: false,
          onDragDropped: null,
          onDraw: () => gameModel.selectTopCardOfDeck(
            context,
            fromDiscardPile: false,
            notYourTurnMessage: localizations.notYourTurn,
            noCardsAvailableMessage: localizations.noCardsAvailableToDraw,
          ),
        ),
        CardPileWidget(
          cards: gameModel.deck.cardsDeckDiscarded,
          scale: 1.00,
          wiggleTopCard: true,
          cardsAreHidden: false,
          revealTopDeckCard: true,
          isDragSource: false,
          isDropTarget: false,
          onDragDropped: null,
          onDraw: () => gameModel.selectTopCardOfDeck(
            context,
            fromDiscardPile: true,
            notYourTurnMessage: localizations.notYourTurn,
            noCardsAvailableMessage: localizations.noCardsAvailableToDraw,
          ),
        ),
        const SizedBox(width: ConstLayout.sizeM),
        buildMiniInstructions(true, localizations.orHereLeft, TextAlign.right),
      ],
    );
  }

  ///
  /// [DECK] (instructions)[DISCARD]<<Active
  ///
  Widget ctaSwapDiscardedCardWithAnyCardsInHand(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    gameModel.deck.cardsDeckDiscarded.last.isSelectable = false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // left Pile
        CardPileWidget(
          cards: gameModel.deck.cardsDeckPile,
          scale: ConstLayout.scaleSmall,
          wiggleTopCard: false,
          cardsAreHidden: true,
          revealTopDeckCard: false,
          isDragSource: false,
          isDropTarget: false,
          onDragDropped: null,
        ),

        // Let them know what to do
        buildMiniInstructions(
          true,
          localizations.swapThisWith,
          TextAlign.center,
        ),

        // Right Discarded pile
        CardPileWidget(
          cards: gameModel.deck.cardsDeckDiscarded,
          scale: 1.0,
          wiggleTopCard: false,
          cardsAreHidden: false,
          revealTopDeckCard: true,
          isDragSource: true,
          isDropTarget: false,
          onDragDropped: null,
          onDraw: () => gameModel.selectTopCardOfDeck(
            context,
            fromDiscardPile: true,
            notYourTurnMessage: localizations.notYourTurn,
            noCardsAvailableMessage: localizations.noCardsAvailableToDraw,
          ),
        ),
      ],
    );
  }

  ///
  /// [DECK]   [DISCARDED]
  ///
  Widget ctaSwapTopDeckCardWithAnyCardsInHandOrDiscard(
    final BuildContext context,
  ) {
    final AppLocalizations localizations = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CardPileWidget(
          cards: gameModel.deck.cardsDeckPile,
          scale: 1.0,
          wiggleTopCard: false,
          cardsAreHidden: true,
          revealTopDeckCard: true,
          isDragSource: true,
          isDropTarget: false,
          onDragDropped: (cardSource, cardTarget, targetCenter) =>
              gameModel.onDropCardOnCard(
                context,
                cardSource,
                cardTarget,
                swapOrigin: targetCenter,
              ),
        ),
        buildMiniInstructions(
          true,
          localizations.discardOrSwap,
          TextAlign.center,
        ),
        CardPileWidget(
          cards: gameModel.deck.cardsDeckDiscarded,
          scale: ConstLayout.scaleTiny,
          onDraw: () {
            // Player has discard the top deck revealed card
            // they now have to turn over one of their hidden card
            gameModel.deck.cardsDeckDiscarded.add(
              gameModel.deck.cardsDeckPile.removeLast(),
            );
            gameModel.gameState = GameStates.revealOneHiddenCard;
          },
          cardsAreHidden: false,
          wiggleTopCard: true,
          revealTopDeckCard: true,
          isDragSource: false,
          isDropTarget: true,
          onDragDropped: (cardSource, cardTarget, targetCenter) =>
              gameModel.onDropCardOnCard(
                context,
                cardSource,
                cardTarget,
                swapOrigin: targetCenter,
              ),
        ),
      ],
    );
  }
}

///
Widget buildMiniInstructions(
  bool isActivePlayer,
  String text,
  TextAlign align,
) {
  final TextStyle style = TextStyle(
    fontSize: ConstLayout.textS,
    color: Colors.white.withAlpha(
      isActivePlayer ? ConstLayout.alphaFull : ConstLayout.alphaL,
    ),
  );

  return Text(text, textAlign: align, style: style);
}
