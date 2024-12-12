import 'dart:math';

import 'package:cards/misc.dart';
import 'package:cards/models/card_model.dart';
import 'package:cards/widgets/cards/card_face_french_widget.dart';
import 'package:flutter/material.dart';

/// A widget that displays a playing card's face or back.
///
/// The [CardFaceSkyjoWidget] is responsible for rendering a playing card based on the provided [CardModel].
///
/// The widget uses different methods to display the front and back of the card depending on its properties.
class CardFaceSkyjoWidget extends CardFaceFrenchWidget {
  /// Creates a [CardFaceSkyjoWidget] with a [CardModel] card.
  const CardFaceSkyjoWidget({
    super.key,
    required super.card,
  });

  @override
  Widget build(BuildContext context) {
    return card.isRevealed ? buildFaceUp() : buildFaceDown();
  }

  @override
  Widget buildFaceUp() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Stack(
        children: [
          Container(
            width: 200,
            height: 300,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.white,
                  getBackColor(card.value),
                ],
                center: Alignment.center,
                radius: 0.75,
              ),
            ),
            // color: getBackColor(card.value),
            child: Stack(
              children: [
                Positioned(
                  top: 10,
                  left: 10,
                  child: buildSmallText(),
                ),
                Center(child: buildMainText()),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Transform.rotate(
                    angle: pi, // 180 degrees in radians
                    child: buildSmallText(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSmallText() {
    return Stack(
      children: [
        TextSize(
          card.rank,
          20,
          align: TextAlign.center,
          color: Colors.black,
          bold: true,
        ),
      ],
    );
  }

  Widget buildMainText() {
    return Stack(
      children: [
        Text(
          card.value.toString(),
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 60,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = Colors.white,
            decoration: TextDecoration.none,
          ),
        ),
        Text(
          card.value.toString(),
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: 60,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  /// Returns the color associated with the suit string.
  Color getBackColor(int value) {
    if (value < 0) {
      return Colors.blueGrey;
    } else if (value == 0) {
      return Colors.blue;
    } else if (value < 5) {
      return Colors.lightGreen;
    } else if (value < 9) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
