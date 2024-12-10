import 'package:cards/misc.dart';
import 'package:cards/models/base/card_model.dart';
import 'package:flutter/material.dart';

/// A widget that displays a playing card's face or back.
///
/// The [CardFaceWidget] is responsible for rendering a playing card based on the provided [CardModel].
///
/// The widget uses different methods to display the front and back of the card depending on its properties.
class CardFaceWidget extends StatelessWidget {
  /// Creates a [CardFaceWidget] with a [CardModel] card.
  const CardFaceWidget({
    super.key,
    required this.card,
  });

  /// The playing card to be displayed.
  final CardModel card;

  @override
  Widget build(BuildContext context) {
    return card.isRevealed ? buildFaceUp() : buildFaceDown();
  }

  Widget buildFaceUp() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Stack(
        children: [
          Column(
            children: [
              buildRank(),
              const Spacer(),
              buildValue(),
            ],
          ),
          ...buildSuitSymbols(),
        ],
      ),
    );
  }

  Widget buildRank() {
    final color = getSuitColor(card.suit);
    switch (card.rank) {
      case '§':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextSize(
              'Joker',
              align: TextAlign.center,
              30,
              bold: true,
              color: color,
            ),
          ],
        );
      case 'K':
      case 'Q':
      case 'J':
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextSize(
              card.rank,
              40,
              bold: true,
              color: color,
            ),
            TextSize(
              card.suit,
              20,
              bold: true,
              color: color,
            ),
          ],
        );
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextSize(
              card.rank,
              40,
              bold: true,
              color: color,
            ),
          ],
        );
    }
  }

  Widget buildValue() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextSize(
          card.value.toString(),
          20,
          align: TextAlign.right,
          bold: true,
          color: getSuitColor(card.suit),
        ),
      ],
    );
  }

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

  Widget buildSuitSymbol({final double size = 18}) {
    return Text(
      card.suit,
      style: TextStyle(
        fontSize: size,
        color: getSuitColor(card.suit),
        decoration: TextDecoration.none,
      ),
    );
  }

  List<Widget> buildSuitSymbols() {
    List<Widget> symbols = [];
    int numSymbols = card.value;

    List<Offset> positions;
    switch (numSymbols) {
      case -2: // Joker
        return [figureCards('⛳')];
      case 0: // King
        return [figureCards('♚')];
      case 12: // Queen
        return [figureCards('♛')];
      case 11: // Jack
        return [figureCards('♝')];

      case 1:
        return [Center(child: buildSuitSymbol(size: 30))];

      // Layout for number cards 2 to 10
      case 2:
        positions = [Offset(0, -30), Offset(0, 30)];
        break;
      case 3:
        positions = [
          Offset(0, -30),
          Offset(0, 0),
          Offset(0, 30),
        ];
        break;
      case 4:
        positions = [
          Offset(-20, -20),
          Offset(20, -20),
          Offset(-20, 20),
          Offset(20, 20),
        ];
        break;
      case 5:
        positions = [
          // top
          Offset(0, 0),

          // left
          Offset(-20, -20),
          Offset(-20, 20),

          // right
          Offset(20, -20),
          Offset(20, 20),
        ];
        break;
      case 6:
        positions = [
          // left column
          Offset(-15, -30),
          Offset(-15, 0),
          Offset(-15, 30),

          // right column
          Offset(20, -30),
          Offset(20, 0),
          Offset(20, 30),
        ];
        break;
      case 7:
        positions = [
          // left
          Offset(-20, -30),
          Offset(-20, 0),
          Offset(-20, 30),
          // center
          Offset(0, 0),
          // right
          Offset(20, -30),
          Offset(20, 0),
          Offset(20, 30),
        ];
        break;
      case 8:
        positions = [
          // top row
          Offset(-20, -30),
          Offset(20, -30),
          // second
          Offset(-20, -10),
          Offset(20, -10),
          // third
          Offset(-20, 10),
          Offset(20, 10),
          // last
          Offset(-20, 30),
          Offset(20, 30),
        ];
        break;
      case 9:
        positions = [
          // left
          Offset(-20, -30),
          Offset(-20, 0),
          Offset(-20, 30),
          // center
          Offset(0, -30),
          Offset(0, 0),
          Offset(0, 30),
          // right
          Offset(20, -30),
          Offset(20, 0),
          Offset(20, 30),
        ];
        break;
      case 10:
        positions = [
          // Left column
          Offset(-20, -30),
          Offset(-20, -10),
          Offset(-20, 10),
          Offset(-20, 30),
          Offset(-20, 50),

          // right column
          Offset(20, -50),
          Offset(20, -30),
          Offset(20, -10),
          Offset(20, 10),
          Offset(20, 30),
        ];
        break;
      default:
        positions = [];
    }

    for (final Offset position in positions) {
      symbols.add(
        Positioned(
          left: 35 + position.dx, // Adjust 50 to center horizontally
          top: 70 + position.dy, // Adjust 75 to center vertically
          child: buildSuitSymbol(),
        ),
      );
    }

    return symbols;
  }

  Widget figureCards(final String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 30.0),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: getSuitColor(card.suit),
            fontSize: 60,
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

class CardDimensions {
  static const double width = 100.0;
  static const double height = 150.0;
  static const double margin = 4.0;
  static const double borderRadius = 4.0;
}
