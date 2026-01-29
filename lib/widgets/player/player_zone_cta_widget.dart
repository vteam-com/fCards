import 'package:cards/models/game_model.dart';
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
    if (player.isActivePlayer) {
      switch (gameModel.gameState) {
        //
        case GameStates.notStarted:
          return Text('Starting');

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
          return ctaFlipOneOfYourHiddenCards();

        //
        case GameStates.gameOver:
          return Text('GAME OVER');
      }
    } else {
      return buildWaitingForTurnContent();
    }
  }

  ///
  Widget buildWaitingForTurnContent() {
    return buildMiniInstructions(
      player.isActivePlayer,
      player.areAllCardsRevealed() ? 'You are done.' : 'Wait for your turn :)',
      TextAlign.center,
    );
  }

  ///
  Widget ctaFlipOneOfYourHiddenCards() {
    return buildMiniInstructions(
      true,
      '↓ Flip open one of your hidden cards ↓',
      TextAlign.center,
    );
  }

  ///
  /// Draw Card [DECK]   [DISCARD] or here
  ///  here ->                     <-
  ///
  Widget ctaPickCardFromPiles(final BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (GameStates.swapTopDeckCardWithAnyCardsInHandOrDiscard !=
            gameModel.gameState)
          buildMiniInstructions(true, 'Draw\na card\nhere\n→', TextAlign.left),
        const SizedBox(width: 10),
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
          onDraw: () =>
              gameModel.selectTopCardOfDeck(context, fromDiscardPile: false),
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
          onDraw: () =>
              gameModel.selectTopCardOfDeck(context, fromDiscardPile: true),
        ),
        const SizedBox(width: 10),
        buildMiniInstructions(true, '\nor\nhere\n←', TextAlign.right),
      ],
    );
  }

  ///
  /// [DECK] (instructions)[DISCARD]<<Active
  ///
  Widget ctaSwapDiscardedCardWithAnyCardsInHand(BuildContext context) {
    gameModel.deck.cardsDeckDiscarded.last.isSelectable = false;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // left Pile
        CardPileWidget(
          cards: gameModel.deck.cardsDeckPile,
          scale: 0.80,
          wiggleTopCard: false,
          cardsAreHidden: true,
          revealTopDeckCard: false,
          isDragSource: false,
          isDropTarget: false,
          onDragDropped: null,
        ),

        // Let them know what to do
        buildMiniInstructions(true, 'swap this →\n\nwith ↓', TextAlign.center),

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
          onDraw: () =>
              gameModel.selectTopCardOfDeck(context, fromDiscardPile: true),
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
          onDragDropped: (cardSource, cardTarget) =>
              gameModel.onDropCardOnCard(context, cardSource, cardTarget),
        ),
        buildMiniInstructions(true, 'Discard →\nor\n↓ swap', TextAlign.center),
        CardPileWidget(
          cards: gameModel.deck.cardsDeckDiscarded,
          scale: 0.75,
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
          onDragDropped: (cardSource, cardTarget) =>
              gameModel.onDropCardOnCard(context, cardSource, cardTarget),
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
    fontSize: 18,
    color: Colors.white.withAlpha(isActivePlayer ? 255 : 140),
  );

  return Text(text, textAlign: align, style: style);
}
