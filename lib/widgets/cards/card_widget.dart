import 'package:cards/models/card_model.dart';
import 'package:cards/widgets/cards/card_face_french_widget.dart';
import 'package:cards/widgets/cards/card_face_skyjo_widget.dart';
import 'package:cards/widgets/wiggle_widget.dart';
import 'package:flutter/material.dart';

class CardDimensions {
  static const double width = 100.0;
  static const double height = 150.0;
  static const double margin = 4.0;
  static const double borderRadius = 4.0;
}

/// A widget that displays a playing card or a placeholder.
///
/// The [CardWidget] is responsible for rendering a playing card based on the provided [CardModel].
///
/// The widget uses the [WiggleWidget] to provide a wiggling animation when the card is selectable. It also adjusts the opacity of the card based on its selectable state.
///
/// The card surface is rendered using different methods depending on the card's properties, such as whether it is a Joker card or a regular card with suit and rank.
class CardWidget extends StatelessWidget {
  /// Creates a [CardWidget] with a [CardModel] card.
  /// If the card is null, a placeholder is shown.
  const CardWidget({
    super.key,
    required this.card,
    this.onDropped,
  });

  /// The playing card to be displayed.
  final CardModel card;
  final Function(CardModel source, CardModel target)? onDropped;

  @override
  Widget build(BuildContext context) {
    return DragTarget<CardModel>(
      onAcceptWithDetails: (DragTargetDetails<CardModel> data) {
        // DROPPED DROP CARD
        onDropped?.call(data.data, card);
      },
      onWillAcceptWithDetails: (data) => card.isSelectable && onDropped != null,
      builder: (context, List<CardModel?> candidateData, List rejectedData) {
        return Transform.scale(
          scale: candidateData.isEmpty ? 1.0 : 1.5,
          child: buildCard(),
        );
      },
    );
  }

  Widget buildCard() {
    return WiggleWidget(
      wiggle: card.isSelectable,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          margin: const EdgeInsets.all(CardDimensions.margin),
          width: CardDimensions.width,
          height: CardDimensions.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(CardDimensions.borderRadius),
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: card.suit == ''
              ? CardFaceSkyjoWidget(card: card)
              : CardFaceFrenchWidget(card: card),
        ),
      ),
    );
  }
}

Widget dragSource(final CardModel card) {
  return Draggable<CardModel>(
    data: card,
    feedback: Opacity(
      opacity: 0.8,
      child: CardWidget(
        card: card,
        onDropped: null,
      ),
    ),
    childWhenDragging: SizedBox(), // hide it when dragging
    child: CardWidget(
      card: card,
      onDropped: null,
    ),
  );
}
