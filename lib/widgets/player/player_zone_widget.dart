import 'dart:math';
import 'package:animate_do/animate_do.dart';

import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/models/game/game_model.dart';
import 'package:cards/widgets/cards/card_widget.dart';
import 'package:cards/widgets/player/player_header_widget.dart';
import 'package:cards/widgets/player/player_zone_cta_widget.dart';
import 'package:flutter/material.dart';

class PlayerZoneWidget extends StatelessWidget {
  /// Constructs a [PlayerZoneWidget] with the provided parameters.
  ///
  /// The [gameModel] parameter is required and represents the current game model.
  /// The [player] parameter is required and represents the player for this zone.
  /// The [heightZone] parameter is required and represents the height of the player zone.
  /// The [heightOfCTA] parameter is required and represents the height of the CTA (Call-to-Action) widget.
  /// The [heightOfCardGrid] parameter is required and represents the height of the card grid.
  const PlayerZoneWidget({
    super.key,
    required this.gameModel,
    required this.player,
    required this.heightZone,
    required this.heightOfCTA,
    required this.heightOfCardGrid,
  });

  /// The game model containing the current game state and logic
  final GameModel gameModel;

  /// The height allocated for the call-to-action section
  final double heightOfCTA;

  /// The height allocated for displaying the player's card grid
  final double heightOfCardGrid;

  /// The total height of the player zone widget
  final double heightZone;

  /// The player model representing this zone's player
  final PlayerModel player;

  @override
  Widget build(BuildContext context) {
    final double width = min(
      ConstLayout.joinGamePlayerListMaxWidth,
      MediaQuery.of(context).size.width,
    );
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      alignment: Alignment.center,
      children: [
        FadeIn(child: _containerBorder(width, heightZone)),
        Container(
          width: width - ConstLayout.radiusM,
          height: heightZone - ConstLayout.radiusM,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            border: Border.all(
              color: Colors.transparent,
              width: CardModel.golfGrid2x2Size,
            ),
            borderRadius: BorderRadius.circular(ConstLayout.radiusM),
            // No shadow.
          ),
          padding: EdgeInsets.all(ConstLayout.sizeS.toDouble()),
          child: _buildContent(context),
        ),
      ],
    );
  }

  ///
  LinearGradient activeBorder() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.yellow.shade200, Colors.yellow.shade700],
    );
  }

  Widget _buildContent(final BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //
        // Header
        //
        PlayerHeaderWidget(
          gameModel: gameModel,
          player: player,
          onStatusChanged: (PlayerStatus newStatus) {
            gameModel.updatePlayerStatus(player, newStatus);
          },
          sumOfRevealedCards: player.sumOfRevealedCards,
        ),

        //
        // CTA
        //
        SizedBox(
          height: heightOfCTA,
          child: PlayerZoneCtaWidget(player: player, gameModel: gameModel),
        ),

        //
        // Cards in Hand
        //
        SizedBox(
          height: heightOfCardGrid,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: _buildPlayerHand(context, gameModel, player),
          ),
        ),
      ],
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

    card.isSelectable =
        player.isActivePlayer &&
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

  Widget _buildPlayerHand(
    BuildContext context,
    GameModel gameModel,
    PlayerModel player,
  ) {
    List row = List.empty(growable: true);
    int columns = player.hand.length == CardModel.golfGrid2x2Size
        ? CardModel.miniPutColumns
        : CardModel.standardColumns;

    for (int i = 0; i < player.hand.length; i += columns) {
      List<Widget> columnChildren = [];
      for (int j = 0; j < columns && (i + j) < player.hand.length; j++) {
        columnChildren.add(
          _buildPlayerCardButton(context, gameModel, player, i + j),
        );
      }
      row.add(Column(children: columnChildren));
    }

    return Row(children: [...row]);
  }

  Widget _containerBorder(double width, double height) {
    Color color = Colors.transparent;
    if (gameModel.gameState == GameStates.gameOver) {
      color = player.isWinner ? Colors.green : Colors.red;
    } else {
      if (player.areAllCardsRevealed()) {
        color = Colors.blue;
      } else if (player.isActivePlayer) {
        color = Colors.yellow;
      }
    }

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: ConstLayout.sizeS),
        borderRadius: BorderRadius.circular(ConstLayout.radiusM),
        // No shadow.
      ),
    );
  }
}
