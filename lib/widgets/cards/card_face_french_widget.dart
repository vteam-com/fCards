import 'package:cards/widgets/helpers/misc.dart';
import 'package:cards/models/card/card_model.dart';
import 'package:cards/models/app/constants.dart';

import 'package:flutter/material.dart';

/// A widget that displays a playing card's face or back.
///
/// The [CardFaceFrenchWidget] is responsible for rendering a playing card based on the provided [CardModel].
///
/// The widget uses different methods to display the front and back of the card depending on its properties.
class CardFaceFrenchWidget extends StatelessWidget {
  /// Creates a [CardFaceFrenchWidget] with a [CardModel] card.
  const CardFaceFrenchWidget({super.key, required this.card});

  /// The playing card to be displayed.
  final CardModel card;

  @override
  Widget build(BuildContext context) {
    return card.isRevealed ? buildFaceUp() : buildFaceDown();
  }

  /// Render the back of the card
  Widget buildFaceDown() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/back_of_card.png'),
          fit: BoxFit.fill, // adjust the fit as needed
        ),
      ),
    );
  }

  /// Render the front of the card
  Widget buildFaceUp() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Stack(
        children: [
          Column(children: [buildRank(), const Spacer(), buildValue()]),
          ...buildSuitSymbols(),
        ],
      ),
    );
  }

  ///
  Widget buildRank() {
    final color = getSuitColor(card.suit);
    switch (card.rank) {
      case '§':
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: TextSize(
            'Joker',
            align: TextAlign.center,
            Constants.textL,
            bold: true,
            color: color,
          ),
        );
      case 'K':
      case 'Q':
      case 'J':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextSize(card.rank, Constants.textL, bold: true, color: color),
            TextSize(card.suit, Constants.textS, bold: true, color: color),
          ],
        );
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextSize(card.rank, Constants.textL, bold: true, color: color),
          ],
        );
    }
  }

  ///
  Widget buildSuitSymbol({final double size = Constants.textS}) {
    return Text(
      card.suit,
      style: TextStyle(
        fontSize: size,
        color: getSuitColor(card.suit),
        decoration: TextDecoration.none,
      ),
    );
  }

  ///
  List<Widget> buildSuitSymbols() {
    List<Widget> symbols = [];
    int numSymbols = card.value;

    List<Offset> positions;
    switch (numSymbols) {
      case Constants.cardValueJoker: // Joker
        return [figureCards('⛳')];
      case Constants.cardValueKing: // King
        return [figureCards('♚')];
      case Constants.cardValueQueen: // Queen
        return [figureCards('♛')];
      case Constants.cardValueJack: // Jack
        return [figureCards('♝')];

      case 1:
        return [Center(child: buildSuitSymbol(size: Constants.textL))];

      // Layout for number cards 2 to 10
      case Constants.cardValue2:
        positions = [
          Offset(0, -Constants.cardOffset30),
          Offset(0, Constants.cardOffset30),
        ];
        break;
      case Constants.cardValue3:
        positions = [
          Offset(0, -Constants.cardOffset30),
          Offset(0, 0),
          Offset(0, Constants.cardOffset30),
        ];
        break;
      case Constants.cardValue4:
        positions = [
          Offset(-Constants.cardOffset20, -Constants.cardOffset20),
          Offset(Constants.cardOffset20, -Constants.cardOffset20),
          Offset(-Constants.cardOffset20, Constants.cardOffset20),
          Offset(Constants.cardOffset20, Constants.cardOffset20),
        ];
        break;
      case Constants.cardValue5:
        positions = [
          // top
          Offset(0, 0),

          // left
          Offset(-Constants.cardOffset20, -Constants.cardOffset20),
          Offset(-Constants.cardOffset20, Constants.cardOffset20),

          // right
          Offset(Constants.cardOffset20, -Constants.cardOffset20),
          Offset(Constants.cardOffset20, Constants.cardOffset20),
        ];
        break;
      case Constants.cardValue6:
        positions = [
          // left column
          Offset(-Constants.cardOffset15, -Constants.cardOffset30),
          Offset(-Constants.cardOffset15, 0),
          Offset(-Constants.cardOffset15, Constants.cardOffset30),

          // right column
          Offset(Constants.cardOffset20, -Constants.cardOffset30),
          Offset(Constants.cardOffset20, 0),
          Offset(Constants.cardOffset20, Constants.cardOffset30),
        ];
        break;
      case Constants.cardValue7:
        positions = [
          // left
          Offset(-Constants.cardOffset20, -Constants.cardOffset30),
          Offset(-Constants.cardOffset20, 0),
          Offset(-Constants.cardOffset20, Constants.cardOffset30),
          // center
          Offset(0, 0),
          // right
          Offset(Constants.cardOffset20, -Constants.cardOffset30),
          Offset(Constants.cardOffset20, 0),
          Offset(Constants.cardOffset20, Constants.cardOffset30),
        ];
        break;
      case Constants.cardValue8:
        positions = [
          // top row
          Offset(-Constants.cardOffset20, -Constants.cardOffset30),
          Offset(Constants.cardOffset20, -Constants.cardOffset30),
          // second
          Offset(-Constants.cardOffset20, -Constants.cardOffset10),
          Offset(Constants.cardOffset20, -Constants.cardOffset10),
          // third
          Offset(-Constants.cardOffset20, Constants.cardOffset10),
          Offset(Constants.cardOffset20, Constants.cardOffset10),
          // last
          Offset(-Constants.cardOffset20, Constants.cardOffset30),
          Offset(Constants.cardOffset20, Constants.cardOffset30),
        ];
        break;
      case Constants.cardValue9:
        positions = [
          // left
          Offset(-Constants.cardOffset20, -Constants.cardOffset30),
          Offset(-Constants.cardOffset20, 0),
          Offset(-Constants.cardOffset20, Constants.cardOffset30),
          // center
          Offset(0, -Constants.cardOffset30),
          Offset(0, 0),
          Offset(0, Constants.cardOffset30),
          // right
          Offset(Constants.cardOffset20, -Constants.cardOffset30),
          Offset(Constants.cardOffset20, 0),
          Offset(Constants.cardOffset20, Constants.cardOffset30),
        ];
        break;
      case Constants.cardValue10:
        positions = [
          // Left column
          Offset(-Constants.cardOffset20, -Constants.cardOffset30),
          Offset(-Constants.cardOffset20, -Constants.cardOffset10),
          Offset(-Constants.cardOffset20, Constants.cardOffset10),
          Offset(-Constants.cardOffset20, Constants.cardOffset30),
          Offset(-Constants.cardOffset20, Constants.cardOffset50),

          // right column
          Offset(Constants.cardOffset20, -Constants.cardOffset50),
          Offset(Constants.cardOffset20, -Constants.cardOffset30),
          Offset(Constants.cardOffset20, -Constants.cardOffset10),
          Offset(Constants.cardOffset20, Constants.cardOffset10),
          Offset(Constants.cardOffset20, Constants.cardOffset30),
        ];
        break;
      default:
        positions = [];
    }

    for (final Offset position in positions) {
      symbols.add(
        Positioned(
          left:
              Constants.cardCenterOffsetX +
              position.dx, // Adjust to center horizontally
          top:
              Constants.cardCenterOffsetY +
              position.dy, // Adjust to center vertically
          child: buildSuitSymbol(),
        ),
      );
    }

    return symbols;
  }

  ///
  Widget buildValue() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextSize(
          card.value.toString(),
          Constants.textM,
          align: TextAlign.right,
          bold: true,
          color: getSuitColor(card.suit),
        ),
      ],
    );
  }

  ///
  Widget figureCards(final String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: Constants.textXL,
            color: getSuitColor(card.suit),
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  /// Returns the color associated with the suit string.
  Color getSuitColor(String suit) {
    switch (suit) {
      case '♥️':
      case '♦️':
        return Colors.red;
      case '♣️':
      case '♠️':
        return Colors.black;
      default:
        return Colors.green;
    }
  }
}
