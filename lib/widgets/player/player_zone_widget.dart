import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:cards/misc.dart';
import 'package:cards/models/base/game_model.dart';
import 'package:cards/widgets/cards/card_widget.dart';
import 'package:cards/widgets/player/player_header_widget.dart';
import 'package:cards/widgets/player/player_zone_cta_widget.dart';
import 'package:flutter/material.dart';

class PlayerZoneWidget extends StatelessWidget {
  const PlayerZoneWidget({
    super.key,
    required this.gameModel,
    required this.player,
    required this.heightZone,
    required this.heightOfCTA,
    required this.heightOfCardGrid,
  });
  final GameModel gameModel;
  final PlayerModel player;
  final double heightZone;
  final double heightOfCTA;
  final double heightOfCardGrid;

  @override
  Widget build(BuildContext context) {
    debugLog(player.toString());
    final double width = min(400, MediaQuery.of(context).size.width);
    return Stack(
      children: [
        if (player.isActivePlayer)
          FadeIn(
            child: _containerBorder(width, heightZone),
          ),
        Container(
          width: width,
          height: heightZone,
          decoration: BoxDecoration(
            color: Colors.green.shade800.withAlpha(50),
            border: Border.all(
              color: Colors.transparent,
              width: 8,
            ),
            borderRadius: BorderRadius.circular(20.0),
            // No shadow.
          ),
          padding: EdgeInsets.all(10),
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _containerBorder(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.yellow,
          width: 8,
        ),
        borderRadius: BorderRadius.circular(20.0),
        // No shadow.
      ),
    );
  }

  LinearGradient activeBorder() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.yellow.shade200,
        Colors.yellow.shade700,
      ],
    );
  }

  Widget _buildContent(final BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //
        // Header
        //
        PlayerHeaderWidget(
          name: player.name,
          sumOfRevealedCards: player.sumOfRevealedCards,
        ),

        //
        // line
        //
        Divider(color: Colors.white.withAlpha(100)),

        //
        // CTA
        //
        SizedBox(
          height: heightOfCTA,
          child: PlayerZoneCtaWidget(
            player: player,
            gameModel: gameModel,
          ),
        ),

        //
        // line
        //
        Divider(color: Colors.white.withAlpha(100)),

        //
        // Cards in Hand
        //
        SizedBox(
          height: heightOfCardGrid,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: _buildPlayerHand(
              context,
              gameModel,
              player,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerHand(
    BuildContext context,
    GameModel gameModel,
    PlayerModel player,
  ) {
    List row = List.empty(growable: true);

    // For now we always do columns of 3
    for (int i = 0; i < player.hand.length - 2; i += 3) {
      row.add(
        Column(
          children: [i, i + 1, i + 2].map((cardIndex) {
            return _buildPlayerCardButton(
              context,
              gameModel,
              player,
              cardIndex,
            );
          }).toList(),
        ),
      );
    }
    return Row(
      children: [...row],
    );
  }

  Widget _buildPlayerCardButton(
    BuildContext context,
    GameModel gameModel,
    PlayerModel player,
    int gridIndex,
  ) {
    if (gridIndex >= player.hand.length) {
      return Container();
    }
    final CardModel card = player.hand[gridIndex];

    card.isRevealed = player.hand[gridIndex].isRevealed;

    card.isSelectable = player.isActivePlayer &&
        (gameModel.gameState ==
                GameStates.swapDiscardedCardWithAnyCardsInHand ||
            gameModel.gameState ==
                GameStates.swapTopDeckCardWithAnyCardsInHandOrDiscard ||
            (gameModel.gameState == GameStates.revealOneHiddenCard &&
                !card.isRevealed));

    return GestureDetector(
      onTap: () {
        gameModel.revealCard(context, player, gridIndex);
      },
      child: CardWidget(
        card: card,
        onDropped: (cardSource, cardTarget) {
          gameModel.onDropCardOnCard(context, cardSource, cardTarget);
        },
      ),
    );
  }
}
