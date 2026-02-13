import 'dart:math';

import 'package:cards/models/app/constants_card_value.dart';
import 'package:cards/models/app/constants_layout.dart';
import 'package:cards/widgets/helpers/my_text.dart';
import 'package:cards/models/card/card_model.dart';
import 'package:cards/widgets/cards/card_face_french_widget.dart';
import 'package:flutter/material.dart';

/// A widget that displays a playing card's face or back.
///
/// The [CardFaceSkyjoWidget] is responsible for rendering a playing card based on the provided [CardModel].
///
/// The widget uses different methods to display the front and back of the card depending on its properties.
class CardFaceSkyjoWidget extends CardFaceFrenchWidget {
  /// Creates a [CardFaceSkyjoWidget] with a [CardModel] card.
  const CardFaceSkyjoWidget({super.key, required super.card});

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
            width: ConstLayout.skyjoCardWidth,
            height: ConstLayout.skyjoCardHeight,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.white, getBackColor(card.value)],
                center: Alignment.center,
                radius: ConstLayout.skyjoRadialRadius,
              ),
            ),
            // color: getBackColor(card.value),
            child: Stack(
              children: [
                Positioned(
                  top: ConstLayout.skyjoOffset,
                  left: ConstLayout.skyjoOffset,
                  child: _buildSmallText(),
                ),
                Center(child: _buildMainText()),
                Positioned(
                  bottom: ConstLayout.skyjoOffset,
                  right: ConstLayout.skyjoOffset,
                  child: Transform.rotate(
                    angle: pi, // 180 degrees in radians
                    child: _buildSmallText(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the small corner rank label used on both card corners.
  Widget _buildSmallText() {
    return Stack(
      children: [
        MyText(
          card.rank,
          fontSize: ConstLayout.textM,
          align: TextAlign.center,
          color: Colors.black,
          bold: true,
        ),
      ],
    );
  }

  /// Builds the large center value text with outline styling.
  Widget _buildMainText() {
    return Stack(
      children: [
        Text(
          card.value.toString(),
          style:
              TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: ConstLayout.textXL,
                color: Colors.white,
                decoration: TextDecoration.none,
              ).copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = ConstLayout.strokeL
                  ..color = Colors.white,
              ),
        ),
        Text(
          card.value.toString(),
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontSize: ConstLayout.textXL,
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
    } else if (value < ConstCardValue.skyjoValueThreshold5) {
      return Colors.lightGreen;
    } else if (value < ConstCardValue.skyjoValueThreshold9) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
