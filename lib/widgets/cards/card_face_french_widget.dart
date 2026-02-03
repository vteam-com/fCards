import 'package:cards/models/app/constants_card_value.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/helpers/misc.dart';
import 'package:cards/models/card/card_model.dart';

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
            ConstLayout.textL,
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
            TextSize(card.rank, ConstLayout.textL, bold: true, color: color),
            TextSize(card.suit, ConstLayout.textS, bold: true, color: color),
          ],
        );
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextSize(card.rank, ConstLayout.textL, bold: true, color: color),
          ],
        );
    }
  }

  ///
  Widget buildSuitSymbol({final double size = ConstLayout.textS}) {
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
      case ConstCardValue.cardValueJoker: // Joker
        return [figureCards('⛳')];
      case ConstCardValue.cardValueKing: // King
        return [figureCards('♚')];
      case ConstCardValue.cardValueQueen: // Queen
        return [figureCards('♛')];
      case ConstCardValue.cardValueJack: // Jack
        return [figureCards('♝')];

      case 1:
        return [Center(child: buildSuitSymbol(size: ConstLayout.textL))];

      // Layout for number cards 2 to 10
      case ConstCardValue.cardValue2:
        positions = [
          Offset(0, -ConstCardValue.cardOffset30),
          Offset(0, ConstCardValue.cardOffset30),
        ];
        break;
      case ConstCardValue.cardValue3:
        positions = [
          Offset(0, -ConstCardValue.cardOffset30),
          Offset(0, 0),
          Offset(0, ConstCardValue.cardOffset30),
        ];
        break;
      case ConstCardValue.cardValue4:
        positions = [
          Offset(-ConstCardValue.cardOffset20, -ConstCardValue.cardOffset20),
          Offset(ConstCardValue.cardOffset20, -ConstCardValue.cardOffset20),
          Offset(-ConstCardValue.cardOffset20, ConstCardValue.cardOffset20),
          Offset(ConstCardValue.cardOffset20, ConstCardValue.cardOffset20),
        ];
        break;
      case ConstCardValue.cardValue5:
        positions = [
          // top
          Offset(0, 0),

          // left
          Offset(-ConstCardValue.cardOffset20, -ConstCardValue.cardOffset20),
          Offset(-ConstCardValue.cardOffset20, ConstCardValue.cardOffset20),

          // right
          Offset(ConstCardValue.cardOffset20, -ConstCardValue.cardOffset20),
          Offset(ConstCardValue.cardOffset20, ConstCardValue.cardOffset20),
        ];
        break;
      case ConstCardValue.cardValue6:
        positions = [
          // left column
          Offset(-ConstCardValue.cardOffset15, -ConstCardValue.cardOffset30),
          Offset(-ConstCardValue.cardOffset15, 0),
          Offset(-ConstCardValue.cardOffset15, ConstCardValue.cardOffset30),

          // right column
          Offset(ConstCardValue.cardOffset20, -ConstCardValue.cardOffset30),
          Offset(ConstCardValue.cardOffset20, 0),
          Offset(ConstCardValue.cardOffset20, ConstCardValue.cardOffset30),
        ];
        break;
      case ConstCardValue.cardValue7:
        positions = [
          // left
          Offset(-ConstCardValue.cardOffset20, -ConstCardValue.cardOffset30),
          Offset(-ConstCardValue.cardOffset20, 0),
          Offset(-ConstCardValue.cardOffset20, ConstCardValue.cardOffset30),
          // center
          Offset(0, 0),
          // right
          Offset(ConstCardValue.cardOffset20, -ConstCardValue.cardOffset30),
          Offset(ConstCardValue.cardOffset20, 0),
          Offset(ConstCardValue.cardOffset20, ConstCardValue.cardOffset30),
        ];
        break;
      case ConstCardValue.cardValue8:
        positions = [
          // top row
          Offset(-ConstCardValue.cardOffset20, -ConstCardValue.cardOffset30),
          Offset(ConstCardValue.cardOffset20, -ConstCardValue.cardOffset30),
          // second
          Offset(-ConstCardValue.cardOffset20, -ConstCardValue.cardOffset10),
          Offset(ConstCardValue.cardOffset20, -ConstCardValue.cardOffset10),
          // third
          Offset(-ConstCardValue.cardOffset20, ConstCardValue.cardOffset10),
          Offset(ConstCardValue.cardOffset20, ConstCardValue.cardOffset10),
          // last
          Offset(-ConstCardValue.cardOffset20, ConstCardValue.cardOffset30),
          Offset(ConstCardValue.cardOffset20, ConstCardValue.cardOffset30),
        ];
        break;
      case ConstCardValue.cardValue9:
        positions = [
          // left
          Offset(-ConstCardValue.cardOffset20, -ConstCardValue.cardOffset30),
          Offset(-ConstCardValue.cardOffset20, 0),
          Offset(-ConstCardValue.cardOffset20, ConstCardValue.cardOffset30),
          // center
          Offset(0, -ConstCardValue.cardOffset30),
          Offset(0, 0),
          Offset(0, ConstCardValue.cardOffset30),
          // right
          Offset(ConstCardValue.cardOffset20, -ConstCardValue.cardOffset30),
          Offset(ConstCardValue.cardOffset20, 0),
          Offset(ConstCardValue.cardOffset20, ConstCardValue.cardOffset30),
        ];
        break;
      case ConstCardValue.cardValue10:
        positions = [
          // Left column
          Offset(-ConstCardValue.cardOffset20, -ConstCardValue.cardOffset30),
          Offset(-ConstCardValue.cardOffset20, -ConstCardValue.cardOffset10),
          Offset(-ConstCardValue.cardOffset20, ConstCardValue.cardOffset10),
          Offset(-ConstCardValue.cardOffset20, ConstCardValue.cardOffset30),
          Offset(-ConstCardValue.cardOffset20, ConstCardValue.cardOffset50),

          // right column
          Offset(ConstCardValue.cardOffset20, -ConstCardValue.cardOffset50),
          Offset(ConstCardValue.cardOffset20, -ConstCardValue.cardOffset30),
          Offset(ConstCardValue.cardOffset20, -ConstCardValue.cardOffset10),
          Offset(ConstCardValue.cardOffset20, ConstCardValue.cardOffset10),
          Offset(ConstCardValue.cardOffset20, ConstCardValue.cardOffset30),
        ];
        break;
      default:
        positions = [];
    }

    for (final Offset position in positions) {
      symbols.add(
        Positioned(
          left:
              ConstLayout.cardCenterOffsetX +
              position.dx, // Adjust to center horizontally
          top:
              ConstLayout.cardCenterOffsetY +
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
          ConstLayout.textM,
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
            fontSize: ConstLayout.textXL,
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
